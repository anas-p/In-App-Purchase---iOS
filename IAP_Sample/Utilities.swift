//
//  Utilities.swift
//  IAP_Sample
//
//  Created by Anas Zaheer on 08/12/17.
//  Copyright © 2017 nfnlabs. All rights reserved.
//

import UIKit

class Utilities: NSObject {

    func showAlertContrller(title:String, message: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        return alertController
    }
    
}
