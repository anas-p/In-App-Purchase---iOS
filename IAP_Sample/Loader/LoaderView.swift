//
//  LoaderView.swift
//  IAP_Sample
//
//  Created by Anas Zaheer on 08/12/17.
//  Copyright © 2017 nfnlabs. All rights reserved.
//

import UIKit

class LoaderView: UIView {

    class func instanceFromNib() -> LoaderView {
        return UINib(nibName: "LoaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LoaderView
    }
    
    @IBOutlet weak var lblLoaderTitle: UILabel!
}
