//
//  SettingsTableViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var IPAddress: UILabel!
    @IBOutlet weak var ipCell: UITableViewCell!
    @IBOutlet weak var stemiName: UILabel!
    @IBOutlet weak var hardwareVersion: UILabel!


    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        IPAddress.text = UserDefaults.IP()
        stemiName.text = UserDefaults.stemiName()
        hardwareVersion.text = UserDefaults.hardwareVersion()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.9)
    }

    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
        cell.selectedBackgroundView = backgroundView
        if cell.tag == 1 {
            cell.accessoryView = UIImageView(image: UIImage(named: "right_arrow"))
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let clickedCell = tableView.cellForRowAtIndexPath(indexPath)
        if clickedCell == ipCell {
            self.presentViewController(ViewControllers.ChangeIPViewController, animated: true, completion: nil)
        }
    }

}
