//
//  SettingsTableViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit
import STEMIHexapod

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        IPAddress.text = UserDefaults.IP()
        stemiName.text = UserDefaults.stemiName()
        hardwareVersion.text = UserDefaults.hardwareVersion()

    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.9)
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 36/255, green: 168/255, blue: 224/255, alpha: 0.6)
        cell.selectedBackgroundView = backgroundView
        if cell.tag == 1 {
            cell.accessoryView = UIImageView(image: UIImage(named: "right_arrow"))
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCell = tableView.cellForRow(at: indexPath)
        if clickedCell == ipCell {
            self.present(ViewControllers.ChangeIPViewController, animated: true, completion: nil)
        } else if clickedCell == resetCell {
            resetCell.isSelected = false

            let backgroundView = UIView()
            let loadingLabel = UILabel()
            let activityIndicator = UIActivityIndicatorView()

            backgroundView.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
            backgroundView.center = view.center
            backgroundView.backgroundColor = UIColor(red: 39/255, green: 38/255, blue: 39/255, alpha: 0.9)
            backgroundView.clipsToBounds = true
            backgroundView.layer.cornerRadius = 10
            backgroundView.alpha = 0.0

            loadingLabel.frame = CGRect(x: 0, y: 0, width: 130, height: 80)
            loadingLabel.backgroundColor = UIColor.clear
            loadingLabel.textColor = UIColor.white
            loadingLabel.adjustsFontSizeToFitWidth = true
            loadingLabel.textAlignment = NSTextAlignment.center
            loadingLabel.center = CGPoint(x: backgroundView.bounds.width/2, y: backgroundView.bounds.height/2 + 30)
            loadingLabel.text = Localization.localizedString("RESETING")

            activityIndicator.frame = CGRect(x: 0, y: 0, width: activityIndicator.bounds.size.width, height: activityIndicator.bounds.size.height)
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.center = CGPoint(x: backgroundView.bounds.width/2, y: backgroundView.bounds.height/2 - 10)

            backgroundView.addSubview(activityIndicator)
            backgroundView.addSubview(loadingLabel)
            view.addSubview(backgroundView)
            
            activityIndicator.startAnimating()

            let warningMessage = UIAlertController(title: Localization.localizedString("WARNING"), message: Localization.localizedString("RESET_WARNIGN"), preferredStyle: .alert)
            let yesButton = UIAlertAction(title: Localization.localizedString("YES"), style: .destructive, handler: {action in

                backgroundView.alpha = 1.0

                DispatchQueue.main.async(execute: { 
                    self._discardValuesToInitial({ completed in
                        activityIndicator.stopAnimating()
                        backgroundView.removeFromSuperview()
                    })
                })
            })
            let noButton = UIAlertAction(title: Localization.localizedString("NO"), style: .cancel, handler: nil)
            warningMessage.addAction(yesButton)
            warningMessage.addAction(noButton)
            self.present(warningMessage, animated: true, completion: nil)
        }
    }

    //MARK: - Private functions

    fileprivate func _discardValuesToInitial(_ complete: @escaping (Bool) -> Void) {

        stemi = Hexapod(withCalibrationMode: true)
        stemi.setIP(UserDefaults.IP())
        stemi.connectWithCompletion({connected in
            if connected {
                let values = self.stemi.fetchDataFromHexapod()
                for value in values {
                    self.currentCalibrationValues.append(Int(value))
                }

                DispatchQueue.main.async(execute: {
                    self.discard({completion in
                        if completion {
                            complete(true)
                        }
                    })
                })
            }
        })
    }

    fileprivate func discard(_ complete: @escaping (Bool) -> Void) {

        var calculatingNumbers: [Int] = []

            for i in 0...10 {
                for (j, _) in self.currentCalibrationValues.enumerated() {

                    if i == 0 {
                        let calc = abs(self.calibrationValues[j] - self.currentCalibrationValues[j])/20
                        calculatingNumbers.append(calc)
                    }

                    if i < 10 {
                        if self.currentCalibrationValues[j] < self.calibrationValues[j] {
                            self.currentCalibrationValues[j] += calculatingNumbers[j]
                            do {
                                try self.stemi.setCalibrationValue(UInt8(self.currentCalibrationValues[j]), atIndex: j)
                            } catch {
                                #if DEBUG
                                    print("error")
                                #endif
                            }
                        } else if self.currentCalibrationValues[j] > self.calibrationValues[j] {
                            self.currentCalibrationValues[j] -= calculatingNumbers[j]
                            do {
                                try self.stemi.setCalibrationValue(UInt8(self.currentCalibrationValues[j]), atIndex: j)
                            } catch {
                                #if DEBUG
                                    print("error")
                                #endif
                            }
                        }
                    } else {
                        self.currentCalibrationValues[j] = self.calibrationValues[j]
                        do {
                            try self.stemi.setCalibrationValue(UInt8(self.currentCalibrationValues[j]), atIndex: j)
                        } catch {
                            #if DEBUG
                                print("error")
                            #endif
                        }
                    }
                }
                Thread.sleep(forTimeInterval: 0.1)
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
