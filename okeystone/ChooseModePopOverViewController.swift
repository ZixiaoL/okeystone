//
//  ChooseModePopOverViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 12/26/22.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

protocol ChooseModePopOverViewControllerDelegate {
    func handleModes(modeIndex: Int);
}

class ChooseModePopOverViewController: UIViewController {
    
    var delegate: ChooseModePopOverViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presentationController is UIPopoverPresentationController {
            view.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var modes: UIStackView!
    
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
        let fittedSize = modes.sizeThatFits(UIView.layoutFittingCompressedSize)
        preferredContentSize = CGSize(width: fittedSize.width + 30, height: fittedSize.height + 30)
        
    }
    
    @IBAction func SelectMode(_ sender: UIButton) {
        self.dismiss(animated: true)
        delegate?.handleModes(modeIndex: sender.tag)
    }
}
