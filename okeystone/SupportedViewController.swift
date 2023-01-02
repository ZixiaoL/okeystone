//
//  SupportedViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import Network

class SupportedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISplitViewControllerDelegate {
    
    private var scanResult: ScanResult?
    
    @IBOutlet weak var downloadCompletedImage: UIImageView!
    
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
    
    
    @IBOutlet weak var instructions: UITableView!
    
    @IBOutlet weak var ipPortTextField: UITextField! {
        didSet {
            ipPortTextField.delegate = self
        }
    }
    
    var resignationHandler: (() -> Void)?
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    @IBAction func getDownloadLink(_ sender: UIButton) {
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "下载客户端",
                                                    message: "下载后打开客户端扫码链接手机设备",
                                                    preferredStyle: .actionSheet)
            
            
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
            let copyAction = UIAlertAction(title:"复制下载地址", style: .default, handler: {
                (action) -> Void in
                UIPasteboard.general.string = "https://okeystone.com/"
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                    self?.downloadCompletedImage.alpha = 1
                }) { [weak self] UIViewAnimatingPosition in
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                        self?.downloadCompletedImage.alpha = 0
                    })
                }})
            
            let settingsAction = UIAlertAction(title:"去官网查看", style: .default, handler: {
                (action) -> Void in
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
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(copyAction)
            alertController.addAction(settingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructions.delegate = self
        instructions.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showChooseMode":
            let vc = segue.destination as? ChooseModeViewController
            let ipAndPort = ipPortTextField.text!.split(separator: ":")
            vc?.scanResult = ScanResult(ssid: "unknown", password: "unknown", ip: String(ipAndPort[0]), port: String(ipAndPort[1]))
            break
        case "showScanView":
            let vc = segue.destination as? ScanViewController
            vc?.delegate = self
            break
        default:
            break
        }
    }
}

// MARK: - QRScanDelegate
extension SupportedViewController: ScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        if let res = try? JSONDecoder().decode(ScanResult.self, from: Data(result.utf8)) {
            ipPortTextField.text = "\(res.ip):\(res.port)"
            navigationController?.popViewController(animated: true)
            performSegue(withIdentifier: "showChooseMode", sender: self)
        }
    }
}

struct ScanResult: Decodable {
    let ssid, password, ip, port: String
}
