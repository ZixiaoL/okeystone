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


class SteelingWheelModeViewController: UIViewController {
    
    var scanResult: ScanResult?
    var messageId = UInt16(0)
    
    lazy var connection = PcConnectionService(scanResult!.ip, scanResult!.port)
    
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
    
    
    @IBAction func startSync(_ sender: UIButton) {
        if(sender.currentTitle == "开始同步数据") {
            sender.setTitle("暂停", for: .normal)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                if CMMotionManager.shared.isDeviceMotionAvailable {
                    self?.sendDeviceInfo()
                    self?.floatingBallBehavior.addItem(self!.floatingBallView)
                    self?.floatingBallBehavior.gravityBehavior.magnitude = 100
                    CMMotionManager.shared.deviceMotionUpdateInterval = 1/60
                    CMMotionManager.shared.startDeviceMotionUpdates(to: .main, withHandler: { [weak self] (data, error) in
                        if let gravityX = data?.gravity.x, let gravityY = data?.gravity.y {
                            if gravityX != 0 && gravityY != 0 {
                                var xy = 0.0;
                                switch UIDevice.current.orientation {
                                case .portrait:
                                    xy = atan2(gravityX, gravityY)
                                    self?.floatingBallBehavior.push(self!.floatingBallView, CGVector(dx: gravityX, dy: gravityY))
                                case .portraitUpsideDown: break
                                case .landscapeRight:
                                    xy = atan2(-gravityY, gravityX)
                                    self?.floatingBallBehavior.push(self!.floatingBallView, CGVector(dx: -gravityY, dy: gravityX))
                                case .landscapeLeft:
                                    xy = atan2(gravityY, -gravityX)
                                    self?.floatingBallBehavior.push(self!.floatingBallView, CGVector(dx: gravityY, dy: -gravityX))
                                default:
                                    xy = atan2(gravityX, gravityY)
                                    self?.floatingBallBehavior.push(self!.floatingBallView, CGVector(dx: gravityX, dy: gravityY))
                                }
                                //计算相对于y轴的重力方向
                                self?.floatingBallBehavior.gravityBehavior.angle = xy - .pi / 2;
                                var length = 120*sqrt(gravityX*gravityX+gravityY*gravityY)
                                print("length: \(length)")
                                self?.floatingBallBehavior.attachmentBehavior?.length = length
                            }
                            
                        }
                        if let roll = data?.attitude.roll, let pitch = data?.attitude.pitch, let yaw = data?.attitude.yaw {
                            print("roll: \(roll) pitch: \(-pitch) yaw: \(yaw)")
                            self?.sendBytes(roll, -pitch, yaw)
                        }
                    })
                }
            }
        } else {
            sender.setTitle("开始同步数据", for: .normal)
            floatingBallBehavior.removeItem(self.floatingBallView)
            CMMotionManager.shared.stopDeviceMotionUpdates()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // turn off the accelerometer
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        floatingBallBehavior.gravityBehavior.magnitude = 0
        CMMotionManager.shared.stopDeviceMotionUpdates()
    }
    
    private func toBytes(_ roll: Double, _ pitch: Double, _ yaw: Double) -> [UInt8] {
        var res = [UInt8] ()
        res.append(contentsOf: roll.toLowHigh())
        res.append(contentsOf: pitch.toLowHigh())
        res.append(contentsOf: yaw.toLowHigh())
        return res
    }
    
    private func sendBytes(_ roll: Double, _ pitch: Double, _ yaw: Double) {
        let header: [UInt8] = [90] + self.messageId.toLowHigh() + [1, 21, 0x11]
        let body: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        + toBytes(roll, pitch, yaw)
        + [0x00, 0x00]
        messageId += 1
        connection.sendUDP(header + body)
    }
    
    private func sendDeviceInfo() {
        let localIpBytes = [UInt8](scanResult!.ip.utf8)
        let header: [UInt8] = [90] + self.messageId.toLowHigh() + [2, UInt8(localIpBytes.count) + 4]
        let body: [UInt8] = [UInt8(localIpBytes.count) + 2, 0x01, 0x11, 0x00]
        + localIpBytes
        messageId += 1
        connection.sendUDP(header + body)
    }
}

extension Double {
    func toLowHigh() -> [UInt8] {
        let value =  Int16((self / .pi * 32768))
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
