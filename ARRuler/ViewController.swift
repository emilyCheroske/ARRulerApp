//
//  ViewController.swift
//  ARRuler
//
//  Created by Emily Cheroske on 10/22/19.
//  Copyright © 2019 Emily Cheroske. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var yValue : Float = 0
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        addLight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            textNode.removeFromParentNode()
            dotNodes.removeAll()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addLight() {
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 0
        directionalLight.castsShadow = true
        directionalLight.shadowMode = .deferred
        directionalLight.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        directionalLight.shadowSampleCount = 10
        
        let directionalLightNode = SCNNode()
        directionalLightNode.light = directionalLight
        directionalLightNode.rotation = SCNVector4Make(1, 0, 0, -Float.pi / 3)
        
        sceneView.scene.rootNode.addChildNode(directionalLightNode)
    }
    
    func addDot(at hitresult : ARHitTestResult) {
        var dot = SCNSphere(radius: 0.03)
        
        var material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIImage(named: "art.scnassets/Wood_wicker_003_basecolor.jpg")
        material.normal.contents = UIImage(named: "art.scnassets/Wood_wicker_003_normal.jpg")
        material.normal.intensity = 0.5
        material.metalness.contents = 1.0
        
        dot.materials = [material]
        
        let dotNode = SCNNode(geometry: dot)
        
        dotNode.position = SCNVector3(hitresult.worldTransform.columns.3.x, hitresult.worldTransform.columns.3.y, hitresult.worldTransform.columns.3.z)
                
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if(dotNodes.count >= 2) {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let xDiff = end.position.x - start.position.x
        let yDiff = end.position.y - start.position.y
        let zDiff = end.position.z - start.position.z
        
        let x2 = pow(xDiff, 2)
        let y2 = pow(yDiff, 2)
        let z2 = pow(zDiff, 2)
        
        let distance = abs(sqrt(x2 + y2 + z2))
        
        let textPosition = SCNVector3(x: start.position.x, y: start.position.y + yDiff/2, z: start.position.z + zDiff/2)
        
        updateText(text : "Distance: \(distance)", atPosition: textPosition)
    }
    
    func updateText(text : String, atPosition: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textGeometry.firstMaterial?.lightingModel = .physicallyBased
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(x: atPosition.x, y: atPosition.y, z: atPosition.z)
        
        textNode.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
