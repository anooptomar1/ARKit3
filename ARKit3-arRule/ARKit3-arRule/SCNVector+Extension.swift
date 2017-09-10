//
//  SCNVector+Extension.swift
//  ARKit3-arRule
//
//  Created by 刘文 on 2017/9/8.
//  Copyright © 2017年 刘文. All rights reserved.
//

import ARKit

extension SCNVector3 {
    
    // 点与点之间划线
    func line(to vector: SCNVector3, color: UIColor) -> SCNNode {
        let indices: [UInt32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [self, vector])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode(geometry: geometry)
        return node
    }
}

extension SCNVector3: Equatable {
    
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}

