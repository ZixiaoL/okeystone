//
//  SteelingWheelModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import Network
import CoreMotion


class BalanceModeViewController: UIViewController {
    
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
    
    lazy var floatingBallBehavior = FloatingBallBehavior(in: animator)
    
    @IBOutlet weak var floatingBallView: UIImageView!
    
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
            floatingBallBehavior.gravityBehavior.magnitude = 0
            floatingBallBehavior.removeItem(self.floatingBallView)
            CMMotionManager.shared.stopDeviceMotionUpdates()
            sendBytes(0, 0, 0)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // turn off the accelerometer
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isConnectionActive = false
        floatingBallBehavior.gravityBehavior.magnitude = 0
        floatingBallBehavior.removeItem(self.floatingBallView)
        CMMotionManager.shared.stopDeviceMotionUpdates()
        sendBytes(0, 0, 0)
    }
    
    private func toBytes(_ roll: Double, _ pitch: Double, _ yaw: Double) -> [UInt8] {
        var res = [UInt8] ()
        res.append(contentsOf: (roll / .pi * 32768).toLowHigh())
        res.append(contentsOf: (pitch / .pi * 32768).toLowHigh())
        res.append(contentsOf: (yaw / .pi * 32768).toLowHigh())
        return res
    }
    
    private func sendBytes(_ roll: Double, _ pitch: Double, _ yaw: Double) {
        if (self.connection != nil) {
            let header: [UInt8] = [90] + self.connection!.messageId.getAndIncrement().toLowHigh() + [1, 21, 0x11]
            let body: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            + toBytes(roll, pitch, yaw)
            + [0x00, 0x00]
            connection!.sendUDP(header + body)
        }
    }
    
    @objc private func startCMMotionManager() {
        if (!self.isConnectionActive) {
            return
        }
        if CMMotionManager.shared.isDeviceMotionAvailable {
            self.floatingBallBehavior.addItem(self.floatingBallView)
            self.floatingBallBehavior.gravityBehavior.magnitude = 100
            CMMotionManager.shared.deviceMotionUpdateInterval = 1/20
            CMMotionManager.shared.startDeviceMotionUpdates(to: .main, withHandler: { [weak self] (data, error) in
                if let gravityX = data?.gravity.x, let gravityY = data?.gravity.y {
                    if gravityX != 0 && gravityY != 0 {
                        var xy = 0.0;
                        switch UIDevice.current.orientation {
                        case .portrait:
                            xy = atan2(gravityX, gravityY)
                        case .portraitUpsideDown: break
                        case .landscapeRight:
                            xy = atan2(-gravityY, gravityX)
                        case .landscapeLeft:
                            xy = atan2(gravityY, -gravityX)
                        default:
                            xy = atan2(gravityX, gravityY)
                        }
                        //计算相对于y轴的重力方向
                        self?.floatingBallBehavior.gravityBehavior.angle = xy - .pi / 2;
                        let length = 240*sqrt(gravityX*gravityX+gravityY*gravityY)
                        print("length: \(length)")
                        self?.floatingBallBehavior.attachmentBehavior?.length = min(length, 120)
                        if length > 60, let roll = data?.attitude.roll, let pitch = data?.attitude.pitch, let yaw = data?.attitude.yaw {
                            print("roll: \(roll) pitch: \(-pitch) yaw: \(yaw)")
                            self?.sendBytes(roll, -pitch, yaw)
                        }
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

extension Double {
    func toLowHigh() -> [UInt8] {
        let value =  Int16(self)
        let high = UInt8((value >> 8) & 0xff)
        let low = UInt8(value & 0xff)
        return [low, high]
    }
}

extension UInt16 {
    func toLowHigh() -> [UInt8] {
        let high = UInt8((self >> 8) & 0xff)
        let low = UInt8(self & 0xff)
        return [low, high]
    }
}

// MARK: - QRScanDelegate
extension BalanceModeViewController: ScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        if let res = try? JSONDecoder().decode(ScanResult.self, from: Data(result.utf8)) {
            self.connection = PcConnectionService(res.ip, res.port)
            navigationController?.popViewController(animated: true)
        }
    }
}
