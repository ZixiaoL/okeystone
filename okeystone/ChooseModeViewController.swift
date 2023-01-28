//
//  ChooseModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/11.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import Network

class ChooseModeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, ChooseModePopOverViewControllerDelegate {
    
    func handleModes(modeIndex: Int) {
        switch modeIndex {
        case 1:
            performSegue(withIdentifier: "showUserAccelerationModeViewController", sender: self)
        case 2:
            performSegue(withIdentifier: "showBalanceModeViewController", sender: self)
        case 3:
            performSegue(withIdentifier: "showSteelingWheelModeViewController", sender: self)
        case 4:
            performSegue(withIdentifier: "showEverythingModeViewController", sender: self)
        default:
            break
        }
    }
    
    
    var scanResult: ScanResult? {
        didSet {
            connection = PcConnectionService(scanResult!.ip, scanResult!.port)
            sendDeviceInfo()
        }
    }
    
    lazy var connection = PcConnectionService(scanResult!.ip, scanResult!.port)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructions.delegate = self
        instructions.dataSource = self
    }
    
    @IBOutlet weak var instructions: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4;
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
        case 3:
            identifier = "instruction4"
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        // Configure content.
        switch indexPath.section {
        case 0:
            cell.detailTextLabel?.text = scanResult!.ssid
        case 1:
            cell.detailTextLabel?.text = scanResult!.ssid
        case 2:
            cell.detailTextLabel?.text = UIDevice.current.name
        case 3:
            cell.detailTextLabel?.text = "deprecated?"
        default:
            break
        }
        return cell;
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showBalanceModeViewController":
            let vc = segue.destination as? BalanceModeViewController
            vc?.connection = connection
        case "showSteelingWheelModeViewController":
            let vc = segue.destination as? SteelingWheelModeViewController
            vc?.connection = connection
        case "showUserAccelerationModeViewController":
            let vc = segue.destination as? UserAccelerationViewController
            vc?.connection = connection
        case "showEverythingModeViewController":
            let vc = segue.destination as? EverythingModeViewController
            vc?.connection = connection
        case "popOverChooseModePopOverViewController":
            let vc = segue.destination as? ChooseModePopOverViewController
            vc?.delegate = self
        case "showScanView":
            let vc = segue.destination as? ScanViewController
            vc?.delegate = self
        default:
            break
        }
    }
    
    private func sendDeviceInfo() {
        let localIpBytes = [UInt8](scanResult!.ip.utf8)
        let header: [UInt8] = [90] + self.connection.messageId.getAndIncrement().toLowHigh() + [2, UInt8(localIpBytes.count) + 4]
        let body: [UInt8] = [UInt8(localIpBytes.count) + 2, 0x01, 0x11, 0x00]
        + localIpBytes
        connection.sendUDP(header + body)
    }
}

// MARK: - QRScanDelegate
extension ChooseModeViewController: ScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        if let res = try? JSONDecoder().decode(ScanResult.self, from: Data(result.utf8)) {
            self.scanResult = res
            navigationController?.popViewController(animated: true)
        }
    }
}
