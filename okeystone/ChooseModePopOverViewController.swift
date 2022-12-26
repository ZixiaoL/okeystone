//
//  ChooseModePopOverViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 12/26/22.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

class ChooseModePopOverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if presentationController is UIPopoverPresentationController {
            view.backgroundColor = .clear
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // any time we get re-layed out
    // we reset our preferredContentSize
    // to tightly fit our top-level stack view
    // using autolayout, i.e., sizeThatFits(UILayoutFittingCompressedSize)

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if let fittedSize = self?.sizeThatFits(UILayoutFittingCompressedSize) {
//            preferredContentSize = CGSize(width: fittedSize.width + 30, height: fittedSize.height + 30)
//        }
    }

}
