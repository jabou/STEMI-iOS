//
//  WalkingStylesTableViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 06/09/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class WalkingStylesTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet var walkingCells: [UITableViewCell]!

    //MARK: - Private variables
    private var _preselectedStyle: Int!
    private var _parentVC: WalkingStyleViewController!

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _parentVC = self.parentViewController as! WalkingStyleViewController
        _preselectedStyle = _parentVC.walkingStyle.hashValue

    }

    //MARK: - Table view data source
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.9)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
        cell.selectedBackgroundView = backgroundView
        cell.accessoryView = UIImageView(image: UIImage(named: "checkmark"))
        if cell.tag == walkingCells[_preselectedStyle].tag {
            cell.accessoryView?.hidden = false
        } else {
            cell.accessoryView?.hidden = true
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            _parentVC.selectedStyleWithId(cell.tag)
            if let accesory = cell.accessoryView {
                if accesory.hidden {
                    for walkingCell in walkingCells {
                        if walkingCell.tag == cell.tag {
                            walkingCell.accessoryView?.hidden = false
                        } else {
                            walkingCell.accessoryView?.hidden = true
                        }
                    }
                }
            }
        }
    }


}
