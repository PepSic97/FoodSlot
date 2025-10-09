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
            
            SceneView(
                scene: scene,
                pointOfView: nil,
                options: [],
                preferredFramesPerSecond: 60,
                antialiasingMode: .multisampling4X
            )
            .frame(width: 250, height: 250)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !hasRolled else { return }
                startDiceAnimation()
            }
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
        // Crea una nuova scena vuota
        scene = SCNScene()
        
        // --- 📸 Camera ---
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = false
        scene.rootNode.addChildNode(cameraNode)
        
        // --- 💡 Luci ---
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 5, y: 5, z: 10)
        scene.rootNode.addChildNode(lightNode)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        // --- 🎲 Caricamento del dado dal file .scn ---
        if let diceScene = SCNScene(named: "Dungeons_And_Dragons_Dice_Set.scn") {
            // Nome nodo in base ai lati (es. "d6", "d20", ecc.)
            let nodeName = "d\(die.sides)"
            if let loadedNode = diceScene.rootNode.childNode(withName: nodeName, recursively: true) {
                diceNode = loadedNode.clone()
                diceNode?.position = SCNVector3(0, 0, 0)
                
                // --- 📏 Scala e posizione della camera in base al tipo di dado ---
                let (scale, cameraZ): (Float, Float)
                switch die.sides {
                case 4:
                    (scale, cameraZ) = (1.0, 3.5)
                case 6:
                    (scale, cameraZ) = (0.9, 3.8)
                case 8:
                    (scale, cameraZ) = (0.8, 4.0)
                case 10:
                    (scale, cameraZ) = (0.75, 4.2)
                case 12:
                    (scale, cameraZ) = (0.7, 4.5)
                case 20:
                    (scale, cameraZ) = (0.65, 4.8)
                default:
                    (scale, cameraZ) = (0.8, 4.0)
                }

                diceNode?.scale = SCNVector3(scale, scale, scale)
                cameraNode.position = SCNVector3(x: 0, y: 0, z: cameraZ)
                
                // Aggiungi il dado alla scena
                scene.rootNode.addChildNode(diceNode!)
            } else {
                print("⚠️ Nodo \(nodeName) non trovato nella scena SCN.")
            }
        } else {
            print("❌ Scena .scn non trovata nel bundle!")
        }
    }

    // MARK: - Animazione dado
    func startDiceAnimation(durationMultiplier: Double = 1.0) {
        guard !isRolling, let diceNode = diceNode else { return }
        isRolling = true
        hasRolled = true

        let index = Int.random(in: 0..<die.sides)
        currentResultIndex = index
        let text = die.faceTexts[index].isEmpty ? "Faccia \(index + 1)" : die.faceTexts[index]

        let randomX = Float.random(in: 0...Float.pi * 3)
        let randomY = Float.random(in: 0...Float.pi * 3)
        let finalRotation = rotationForFace(index: index, sides: die.sides)

        let rotateSequence = SCNAction.sequence([
            SCNAction.rotateBy(x: CGFloat(randomX), y: CGFloat(randomY), z: 0, duration: 0.8 * durationMultiplier),
            SCNAction.rotateTo(x: CGFloat(finalRotation.x),
                               y: CGFloat(finalRotation.y),
                               z: CGFloat(finalRotation.z),
                               duration: 0.4 * durationMultiplier,
                               usesShortestUnitArc: true)
        ])
        diceNode.runAction(rotateSequence)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3 * durationMultiplier) {
            self.applyTextOnTopFace(text)
            self.resultText = text
            self.saveResult(text)
            self.isRolling = false
        }
    }

    // MARK: - Shake detection
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
                            startDiceAnimation(durationMultiplier: 0.5)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Applicazione testo sulla faccia superiore
    func applyTextOnTopFace(_ text: String) {
        guard let diceNode = diceNode,
              let geometry = diceNode.geometry else { return }

        let topMaterial = SCNMaterial()
        topMaterial.diffuse.contents = imageFromText(text)
        topMaterial.isDoubleSided = true

        var materials = geometry.materials
        if materials.isEmpty {
            materials = Array(repeating: SCNMaterial(), count: die.sides)
        }

        let topIndex = topFaceIndex(for: die.sides)
        if topIndex < materials.count {
            materials[topIndex] = topMaterial
        }

        geometry.materials = materials
    }

    // MARK: - Calcolo faccia superiore
    func topFaceIndex(for sides: Int) -> Int {
        switch sides {
        case 4:  return 0  // tetraedro
        case 6:  return 2  // cubo
        case 8:  return 4  // octaedro
        case 10: return 5  // decaedro
        case 12: return 6  // dodecaedro
        case 20: return 10 // icosaedro
        default: return 0
        }
    }

    // MARK: - Genera immagine testo
    func imageFromText(_ text: String) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 50),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black
        ]
        let rect = CGRect(x: 0, y: (size.height - 60)/2, width: size.width, height: 60)
        text.draw(in: rect, withAttributes: attrs)

        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }

    // MARK: - Salvataggio risultato
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

    // MARK: - Rotazioni realistiche per tutti i dadi
    func rotationForFace(index: Int, sides: Int) -> SCNVector3 {
        switch sides {

        // ---- D4 (tetraedro)
        case 4:
            let rotations: [SCNVector3] = [
                SCNVector3(0, 0, 0),
                SCNVector3(Float.pi/2, 0, 0),
                SCNVector3(0, Float.pi/2, 0),
                SCNVector3(-Float.pi/2, 0, 0)
            ]
            return rotations[index % 4]

        // ---- D6 (cubo)
        case 6:
            let rotations: [SCNVector3] = [
                SCNVector3(0, 0, 0),
                SCNVector3(-Float.pi/2, 0, 0),
                SCNVector3(Float.pi/2, 0, 0),
                SCNVector3(0, -Float.pi/2, 0),
                SCNVector3(0, Float.pi/2, 0),
                SCNVector3(Float.pi, 0, 0)
            ]
            return rotations[index % 6]

        // ---- D8 (octaedro)
        case 8:
            let rotations: [SCNVector3] = [
                SCNVector3(0, 0, 0),
                SCNVector3(Float.pi/4, 0, 0),
                SCNVector3(-Float.pi/4, 0, 0),
                SCNVector3(0, Float.pi/4, 0),
                SCNVector3(0, -Float.pi/4, 0),
                SCNVector3(Float.pi/4, Float.pi/4, 0),
                SCNVector3(-Float.pi/4, -Float.pi/4, 0),
                SCNVector3(Float.pi/2, 0, 0)
            ]
            return rotations[index % 8]

        // ---- D10 (decaedro)
        case 10:
            let rotations: [SCNVector3] = (0..<10).map { i in
                SCNVector3(Float.pi * Float(i) / 5, Float.pi / 5, 0)
            }
            return rotations[index % 10]

        // ---- D12 (dodecaedro)
        case 12:
            let rotations: [SCNVector3] = (0..<12).map { i in
                SCNVector3(Float.pi * Float(i) / 6, Float.pi / 3, 0)
            }
            return rotations[index % 12]

        // ---- D20 (icosaedro)
        case 20:
            let rotations: [SCNVector3] = (0..<20).map { i in
                SCNVector3(Float.pi * Float(i) / 10, Float.pi / 5, 0)
            }
            return rotations[index % 20]

        default:
            return SCNVector3(0, 0, 0)
        }
    }
}

