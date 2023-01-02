//
//  DiscoveryViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 1/2/23.
//  Copyright © 2023 Zixiao Li. All rights reserved.
//

import UIKit

class DiscoveryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            userGuide.isUserInteractionEnabled = true
            userGuide.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var userGuide: UIImageView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let url = URL(string: "https://okeystone.com/")
        if let url = url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        // Your action
    }

}
