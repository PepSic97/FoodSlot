//
//  DiceGeometry.swift
//  RollingDice
//
//  Created by Giuseppe Sica on 09/10/25.
//

import SceneKit
import UIKit

func geometryForDie(sides: Int, faceTexts: [String]) -> SCNGeometry {
    switch sides {
    case 4:
        return createTetrahedronGeometry(faceTexts: faceTexts)
    case 6:
        let box = SCNBox(width: 1.3, height: 1.3, length: 1.3, chamferRadius: 0.1)
        box.materials = createMaterials(for: faceTexts, faceCount: 6)
        return box
    case 8:
        return createOctahedronGeometry(faceTexts: faceTexts)
    case 10:
        return createPentagonalBipyramidGeometry(faceTexts: faceTexts)
    case 12:
        return createDodecahedronGeometry(faceTexts: faceTexts)
    case 20:
        return createIcosahedronGeometry(faceTexts: faceTexts)
    default:
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.materials = createMaterials(for: faceTexts, faceCount: 6)
        return box
    }
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

func createMaterials(for texts: [String], faceCount: Int) -> [SCNMaterial] {
    var materials: [SCNMaterial] = []
    for i in 0..<faceCount {
        let mat = SCNMaterial()
        let txt = texts.indices.contains(i) ? texts[i] : "F\(i+1)"
        mat.diffuse.contents = imageFromText(txt)
        materials.append(mat)
    }
    return materials
}

// MARK: - D4 (tetraedro)

func createTetrahedronGeometry(faceTexts: [String]) -> SCNGeometry {
    let sqrt2over3 = sqrt(2.0) / 3.0
    let sqrt6over3 = sqrt(6.0) / 3.0

    let vertices: [SCNVector3] = [
        SCNVector3(0, 0, 1),
        SCNVector3(2*sqrt2over3, 0, -1.0/3.0),
        SCNVector3(-sqrt2over3, sqrt6over3, -1.0/3.0),
        SCNVector3(-sqrt2over3, -sqrt6over3, -1.0/3.0)
    ]

    let indices: [Int32] = [
        0,1,2,
        0,3,1,
        0,2,3,
        1,3,2
    ]

    return createGeometry(vertices: vertices, indices: indices, faceTexts: faceTexts, faceCount: 4)
}

// MARK: - D8 (ottaedro)

func createOctahedronGeometry(faceTexts: [String]) -> SCNGeometry {
    return createPlaceholderGeometry(faceCount: 8, faceTexts: faceTexts)
}

// MARK: - D10 (bipiramide pentagonale)

func createPentagonalBipyramidGeometry(faceTexts: [String]) -> SCNGeometry {
    return createPlaceholderGeometry(faceCount: 10, faceTexts: faceTexts)
}

// MARK: - D12 (dodecaedro)

func createDodecahedronGeometry(faceTexts: [String]) -> SCNGeometry {
    return createPlaceholderGeometry(faceCount: 12, faceTexts: faceTexts)
}

// MARK: - D20 (icosaedro)

func createIcosahedronGeometry(faceTexts: [String]) -> SCNGeometry {
    return createPlaceholderGeometry(faceCount: 20, faceTexts: faceTexts)
}

// MARK: - Helpers

func createGeometry(vertices: [SCNVector3], indices: [Int32], faceTexts: [String], faceCount: Int) -> SCNGeometry {
    let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<SCNVector3>.size)
    let vertexSource = SCNGeometrySource(data: vertexData,
                                         semantic: .vertex,
                                         vectorCount: vertices.count,
                                         usesFloatComponents: true,
                                         componentsPerVector: 3,
                                         bytesPerComponent: MemoryLayout<Float>.size,
                                         dataOffset: 0,
                                         dataStride: MemoryLayout<SCNVector3>.size)

    let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int32>.size)
    let element = SCNGeometryElement(data: indexData,
                                     primitiveType: .triangles,
                                     primitiveCount: indices.count / 3,
                                     bytesPerIndex: MemoryLayout<Int32>.size)

    let geom = SCNGeometry(sources: [vertexSource], elements: [element])
    geom.materials = createMaterials(for: faceTexts, faceCount: faceCount)
    return geom
}

func createPlaceholderGeometry(faceCount: Int, faceTexts: [String]) -> SCNGeometry {
    let sphere = SCNSphere(radius: 1.0)
    sphere.materials = createMaterials(for: faceTexts, faceCount: faceCount)
    return sphere
}
