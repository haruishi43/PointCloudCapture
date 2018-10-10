//
//  PreviewViewController.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/26.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import SceneKit

class PreviewViewController: UIViewController {
    
    // MARK: - UI Related Elements:
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // MARK: - Variables:
    var pointCloud: PointCloud?
    
    // MARK: - IBActions:
    @IBAction func tappedDoneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // loading the pointcloud
        guard let pc = pointCloud else {
            print("point cloud could not be loaded")
            // Dismiss the view automatically when point clouds could not be loaded
            dismiss(animated: true, completion: nil)
            return
        }
        
        if pc.pointCloud.isEmpty {
            if !pc.openDataSource() {
                print("FAILURE!!")
                dismiss(animated: true, completion: nil)
                return
            }
        }
        
        let pcNode = pc.getNode()
        pcNode.position = SCNVector3(x: 0, y: -0.1, z: 0)
        sceneView.scene?.rootNode.addChildNode(pcNode)
        
        // animate node (spin around y axis)
        //pcNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        
        indicator.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Start running the indicator
        indicator.startAnimating()
    }
    
    override func viewDidLoad() {
        
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showWireframe
        
        // configure the view
        sceneView.backgroundColor = UIColor.darkGray
        
        // create a new scene
        let scene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 1.0
        cameraNode.camera?.zFar = 100.0
        //scene.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0.3)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 3, z: 3)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        sceneView.scene = scene
    }
    
}
