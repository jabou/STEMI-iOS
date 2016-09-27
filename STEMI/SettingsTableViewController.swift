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
    @IBOutlet weak var resetCell: UITableViewCell!

    //MARK: - Variables
    var stemi: Hexapod!
    var calibrationValues = [50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50]
    var currentCalibrationValues = [Int]()

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
        } else if clickedCell == resetCell {
            resetCell.selected = false

            let backgroundView = UIView()
            let loadingLabel = UILabel()
            let activityIndicator = UIActivityIndicatorView()

            backgroundView.frame = CGRectMake(0, 0, 130, 130)
            backgroundView.center = view.center
            backgroundView.backgroundColor = UIColor(red: 39/255, green: 38/255, blue: 39/255, alpha: 0.9)
            backgroundView.clipsToBounds = true
            backgroundView.layer.cornerRadius = 10
            backgroundView.alpha = 0.0

            loadingLabel.frame = CGRectMake(0, 0, 130, 80)
            loadingLabel.backgroundColor = UIColor.clearColor()
            loadingLabel.textColor = UIColor.whiteColor()
            loadingLabel.adjustsFontSizeToFitWidth = true
            loadingLabel.textAlignment = NSTextAlignment.Center
            loadingLabel.center = CGPointMake(backgroundView.bounds.width/2, backgroundView.bounds.height/2 + 30)
            loadingLabel.text = Localization.localizedString("RESETING")

            activityIndicator.frame = CGRectMake(0, 0, activityIndicator.bounds.size.width, activityIndicator.bounds.size.height)
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            activityIndicator.center = CGPointMake(backgroundView.bounds.width/2, backgroundView.bounds.height/2 - 10)

            backgroundView.addSubview(activityIndicator)
            backgroundView.addSubview(loadingLabel)
            view.addSubview(backgroundView)
            
            activityIndicator.startAnimating()

            let warningMessage = UIAlertController(title: Localization.localizedString("WARNING"), message: Localization.localizedString("RESET_WARNIGN"), preferredStyle: .Alert)
            let yesButton = UIAlertAction(title: Localization.localizedString("YES"), style: .Destructive, handler: {action in

                backgroundView.alpha = 1.0

                dispatch_async(dispatch_get_main_queue(), { 
                    self._discardValuesToInitial({ completed in
                        activityIndicator.stopAnimating()
                        backgroundView.removeFromSuperview()
                    })
                })
            })
            let noButton = UIAlertAction(title: Localization.localizedString("NO"), style: .Cancel, handler: nil)
            warningMessage.addAction(yesButton)
            warningMessage.addAction(noButton)
            self.presentViewController(warningMessage, animated: true, completion: nil)
        }
    }

    //MARK: - Private functions

    private func _discardValuesToInitial(complete: (Bool) -> Void) {

        stemi = Hexapod(withCalibrationMode: true)
        stemi.setIP(UserDefaults.IP())
        stemi.connectWithCompletion({connected in
            if connected {
                let values = self.stemi.fetchDataFromHexapod()
                for value in values {
                    self.currentCalibrationValues.append(Int(value))
                }
                dispatch_async(dispatch_get_main_queue(), { 
                    self.discard({completion in
                        if completion {
                            complete(true)
                        }
                    })
                })
            }
        })
    }

    private func discard(complete: (Bool) -> Void) {

        var calculatingNumbers: [Int] = []

            for i in 0...20 {
                for (j, _) in self.currentCalibrationValues.enumerate() {

                    if i == 0 {
                        let calc = abs(self.calibrationValues[j] - self.currentCalibrationValues[j])/20
                        calculatingNumbers.append(calc)
                    }

                    if i < 20 {
                        if self.currentCalibrationValues[j] < self.calibrationValues[j] {
                            self.currentCalibrationValues[j] += calculatingNumbers[j]
                            do {
                                try self.stemi.setValue(UInt8(self.currentCalibrationValues[j]), atIndex: j)
                            } catch {
                                print("error")
                            }
                        } else if self.currentCalibrationValues[j] > self.calibrationValues[j] {
                            self.currentCalibrationValues[j] -= calculatingNumbers[j]
                            do {
                                try self.stemi.setValue(UInt8(self.currentCalibrationValues[j]), atIndex: j)
                            } catch {
                                print("error")
                            }
                        }
                    } else {
                        self.currentCalibrationValues[j] = self.calibrationValues[j]
                        do {
                            try self.stemi.setValue(UInt8(self.currentCalibrationValues[j]), atIndex: j)
                        } catch {
                            print("error")
                        }
                    }
                }
                NSThread.sleepForTimeInterval(0.2)
            }
            self.stemi.disconnect()
            self.stemi.writeDataToHexapod({ completed in
                if completed {
                    self.currentCalibrationValues = []
                    complete(true)
                }
            })

    }

}
