//
//  ViewController.swift
//  STry4
//
//  Created by elaine on 2020/4/14.
//  Copyright © 2020 yuri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var lblMessage: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {
    return
    }
    let touch = sender.location(in: sceneView)
    let hitTestResults = sceneView.hitTest(touch, types: [.featurePoint, .estimatedHorizontalPlane])
    if hitTestResults.isEmpty == false {
    if let hitTestResult = hitTestResults.first {
    let virtualAnchor = ARAnchor(transform: hitTestResult.worldTransform)
        self.sceneView.session.add(anchor: virtualAnchor)
    } }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if anchor is ARPlaneAnchor { return
    }
    let newNode = SCNNode(geometry: SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0))
        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.addChildNode(newNode)
        }

    
    func saveMap(){
        self.sceneView.session.getCurrentWorldMap { worldMap, error in
        if error != nil { print(error?.localizedDescription ?? "Unknown error")
        return
        }
        if let map = worldMap {
        let data = try! NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                        // save in user defaults database
        let savedMap = UserDefaults.standard
            savedMap.set(data, forKey: "worldmap")
            savedMap.synchronize()
            DispatchQueue.main.async {
                self.lblMessage.text = "World map saved" }
        }
            
        }
        
    }
    
    func loadMap() {
    let storedData = UserDefaults.standard
    if let data = storedData.data(forKey: "worldmap") {
    if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: data), let worldMap = unarchived as? ARWorldMap {
    let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        configuration.planeDetection = .horizontal
        self.lblMessage.text = "Previous world map loaded"
        sceneView.session.run(configuration)
    }
    } else {
    let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    } }
    
    
    func clearMap() {
    let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.lblMessage.text = "Tap to place a virtual object"
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
    let options: ARSession.RunOptions = [.resetTracking,.removeExistingAnchors]
    sceneView.session.run(configuration, options: options)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        saveMap()
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        clearMap()
    }
    @IBAction func loadButton(_ sender: UIButton) {
        loadMap()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        configuration.planeDetection = .horizontal
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
       self.lblMessage.text = "Tap to place a virtual object"
       sceneView.session.run(configuration)
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
