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
            vc?.scanResult = ScanResult(ip: String(ipAndPort[0]), port: String(ipAndPort[1]))
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
    let ip, port: String
}
