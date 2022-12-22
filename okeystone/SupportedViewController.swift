//
//  SupportedViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit

class SupportedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "placeHolder"
        switch indexPath.section {
        case 0:
            identifier = "instruction1"
        case 1:
            identifier = "instruction2"
        case 2:
            identifier = "instruction3"
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell;
    }
    
    
    
    @IBOutlet weak var iconAnimatedView: IconAnimatedView!
    
    @IBOutlet weak var instructions: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3, delay: 1, options: .curveEaseInOut, animations: { [weak self] in
            self?.iconAnimatedView.transform = CGAffineTransform.init(scaleX: 2, y: 2)
            }, completion: nil)
        instructions.delegate = self
        instructions.dataSource = self
    }
    
    @IBAction func scanAction(_ sender: UIButton) {
        let vc = QRScanViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - QRScanDelegate
extension SupportedViewController: QRScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        // PC端数据传输
        let vc = SteelingWheelModeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
