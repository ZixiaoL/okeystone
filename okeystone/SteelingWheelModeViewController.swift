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
    
    var hostUDP = "127.0.0.1"
    var portUDP = "20131"
    var messageId = UInt16(0)
    
    lazy var connection = PcConnectionService(hostUDP, portUDP)
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var floatingBallBehavior = FloatingBallBehavior(in: animator)
    
    @IBOutlet weak var floatingBallView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CMMotionManager.shared.isDeviceMotionAvailable {
            floatingBallBehavior.addItem(floatingBallView)
            floatingBallBehavior.gravityBehavior.magnitude = 100
            CMMotionManager.shared.deviceMotionUpdateInterval = 1/60
            CMMotionManager.shared.startDeviceMotionUpdates(to: .main, withHandler: { [self] (data, error) in
                if let gravityX = data?.gravity.x, let gravityY = data?.gravity.y {
                    if gravityX != 0 && gravityY != 0 {
                        var xy = 0.0;
                        switch UIDevice.current.orientation {
                        case .portrait:
                            xy = atan2(gravityX, gravityY)
                            self.floatingBallBehavior.push(self.floatingBallView, CGVector(dx: gravityX, dy: gravityY))
                        case .portraitUpsideDown: break
                        case .landscapeRight:
                            xy = atan2(-gravityY, gravityX)
                            self.floatingBallBehavior.push(self.floatingBallView, CGVector(dx: -gravityY, dy: gravityX))
                        case .landscapeLeft:
                            xy = atan2(gravityY, -gravityX)
                            self.floatingBallBehavior.push(self.floatingBallView, CGVector(dx: gravityY, dy: -gravityX))
                        default:
                            xy = atan2(gravityX, gravityY)
                            self.floatingBallBehavior.push(self.floatingBallView, CGVector(dx: gravityX, dy: gravityY))
                        }
                        //计算相对于y轴的重力方向
                        self.floatingBallBehavior.gravityBehavior.angle = xy - .pi / 2;
                    }
                    
                }
                if let roll = data?.attitude.roll, let pitch = data?.attitude.pitch, let yaw = data?.attitude.yaw {
                    sendDeviceInfo()
                    sendBytes(roll, pitch, yaw)
                }
            })
        }
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
        let localIpBytes = [UInt8](hostUDP.utf8)
        let header: [UInt8] = [90] + self.messageId.toLowHigh() + [2, 14, 0x11]
        let body: [UInt8] = [0x06, 0x02, 0x11, 0x00]
        + localIpBytes
        + [0x22, 0x03]
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
