//
//  SettingsIPViewController.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

class SettingsIPViewController: UIViewController, UITextFieldDelegate, IPTextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var ipTextFields: [IPTextField]!

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.isEnabled = false

        let fullIP = UserDefaults.IP()
        let fullIPArr = fullIP.components(separatedBy: ".")
        var counter = 0
        for ipTextField in ipTextFields {
            ipTextField.tag = counter
            ipTextField.ipDelegate = self
            ipTextField.delegate = self
            ipTextField.text = fullIPArr[counter]
            counter += 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.enabled = false
        ipTextFields[3].becomeFirstResponder()
    }

    // MARK: - Orientation Handling
    override var shouldAutorotate : Bool {
        return false
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1
        if let nextResponder: UIResponder? = textField.superview?.viewWithTag(nextTag) {
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        doneButton.isEnabled = true

        let newLength = textField.text!.characters.count + string.characters.count - range.length

        switch textField {
        case ipTextFields[0]:
            if newLength > 3 {
                ipTextFields[1].text = string
                ipTextFields[1].becomeFirstResponder()
            }
            return newLength <= 3
        case ipTextFields[1]:
            if newLength > 3 {
                ipTextFields[2].text = string
                ipTextFields[2].becomeFirstResponder()
            } else if range.location == 0 && string.characters.count == 0 {
                return true
            }
            return newLength <= 3
        case ipTextFields[2]:
            if newLength > 3 {
                ipTextFields[3].text = string
                ipTextFields[3].becomeFirstResponder()
            } else if range.location == 0 && string.characters.count == 0 {
                return true
            }
            return newLength <= 3
        case ipTextFields[3]:
            if range.location == 0 && string.characters.count == 0 {
                return true
            }
            return newLength <= 3
        default:
            return true
        }
    }

    // MARK: IPTextFieldDelegate
    func deleteButtonPressed() {
        if ipTextFields[1].text?.characters.count == 0 {
            ipTextFields[0].becomeFirstResponder()
        } else if ipTextFields[2].text?.characters.count == 0 {
            ipTextFields[1].becomeFirstResponder()
        } else if ipTextFields[3].text?.characters.count == 0 {
            ipTextFields[2].becomeFirstResponder()
        }
    }

    // MARK: - Private methods
    fileprivate func resignFirstResponders() {
        for ipTextField in ipTextFields {
            ipTextField.resignFirstResponder()
        }
    }

    // MARK: Action Handlers
    @IBAction func cancelButtonActionHandler(_ sender: AnyObject) {
        resignFirstResponders()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonActionHandler(_ sender: AnyObject) {
        if ipTextFields[0].textInRange() && ipTextFields[1].textInRange() && ipTextFields[2].textInRange() && ipTextFields[3].textInRange() {
            let fullIPArr = [ipTextFields[0].text!, ipTextFields[1].text!, ipTextFields[2].text!, ipTextFields[3].text!]
            let fullIP = fullIPArr.joined(separator: ".")
            UserDefaults.setIP(fullIP)
            resignFirstResponders()
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: Localization.localizedString("ERROR"), message: Localization.localizedString("IP_ERROR"), preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: Localization.localizedString("OK"), style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func resetButtonActionHandler(_ sender: UIButton) {
        ipTextFields[0].text = "192"
        ipTextFields[1].text = "168"
        ipTextFields[2].text = "4"
        ipTextFields[3].text = "1"
        ipTextFields[3].becomeFirstResponder()
        doneButton.enabled = true
    }


}
