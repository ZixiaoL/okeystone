//
//  ChooseModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/11.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import Network

class ChooseModeViewController: UIViewController {

    var hostUDP: String?
    var portUDP: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showSteelingWheelMode") {
            let vc = segue.destination as? SteelingWheelModeViewController
            vc?.hostUDP = hostUDP!
            vc?.portUDP = portUDP!
        }
    }
}
