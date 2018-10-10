//
//  ViewController+ARSCNViewDelegate.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/20.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

extension CameraViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // renderer for update at a frame
        
        if isRecording {
            if time > acquisitionTime {
                acquisitionTime =  time + acquisitionInterval
                savePoints()
            }
            
            if time > frameTime {
                frameTime = time + frameInterval
                saveFrame()
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
    
    func spawnNode() {
        let session = self.sceneView.session
        
        guard let pointCloud = session.currentFrame?.rawFeaturePoints else { return }
        
        DispatchQueue.global(qos: .background).async {
            for point in pointCloud.points {
                
                let node = PointNode(origin: SCNVector3Make(point.x, point.y, point.z))
                
                self.sceneView.scene.rootNode.addChildNode(node)
                
            }
        }
        
        print(">>>>>>>>")
        print(pointCloud.identifiers.count)
        print(pointCloud.points.count)
    }
}
