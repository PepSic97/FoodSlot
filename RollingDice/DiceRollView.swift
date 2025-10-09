//
//  DiceRollView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI
import SceneKit
import CoreMotion
import CoreData

struct DiceRollView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isRolling = false
    @State private var hasRolled = false
    @State private var resultText: String?
    let die: Die
    @State private var scene = SCNScene()
    @State private var diceNode: SCNNode?
    @State private var currentResultIndex: Int?
    let motionManager = CMMotionManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Lancia il d\(die.sides)")
                .font(.title)
            
            // SceneView senza allowsCameraControl per permettere drag
            SceneView(
                scene: scene,
                pointOfView: nil,
                options: [],
                preferredFramesPerSecond: 60,
                antialiasingMode: .multisampling4X
            )
            .frame(width: 250, height: 250)
            .contentShape(Rectangle())
            // Tap
            .onTapGesture {
                guard !hasRolled else { return }
                startDiceAnimation()
            }
            // Drag/scroll intercettato come tap
            .highPriorityGesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { _ in
                        guard !hasRolled else { return }
                        startDiceAnimation()
                    }
            )
            
            if let text = resultText {
                Text("Ha vinto " + text)
                    .font(.title)
            }
        }
        .onAppear {
            setupScene()
            startShakeDetection()
        }
        .onDisappear {
            motionManager.stopAccelerometerUpdates()
        }
    }

    // MARK: - Setup scena
    func setupScene() {
        scene = SCNScene()
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        scene.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        let geom = geometryForDie(sides: die.sides, faceTexts: die.faceTexts)
        diceNode = SCNNode(geometry: geom)
        scene.rootNode.addChildNode(diceNode!)
    }

    // MARK: - Animazione dado (tap/drag/shake)
    func startDiceAnimation(durationMultiplier: Double = 1.0) {
        guard !isRolling, let diceNode = diceNode else { return }
        isRolling = true
        hasRolled = true

        // Estrai risultato casuale
        let index = Int.random(in: 0..<die.sides)
        currentResultIndex = index
        let text = die.faceTexts[index].isEmpty ? "Faccia \(index+1)" : die.faceTexts[index]

        // Rotazione casuale iniziale
        let randomX = Float.random(in: 0...Float.pi * 3)
        let randomY = Float.random(in: 0...Float.pi * 3)
        let finalRotation = rotationForFace(index: index)

        // Sequenza animazione: rotateBy + rotateTo
        let rotateSequence = SCNAction.sequence([
            SCNAction.rotateBy(x: CGFloat(randomX), y: CGFloat(randomY), z: 0, duration: 0.8 * durationMultiplier),
            SCNAction.rotateTo(x: CGFloat(finalRotation.x),
                               y: CGFloat(finalRotation.y),
                               z: CGFloat(finalRotation.z),
                               duration: 0.4 * durationMultiplier,
                               usesShortestUnitArc: true)
        ])
        diceNode.runAction(rotateSequence)

        // Aggiorna materiale e salva risultato dopo animazione
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 * durationMultiplier) {
            self.updateFrontMaterial(with: text)
            self.resultText = text
            self.saveResult(text)
            self.isRolling = false
        }
    }

    // MARK: - Shake detection con debounce e animazione più veloce
    func startShakeDetection() {
        var lastShakeTime = Date.distantPast

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, _ in
                guard let acc = data?.acceleration else { return }
                let magnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
                
                if magnitude > 2.5 {
                    let now = Date()
                    if now.timeIntervalSince(lastShakeTime) > 1.0 {
                        lastShakeTime = now
                        if !hasRolled {
                            // Shake più veloce
                            startDiceAnimation(durationMultiplier: 0.5)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Materiali
    func blankMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white
        return mat
    }

    func updateFrontMaterial(with text: String) {
        guard let box = diceNode?.geometry as? SCNBox else { return }
        let mat = SCNMaterial()
        mat.diffuse.contents = imageFromText(text)
        box.materials[2] = mat
    }

    func imageFromText(_ text: String) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 40, weight: .bold),
            .paragraphStyle: paragraphStyle
        ]
        let rect = CGRect(x: 0, y: (size.height - 50)/2, width: size.width, height: 50)
        text.draw(in: rect, withAttributes: attrs)

        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }

    // MARK: - Salvataggio
    private func saveResult(_ value: String) {
        let newResult = RollResult(context: viewContext)
        newResult.value = value
        newResult.timestamp = Date()

        do {
            try viewContext.save()
        } catch {
            print("Errore nel salvataggio del risultato: \(error)")
        }
    }

    // MARK: - Calcolo orientamento faccia
    func rotationForFace(index: Int) -> SCNVector3 {
        // Esempio per dado a 6 facce; adattare se il dado ha più facce
        switch index {
        case 0: return SCNVector3(0, 0, 0)
        case 1: return SCNVector3(-Float.pi/2, 0, 0)
        case 2: return SCNVector3(Float.pi/2, 0, 0)
        case 3: return SCNVector3(0, -Float.pi/2, 0)
        case 4: return SCNVector3(0, Float.pi/2, 0)
        case 5: return SCNVector3(Float.pi, 0, 0)
        default: return SCNVector3(0, 0, 0)
        }
    }
}

