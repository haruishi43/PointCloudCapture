//
//  PointCloudData.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/21.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import ARKit
import Metal  // might not need...

class PointCloud: NSObject {
    
    var file: String = ""
    var name: String = ""
    var n : Int = 0
    var pointCloud : Array<SCNVector3> = []
    var maxId: UInt64 = 0
    
    init(file: String) {
        self.file = file
        self.name = file.components(separatedBy: ".")[0]  // get the string before '.'
    }
    
    public func openDataSource() -> Bool {
        // change this to completion based method?
        self.n = 0
        var x, y, z : Double
        (x,y,z) = (0,0,0)
        
        // Open file
        let fileManager = FileManager.default
        
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let documentURL = documentsURL.appendingPathComponent(file)
            
            if fileManager.fileExists(atPath: documentURL.path) {
                let data = try String(contentsOfFile: documentURL.path, encoding: .ascii)
                var lines = data.components(separatedBy: "\n")
                
                // Read header
                while !lines.isEmpty {
                    let line = lines.removeFirst()
                    if line.hasPrefix("element vertex ") {
                        n = Int(line.components(separatedBy: " ")[2])!
                        continue
                    }
                    if line.hasPrefix("end_header") {
                        break
                    }
                }
                
                pointCloud = Array<SCNVector3>(repeating: SCNVector3(x:0,y:0,z:0), count: n)
                
                // Read data
                for i in 0...(self.n-1) {
                    let line = lines[i]
                    x = Double(line.components(separatedBy: " ")[0])!
                    y = Double(line.components(separatedBy: " ")[1])!
                    z = Double(line.components(separatedBy: " ")[2])!
                    
                    pointCloud[i].x = Float(x)
                    pointCloud[i].y = Float(y)
                    pointCloud[i].z = Float(z)
                }
                print("Point cloud data loaded: \(n) points")
            } else {
                print("file doesn't exists")
                return false
            }
            
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    public func saveToPLY() {
        let n: Int = pointCloud.count
        
        if pointCloud.isEmpty {
            print("no point clouds")
            return
        }
        let fileManager = FileManager.default
        
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let documentURL = documentsURL.appendingPathComponent(file)
            
            var data = String()
            
            let header = """
            ply
            format ascii 1.0
            comment VCGLIB generated
            element vertex \(n)
            property float x
            property float y
            property float z
            element face 0
            property list uchar int vertex_indices
            end_header
            
            """
            
            data = header
            for point in pointCloud {
                let line = """
                \(point.x) \(point.y) \(point.z)
                
                """
                data = data + line
            }
            
            // If file already exists at path, remove the file first
            if fileManager.fileExists(atPath: documentURL.path) {
                try fileManager.removeItem(atPath: documentURL.path)
            }
            
            // Write to document (ply file)
            try data.write(to: documentURL, atomically: false, encoding: .ascii)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func savePoint(identifier: UInt64, vector: SCNVector3) {
        if identifier > maxId {
            pointCloud.append(vector)
            maxId = identifier  // Increment the largest identifier
        }
    }
    
    public func getNode() -> SCNNode {
        let points = self.pointCloud
        var vertices = Array(repeating: PointCloudVertex(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0), count: points.count)
        
        for i in 0...(points.count - 1) {
            let p = points[i]
            vertices[i].x = Float(p.x)
            vertices[i].y = Float(p.y)
            vertices[i].z = Float(p.z)
            vertices[i].r = Float(0.0)
            vertices[i].g = Float(1.0)
            vertices[i].b = Float(1.0)
        }
        
        let node = buildNode(points: vertices)
        //print(String(describing: node))
        return node
    }
    
    private func buildNode(points: [PointCloudVertex]) -> SCNNode {
        let vertexData = NSData(
            bytes: points,
            length: MemoryLayout<PointCloudVertex>.size * points.count
        )
        
        let positionSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.vertex,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        
        let colorSource = SCNGeometrySource(
            data: vertexData as Data,
            semantic: SCNGeometrySource.Semantic.color,
            vectorCount: points.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: MemoryLayout<Float>.size * 3,
            dataStride: MemoryLayout<PointCloudVertex>.size
        )
        
        let elements = SCNGeometryElement(
            data: nil,
            primitiveType: .point,
            primitiveCount: points.count,
            bytesPerIndex: MemoryLayout<Int>.size
        )
        
        let pointsGeometry = SCNGeometry(sources: [positionSource, colorSource], elements: [elements])
        
        return SCNNode(geometry: pointsGeometry)
    }
    
}
