//
//  UserAccelerationViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 1/28/23.
//  Copyright © 2023 Zixiao Li. All rights reserved.
//

import UIKit
import Network
import CoreMotion

class UserAccelerationViewController: UIViewController {
    
    var connection: PcConnectionService?
    
    var isConnectionActive = false {
        didSet {
            if(isConnectionActive) {
                startButton.setTitle("暂停", for: .normal)
            } else {
                startButton.setTitle("开始同步数据", for: .normal)
                timer.invalidate()
            }
        }
    }
    
    var timer = Timer()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var cover: UIView!
    
    @IBOutlet weak var countdown3: UIImageView!
    
    @IBOutlet weak var countdown2: UIImageView!
    
    @IBOutlet weak var countdown1: UIImageView!
    
    @IBOutlet weak var countdownCompleted: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startSync(_ sender: UIButton) {
        if(!isConnectionActive) {
            isConnectionActive = true
            cover.isHidden = false
            countdown3.isHidden = false
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                self?.countdown3.alpha = 0
            }) { [weak self] UIViewAnimatingPosition in
                self?.countdown3.isHidden = true
                self?.countdown3.alpha = 1
                self?.countdown2.isHidden = false
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    self?.countdown2.alpha = 0
                }) {UIViewAnimatingPosition in
                    self?.countdown2.isHidden = true
                    self?.countdown2.alpha = 1
                    self?.countdown1.isHidden = false
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                        self?.countdown1.alpha = 0
                    }) {UIViewAnimatingPosition in
                        self?.countdown1.isHidden = true
                        self?.countdown1.alpha = 1
                        self?.countdownCompleted.isHidden = false
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                            self?.countdownCompleted.alpha = 0

                        }) {
                            UIViewAnimatingPosition in
                            self?.countdownCompleted.isHidden = true
                            self?.countdownCompleted.alpha = 1
                            self?.cover.isHidden = true
                        }}}}
            timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(startCMMotionManager), userInfo: nil, repeats: false)
        } else {
            isConnectionActive = false
            CMMotionManager.shared.stopDeviceMotionUpdates()
            sendBytes(0)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // turn off the accelerometer
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isConnectionActive = false
        CMMotionManager.shared.stopDeviceMotionUpdates()
        sendBytes(0)
    }
    
    private func sendBytes(_ useracceleration: Double) {
        if (self.connection != nil) {
            let header: [UInt8] = [90] + self.connection!.messageId.getAndIncrement().toLowHigh() + [1, 21, 0x11]
            let body: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            + [0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            + useracceleration.toLowHigh()
            connection!.sendUDP(header + body)
        }
    }
    
    @objc private func startCMMotionManager() {
        if (!self.isConnectionActive) {
            return
        }
        if CMMotionManager.shared.isDeviceMotionAvailable {
            CMMotionManager.shared.deviceMotionUpdateInterval = 1/20
            CMMotionManager.shared.startDeviceMotionUpdates(to: .main, withHandler: { [weak self] (data, error) in
                if let x = data?.userAcceleration.x, let y = data?.userAcceleration.y, let z = data?.userAcceleration.z {
                    let strength = x*x+y*y+z*z
                    print("strength: \(strength)")
                    if strength < 0.3 {
                        self?.sendBytes(0)
                    } else if (strength > 0.6) {
                        self?.sendBytes(2)
                    } else {
                        self?.sendBytes(1)
                    }
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showScanView":
            let vc = segue.destination as? ScanViewController
                vc?.delegate = self
        default:
            break
        }
    }
}

// MARK: - QRScanDelegate
extension UserAccelerationViewController: ScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        if let res = try? JSONDecoder().decode(ScanResult.self, from: Data(result.utf8)) {
            self.connection = PcConnectionService(res.ip, res.port)
            navigationController?.popViewController(animated: true)
        }
    }
}
