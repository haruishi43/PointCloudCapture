//
//  CameraViewController+Delegation.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/26.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit

extension CameraViewController: UIPopoverPresentationControllerDelegate {
    
    enum SegueIdentifier: String {
        case showTableView
        case showPreview
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else { return }
        
        let vc = segue.destination
        
        switch segueIdentifier {
        case .showTableView:
            vc.preferredContentSize = CGSize(width: 300, height: 250)
            vc.modalPresentationStyle = .popover
            if let popoverController = vc.popoverPresentationController, let button = sender as? UIButton {
                // Pop over the button layout
                popoverController.delegate = self
                popoverController.sourceView = button
                popoverController.sourceRect = button.bounds
                popoverController.permittedArrowDirections = .right
            }
            
            // tableView setup
            let tableViewController = vc as! SelectionTableViewController
            tableViewController.clouds = pointClouds
            tableViewController.delegate = self
        case .showPreview:
            
            let vc = segue.destination
            vc.modalPresentationStyle = .fullScreen
            
            let previewViewController = vc as! PreviewViewController
            previewViewController.pointCloud = selectedCloud
            selectedCloud = nil
        }
        
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("dismissed")
    }
}

extension CameraViewController: SelectionTableViewControllerDelegate {
    
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, selected cloud: PointCloud) {
        
        selectedCloud = cloud
        self.performSegue(withIdentifier: SegueIdentifier.showPreview.rawValue, sender: nil)
    }
}
