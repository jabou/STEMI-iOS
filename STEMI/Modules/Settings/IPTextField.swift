//
//  IPTextField.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 13/08/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

protocol IPTextFieldDelegate: class {
    func deleteButtonPressed()
}

class IPTextField: UITextField {

    weak var ipDelegate: IPTextFieldDelegate?

    // MARK: - UITextField methods
    override func deleteBackward() {
        super.deleteBackward()
        ipDelegate?.deleteButtonPressed()
    }

    // MARK: - Public methods
    func textInRange() -> Bool {
        var isInRange = false
        if let text = self.text {
            let stringToInt = Int(text)
            if let int = stringToInt {
                if 1 ... 255 ~= int {
                    isInRange = true
                }
            }
        }
        return isInRange
    }

}
