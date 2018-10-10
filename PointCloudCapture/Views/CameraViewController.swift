//
//  ViewController.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/20.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class CameraViewController: UIViewController {

    
    // MARK: - UI Elements:
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var pointsSwitch: UISwitch!
    @IBOutlet weak var framesSwitch: UISwitch!
    
    // MARK: - Variables:
    let initialPointClouds = ["bun_zipper_points", "dragon_hidden"]
    var pointClouds = [PointCloud]()
    var currentCloud: PointCloud?
    var selectedCloud: PointCloud?
    
    var isRecording: Bool = false
    
    
    var startTime: TimeInterval?
    var acquisitionInterval: TimeInterval = 0.5
    var acquisitionTime: TimeInterval = 0.5
    
    // Point Cloud:
    var frameInterval: TimeInterval = 2
    var frameTime: TimeInterval = 2
    var frameArray = [ARFrame]()
    
    // MARK: - Override Functions:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePointClouds()  // initialize pointClouds data when ply files exists in documents
        setupSceneView()  // setup sceneView
        
//        setupView()  // initial setup
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let config = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    // MARK: - Functions:
    
    private func setupSceneView() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Debug options
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let session = ARSession()
        session.delegate = self
        sceneView.session = session
    }
    
//    private func setupView() {
//
//    }
//
    @IBAction func tappedRecordButton(_ sender: UIButton) {
        if isRecording {
            // Goes in when stopping record:
            toolButton(isEnabled: true)
            isRecording = false
            sender.setTitle("Start", for: .normal)
            sender.setTitleColor(.white, for: .normal)
            
            // save point cloud to ply file
            guard let cloud = currentCloud else {
                print("not current cloud")
                return
            }
            
            cloud.saveToPLY()
            pointClouds.append(cloud)
            
            // FIXME: will currentCloud go nil before saving all of the points?
            currentCloud = nil
            
            print(frameArray.count)
        } else {
            // Goes in when starting to record:
            toolButton(isEnabled: false)
            isRecording = true
            startTime = Date.timeIntervalSinceReferenceDate
            sender.setTitle("Stop", for: .normal)
            sender.setTitleColor(.red, for: .normal)
            
            // initialize the currentCloud
            let name = createName()
            let fileName = name + ".ply"  // not the correct way of doing this
            currentCloud = PointCloud(file: fileName)
        }
    }
    
    
    func toolButton(isEnabled: Bool) {
        previewButton.isEnabled = isEnabled
    }
    
    private func initializePointClouds() {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // TODO: will remove
            // Copy the ply files to documents directory
            for file in initialPointClouds {
                if let url = Bundle.main.url(forResource: file, withExtension: "ply") {
                    let documentURL = documentsURL.appendingPathComponent(file).appendingPathExtension("ply")
                    if !fileManager.fileExists(atPath: documentURL.path) {
                        try fileManager.copyItem(at: url, to: documentURL)
                    }
                }
            }
            
            // Get the contents for the directory
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            // Create/initialize PointClouds from fileURLs and append them to the array
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                if fileURL.pathExtension == "ply" {
                    let pc = PointCloud(file: fileName)
                    pointClouds.append(pc)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func savePoints() {
        let session = self.sceneView.session
        guard let pointCloud = session.currentFrame?.rawFeaturePoints else { return }
        DispatchQueue.global(qos: .background).async {
            let count = pointCloud.identifiers.count
            
            for i in 0..<count {
                let id = pointCloud.identifiers[i]
                let point = pointCloud.points[i]
                let vec = SCNVector3Make(point.x, point.y, point.z)
                
                self.currentCloud?.savePoint(identifier: id, vector: vec)
            }
        }
    }
    
    public func saveFrame() {
        guard let currentFrame = sceneView.session.currentFrame else { return }
        let frame: ARFrame = currentFrame.copy() as! ARFrame
        frameArray.append(frame)
    }
    
    private func createName() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSSS"
        let fileName = formatter.string(from: now)
        return fileName
    }
    
    func printTimeInterval() {
        guard let initial = startTime else { return }
        let time = Date.timeIntervalSinceReferenceDate
        print(time - initial)
    }
}
