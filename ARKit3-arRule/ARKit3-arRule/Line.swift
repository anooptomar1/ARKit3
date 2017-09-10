//
//  Line.swift
//  ARKit3-arRule
//
//  Created by 刘文 on 2017/9/8.
//  Copyright © 2017年 刘文. All rights reserved.
//

import ARKit

enum DistanceUnit {
    case meter, centimeter, inch
    
    var factor: Float{
        switch self {
        case .meter:
            return 1.0
        case .centimeter:
            return 100.0
        case .inch:
            return 39.3700787
        }
    }
    
    var name: String {
        switch self {
        case .meter:
            return "m"
        case .centimeter:
            return "cm"
        case .inch:
            return "inch"
        }
    }
    
    func next() -> DistanceUnit {
        switch self {
        case .meter:
            return .centimeter
        case .centimeter:
            return .inch
        case .inch:
            return .meter
        }
    }
}

class Line {

    private let startVector: SCNVector3
    private var endVector: SCNVector3 = SCNVector3()
    
    private let sceneView: ARSCNView
    private var startNode: SCNNode
    private var endNode: SCNNode
    private var textNode: SCNNode
    private var text: SCNText
    private var lineNode: SCNNode?
    
    var unit: DistanceUnit
    var color = UIColor.orange
    
    // 获取该线的距离
    var distance: String? {
        let distanceX = startVector.x - endVector.x
        let distanceY = startVector.y - endVector.y
        let distanceZ = startVector.z - endVector.z
        let value = sqrt((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
        
        return String(format:"%0.2f %@", value*unit.factor, unit.name)
    }
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        // 创建起点与终点节点
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant // 不产生阴影
        dot.firstMaterial?.isDoubleSided = true // 正反两面都抛光
        
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        // 线条与终点节点 都在 确定好endVector后添加进场景中
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)
        
        // 文字过度节点的 几何形
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant
        text.firstMaterial?.isDoubleSided = true
        text.alignmentMode = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        
        // 文字过度节点，因为要让文字始终面向屏幕中心
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        
        // 添加约束
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    // 随着线的终点改变，更新线
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        
        endVector = vector
        
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        // 文字节点
        text.string = distance
        textNode.position = SCNVector3((startVector.x + vector.x) / 2.0 , (startVector.y + vector.y) / 2.0 ,(startVector.z + vector.z) / 2.0 )
        
        endNode.position = vector
        if endNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(endNode)
        }
    }
    
    // 移除所有节点
    func remove() {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }
    
}
