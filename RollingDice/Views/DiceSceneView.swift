//
//  DiceSceneView.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SwiftUI
import SceneKit

struct DiceSceneView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        if let scene = SCNScene(named: "Dungeons_And_Dragons_Dice_Set.scn") {
            sceneView.scene = scene
            sceneView.allowsCameraControl = true
            sceneView.autoenablesDefaultLighting = true
            sceneView.backgroundColor = .black
            if scene.rootNode.childNode(withName: "camera", recursively: true) == nil {
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                cameraNode.position = SCNVector3(0, 0, 10)
                scene.rootNode.addChildNode(cameraNode)
            }
        } else {
            print("❌ Errore: scena non trovata")
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}
