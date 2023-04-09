//
//  SteelingWheelModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 1/28/23.
//  Copyright © 2023 Zixiao Li. All rights reserved.
//

import UIKit
import Network
import CoreLocation

class SteelingWheelModeViewController: UIViewController {
    
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
    
    @IBOutlet weak var turnLeftLabel: UILabel!
    @IBOutlet weak var turnRightLabel: UILabel!
    
    var originalHeading: Double?
    
    var timer = Timer()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    override func viewDidLoad() {
        super.viewDidLoad()	
    }
    
    @IBOutlet weak var cover: UIView!
    
    @IBOutlet weak var pointer: UIImageView!
    
    @IBOutlet weak var pointerBoard: UIImageView!
    
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
            timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(startCLLocationManager), userInfo: nil, repeats: false)
        } else {
            isConnectionActive = false
            CLLocationManager.shared.stopUpdatingHeading()
            originalHeading = nil
            self.pointer.transform = CGAffineTransform.identity
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
        CLLocationManager.shared.stopUpdatingHeading()
        sendBytes(0)
    }
    
    private func sendBytes(_ direction: Double) {
        if (self.connection != nil) {
            let header: [UInt8] = [90] + self.connection!.messageId.getAndIncrement().toLowHigh() + [1, 21, 0x11]
            let body: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            + [0x00, 0x00, 0x00, 0x00]
            + direction.toLowHigh()
            + [0x00, 0x00]
            connection!.sendUDP(header + body)
        }
    }
    
    @objc private func startCLLocationManager() {
        if (!self.isConnectionActive) {
            return
        }
        if CLLocationManager.headingAvailable() {
            CLLocationManager.shared.delegate = self
            CLLocationManager.shared.startUpdatingHeading()
        }else {
            print("当前磁力计设备损坏")
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
extension SteelingWheelModeViewController: ScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        if let res = try? JSONDecoder().decode(ScanResult.self, from: Data(result.utf8)) {
            self.connection = PcConnectionService(res.ip, res.port)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension SteelingWheelModeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading)
        let angle = newHeading.magneticHeading//拿到当前设备朝向 0- 359.9 角度
        if originalHeading == nil {
            originalHeading = angle
        }
        print("originalHeading: \(originalHeading!)")
        let arc = CGFloat((angle-originalHeading!) / 180 * Double.pi)//角度转换成为弧度
        UIView.animate(withDuration: 0.5, animations: {
            print("radian: \(arc)")
            let transform = CGAffineTransform(translationX: 0, y: self.pointerBoard.frame.height/3.5)
                .rotated(by: arc)
                .translatedBy(x: 0, y: -self.pointerBoard.frame.height/3.5)
            self.pointer.transform = transform
        })
        if(angle-originalHeading! >= 180) {
            sendBytes(angle-originalHeading!-360)
        } else if (angle-originalHeading! < -180) {
            sendBytes(angle-originalHeading!+360)
        } else {
            sendBytes(angle-originalHeading!)
        }
    }
}
