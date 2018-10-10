//
//  PointNode.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/20.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import Foundation
import SceneKit

class PointNode: SCNNode {
    
    convenience init(origin: SCNVector3) {
        self.init()
        
        self.position = origin
        createGeometry()
    }
    
    /// Create Geometry for the node
    private func createGeometry() {
        let r: CGFloat = 0.005
        let sphere = SCNSphere(radius: r)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        
        sphere.name = "point"
        sphere.firstMaterial = material
        sphere.segmentCount = 4
        
        self.geometry = sphere
    }
    
    private func updateGeometry() {
        
    }
}
