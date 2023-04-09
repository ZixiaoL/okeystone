//
//  ChooseModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/11.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import Network
import NetworkExtension

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
    
    @IBOutlet weak var status: UILabel!
    
    
    var scanResult: ScanResult? {
        didSet {
            connection = PcConnectionService(scanResult!.ip, scanResult!.port)
            sendDeviceInfo()
        }
    }
    
    lazy var connection = PcConnectionService(scanResult!.ip, scanResult!.port)
    
    @IBOutlet weak var deviceCurrentStatus: UIButton!
    
    @IBOutlet weak var backgroundView: BackgroundView!
    
    @IBAction func deviceCurrentStatus(_ sender: UIButton) {
        handleModes(modeIndex: 4)
    }
    
    var successfulStateCount = 0 {
        didSet {
            if(successfulStateCount == -1) {
                status.text = "连接失败"
                backgroundView.backgroundColor = UIColor(cgColor: #colorLiteral(red: 1, green: 0.8347119689, blue: 0.8241621852, alpha: 1))
                deviceCurrentStatus.isHidden = false
            } else if (successfulStateCount == 4) {
                status.text = "连接成功！"
                backgroundView.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.778111279, green: 0.9830670953, blue: 0.8974402547, alpha: 1))
                deviceCurrentStatus.isHidden = false
            }
        }
    }
    
    var successfulState = [0, 0, 0, 0] {
        didSet {
                instructions.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructions.delegate = self
        instructions.dataSource = self
        connectWifi(scanResult!.ssid, scanResult!.password)
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
            if(successfulState[0] == 0) {
                cell.detailTextLabel?.text = "WIFI"
                cell.imageView?.rotate()
            } else if(successfulState[0] == 1) {
                cell.imageView?.image = UIImage(named: "checkbox-circle-fill")
                cell.detailTextLabel?.text = scanResult?.ssid
            } else {
                cell.imageView?.image = UIImage(named: "error-warning-fill")
                cell.detailTextLabel?.text = scanResult?.ssid
            }
        case 1:
            if(successfulState[1] == 0) {
                cell.detailTextLabel?.text = "电脑连接中"
                cell.imageView?.rotate()
            } else if(successfulState[1] == 1) {
                cell.imageView?.image = UIImage(named: "checkbox-circle-fill")
                cell.detailTextLabel?.text = scanResult?.ssid
            } else {
                cell.imageView?.image = UIImage(named: "error-warning-fill")
                cell.detailTextLabel?.text = scanResult?.ssid
            }
        case 2:
            if(successfulState[2] == 0) {
                cell.detailTextLabel?.text = "正在获取设备名称"
                cell.imageView?.rotate()
            } else if(successfulState[2] == 1) {
                cell.imageView?.image = UIImage(named: "checkbox-circle-fill")
                cell.detailTextLabel?.text = UIDevice.current.name
            } else {
                cell.imageView?.image = UIImage(named: "error-warning-fill")
                cell.detailTextLabel?.text = "获取设备名称失败"
            }
        case 3:
            if(successfulState[3] == 0) {
                cell.detailTextLabel?.text = "正在获取设备模式"
                cell.imageView?.rotate()
            } else if(successfulState[2] == 1) {
                cell.imageView?.image = UIImage(named: "checkbox-circle-fill")
                cell.detailTextLabel?.text = "方向盘模式"
            } else {
                cell.imageView?.image = UIImage(named: "error-warning-fill")
                cell.detailTextLabel?.text = "获取设备模式失败"
            }
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
    
    func connectWifi(_ ssid: String, _ password: String){
        if #available(iOS 11.0, *) {
            let hcg =  NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
            NEHotspotConfigurationManager.shared.apply(hcg) { [weak self] (erro) in
                if erro == nil {
                    print("链接wifi成功")
                    self?.successfulState[0] = 1
                    self?.successfulState[1] = 1
                    self?.successfulState[2] = 1
                    self?.successfulState[3] = 1
                    self?.successfulStateCount = 4
                }else{
                    print(erro?.localizedDescription ?? "未知错误")
                    self?.successfulState[0] = -1
                    self?.successfulState[1] = -1
                    self?.successfulState[2] = 1
                    self?.successfulState[3] = 1
                    self?.successfulStateCount = -1
                }
            }
        } else {
            // 跳转至设置界面
        }
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

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}
