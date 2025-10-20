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
    @State private var diceWrapperNode = SCNNode()
    @State private var currentResultIndex: Int?
    let motionManager = CMMotionManager()
    @StateObject private var locationManager = LocationManager()

    @State private var navigateToRestaurants = false

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

            if let text = resultText {
                Text("È uscito: \(text.capitalized)")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Cerca ristoranti vicini") {
                    handleRestaurantNavigation()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            setupScene()
            startShakeDetection()
        }
        .onDisappear {
            motionManager.stopAccelerometerUpdates()
        }
        .navigationDestination(isPresented: $navigateToRestaurants) {
            if let text = resultText {
                RestaurantListView(food: text)
            } else {
                Text("Nessun risultato disponibile")
            }
        }
    }

    // MARK: - Permesso posizione + navigazione
    func handleRestaurantNavigation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestPermission()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                    navigateToRestaurants = true
                }
            }
        case .denied, .restricted:
            locationManager.requestPermission()
        default:
            navigateToRestaurants = true
        }
    }

    // MARK: - Scene setup e animazioni
    func setupScene() {
        scene = SCNScene()
        diceWrapperNode = SCNNode()
        scene.rootNode.addChildNode(diceWrapperNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4.5)
        scene.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(5, 5, 10)
        scene.rootNode.addChildNode(lightNode)

        if let diceScene = SCNScene(named: "Dungeons_And_Dragons_Dice_Set.scn") {
            let nodeName = "d\(die.sides)"
            if let loadedNode = diceScene.rootNode.childNode(withName: nodeName, recursively: true) {
                diceNode = loadedNode.clone()
                diceNode?.scale = SCNVector3(1.3, 1.3, 1.3)
                if let diceNode = diceNode {
                    centerDice(diceNode)
                    diceWrapperNode.addChildNode(diceNode)
                }
            }
        }
    }

    func centerDice(_ node: SCNNode) {
        var minVec = SCNVector3Zero
        var maxVec = SCNVector3Zero
        node.__getBoundingBoxMin(&minVec, max: &maxVec)
        let center = SCNVector3(
            (minVec.x + maxVec.x) / 2,
            (minVec.y + maxVec.y) / 2,
            (minVec.z + maxVec.z) / 2
        )
        node.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        node.position = SCNVector3Zero
    }

    func startDiceAnimation(durationMultiplier: Double = 1.0) {
        guard !isRolling, let _ = diceNode else { return }
        isRolling = true
        hasRolled = true

        let index = Int.random(in: 0..<die.sides)
        currentResultIndex = index
        let food = die.faceTexts[index].isEmpty ? "cibo \(index + 1)" : die.faceTexts[index]

        diceWrapperNode.position = SCNVector3Zero

        let randomX = Float.random(in: 0...Float.pi * 3)
        let randomY = Float.random(in: 0...Float.pi * 3)
        let finalRotation = SCNVector3(Float.pi/4 * Float(index), Float.pi/5 * Float(index), 0)

        let rotateSequence = SCNAction.sequence([
            SCNAction.rotateBy(x: CGFloat(randomX), y: CGFloat(randomY), z: 0, duration: 0.8 * durationMultiplier),
            SCNAction.rotateTo(x: CGFloat(finalRotation.x), y: CGFloat(finalRotation.y), z: CGFloat(finalRotation.z),
                               duration: 0.4 * durationMultiplier, usesShortestUnitArc: true)
        ])

        diceWrapperNode.runAction(rotateSequence)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 * durationMultiplier) {
            self.resultText = food
            self.isRolling = false
        }
    }

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
}
