//
//  SelectionTableViewController.swift
//  PointCloudCapture
//
//  Created by Haruya Ishikawa on 2018/03/26.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import UIKit

class PointCloudCell: UITableViewCell {
    
    static let reuseIdentifier = "PointCloudCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var name = "" {
        didSet {
            titleLabel.text = name
        }
    }
    
}

protocol SelectionTableViewControllerDelegate: class {
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, selected cloud: PointCloud)
}

class SelectionTableViewController: UITableViewController {
    
    var clouds = [PointCloud]()
    
    weak var delegate: SelectionTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 300, height: 250)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cloud = clouds[indexPath.row]
        dismiss(animated: false, completion: nil)
        // Check if the current row is already selected, then deselect it.
        delegate?.selectionTableViewController(self, selected: cloud)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clouds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PointCloudCell.reuseIdentifier, for: indexPath) as? PointCloudCell else {
            fatalError("Expected `\(PointCloudCell.self)` type for reuseIdentifier \(PointCloudCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        cell.name = clouds[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
    
}
