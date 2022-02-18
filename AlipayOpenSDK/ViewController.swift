//
//  ViewController.swift
//  AlipayOpenSDK
//
//  Created by jun on 2022/02/16.
//

import UIKit
import AlipaySDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AlipaySDK.defaultService().payOrder("", fromScheme: "") { result in
            
        }
        
    }


}

