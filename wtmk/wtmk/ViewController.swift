//
//  ViewController.swift
//  wtmk
//
//  Created by tambi on 9/29/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let bridge = WTMKBridge()
        let originalPath = Bundle.main.path(forResource: "original", ofType: "jpg") ?? ""
        let watermark = Bundle.main.path(forResource: "watermark", ofType: "png") ?? ""
        
        bridge.test(originalPath, watermarkImage: watermark, outputImage: "")
    }


}

