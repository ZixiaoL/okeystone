//
//  SupportedViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

class SupportedViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func scanAction(_ sender: UIButton) {
        let vc = QRScanViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - QRScanDelegate
extension SupportedViewController: QRScanDelegate {
    func handleQRScanResult(result: String) {
        // PC端数据传输
    }
}
