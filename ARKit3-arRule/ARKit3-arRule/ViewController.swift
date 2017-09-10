//
//  ViewController.swift
//  ARKit3-arRule
//
//  Created by 刘文 on 2017/9/8.
//  Copyright © 2017年 刘文. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var targetImageView: UIImageView!
    
    var isMeasuring = false // 是否正在测量
    
    var vectorZero = SCNVector3() // 0,0,0
    var vectorStart = SCNVector3()
    var vectorEnd = SCNVector3()
    
    var lines = [Line]()
    var currentLine: Line?
    var unit = DistanceUnit.centimeter // 單位默認公分 cm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        infoLabel.text = "loading..."
    }
    
    @IBAction func resetButtonHandler(_ sender: UIButton) {
        
        for line in lines {
            line.remove()
        }
        lines.removeAll()
    }
    
    @IBAction func unitButtonHandler(_ sender: UIButton) {
        unit = unit.next()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMeasuring {
            // 开始测量
            isMeasuring = true
            targetImageView.image = UIImage(named: "GreenTarget")
            
            vectorStart = SCNVector3()
            vectorEnd = SCNVector3()
        } else {
            // 测量结束
            isMeasuring = false
            
            if let line = currentLine {
                lines.append(line)
                currentLine = nil
                targetImageView.image = UIImage(named: "WhiteTarget")
            }
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking,.removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.pause()
    }
    
    func scanWorld() {
        // 获取屏幕中心点对应相机追踪真实世界中事物所在的位置
        let point = view.center
        let results = sceneView.hitTest(point, types: [.featurePoint])
        guard let result = results.first else {
            return
        }
        let transform = result.worldTransform
        let worldPosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        
        if lines.isEmpty {
            infoLabel.text = "try to click the screen!"
        }
        
        if isMeasuring {
            // 确定线的起点，创建线条
            if vectorStart == vectorZero {
                vectorStart = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: vectorStart, unit: unit)
            }
            
            // 更新线条
            currentLine?.update(to: worldPosition)
            infoLabel.text = currentLine?.distance ?? "update line..."
        }
    }
    
}

// MARK: ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    //
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.scanWorld()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        infoLabel.text = "error!"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        infoLabel.text = "interrupt!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        infoLabel.text = "end!"
    }
    
}

