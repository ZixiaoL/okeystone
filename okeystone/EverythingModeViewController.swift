//
//  EverythingModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 1/28/23.
//  Copyright © 2023 Zixiao Li. All rights reserved.
//

import UIKit
import Network
import CoreMotion
import CoreLocation

class EverythingModeViewController: UIViewController {
    
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
    
    var originalHeading: Double?
    
    var timer = Timer()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var floatingBallBehavior = FloatingBallBehavior(in: animator)
    
    @IBOutlet weak var floatingBallView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var pointerBoard: UIImageView!
    
    @IBOutlet weak var cover: UIView!
    
    @IBOutlet weak var pointer: UIImageView!
    
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
            originalHeading = nil
            self.pointer.transform = CGAffineTransform.identity
            CMMotionManager.shared.stopDeviceMotionUpdates()
            CLLocationManager.shared.stopUpdatingHeading()
            sendBytes(0, 0, 0, 0)
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
        CLLocationManager.shared.stopUpdatingHeading()
        sendBytes(0, 0, 0, 0)
    }
    
    private func toBytes(_ roll: Double, _ pitch: Double, _ direction: Double) -> [UInt8] {
        var res = [UInt8] ()
        res.append(contentsOf: (roll / .pi * 32768).toLowHigh())
        res.append(contentsOf: (pitch / .pi * 32768).toLowHigh())
        res.append(contentsOf: direction.toLowHigh())
        return res
    }
    
    private func sendBytes(_ roll: Double, _ pitch: Double, _ useracceleration: Double, _ direction: Double) {
        if (self.connection != nil) {
            let header: [UInt8] = [90] + self.connection!.messageId.getAndIncrement().toLowHigh() + [1, 21, 0x11]
            let body: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            + toBytes(roll, pitch, direction)
            + useracceleration.toLowHigh()
            connection!.sendUDP(header + body)
        }
    }
    
    @objc private func startCMMotionManager() {
        if (!self.isConnectionActive) {
            return
        }
        if CLLocationManager.headingAvailable() {
            CLLocationManager.shared.startUpdatingHeading()
        }
        if CMMotionManager.shared.isDeviceMotionAvailable {
            self.floatingBallBehavior.addItem(self.floatingBallView)
            self.floatingBallBehavior.gravityBehavior.magnitude = 100
            CMMotionManager.shared.deviceMotionUpdateInterval = 1/5
            CMMotionManager.shared.startDeviceMotionUpdates(to: .main, withHandler: { [weak self] (data, error) in
                var rollToSend = 0.0
                var pitchToSend = 0.0
                var directionToSend = 0.0
                var useraccelerationToSend = 0.0
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
                            rollToSend = roll
                            pitchToSend = -pitch
                        }
                    }
                }
                if let x = data?.userAcceleration.x, let y = data?.userAcceleration.y, let z = data?.userAcceleration.z {
                    let strength = x*x+y*y+z*z
                    print("strength: \(strength)")
                    if strength < 0.3 {
                        useraccelerationToSend = 0
                    } else if (strength > 0.6) {
                        useraccelerationToSend = 2
                    } else {
                        useraccelerationToSend = 1
                    }
                }
                if CLLocationManager.headingAvailable(), let newHeading = CLLocationManager.shared.heading {
                    print(newHeading)
                    let angle = newHeading.magneticHeading//拿到当前设备朝向 0- 359.9 角度
                    if self?.originalHeading == nil {
                        self?.originalHeading = angle
                    }
                    print("originalHeading: \(self?.originalHeading! ?? 0)")
                    let arc = CGFloat((angle-(self?.originalHeading!)!) / 180 * Double.pi)//角度转换成为弧度
                    UIView.animate(withDuration: 0.5, animations: {
                        print("radian: \(arc)")
                        let transform = CGAffineTransform(translationX: 0, y: (self?.pointerBoard.frame.height ?? 0)/3.5)
                            .rotated(by: arc)
                            .translatedBy(x: 0, y: -(self?.pointerBoard.frame.height ?? 0)/3.5)
                        self?.pointer.transform = transform
                    })
                    if(angle-(self?.originalHeading! ?? 0) >= 180) {
                        directionToSend = angle-(self?.originalHeading! ?? 0)-360
                    } else if (angle-(self?.originalHeading! ?? 0) < -180) {
                        directionToSend = angle-(self?.originalHeading! ?? 0)+360
                    } else {
                        directionToSend = angle-(self?.originalHeading! ?? 0)
                    }
                }else {
                    print("当前磁力计设备损坏")
                }
                self?.sendBytes(rollToSend, pitchToSend, useraccelerationToSend, directionToSend)
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
extension EverythingModeViewController: ScanViewControllerDelegate {
    func handleQRScanResult(result: String) {
        if let res = try? JSONDecoder().decode(ScanResult.self, from: Data(result.utf8)) {
            self.connection = PcConnectionService(res.ip, res.port)
            navigationController?.popViewController(animated: true)
        }
    }
}

//extension EverythingModeViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        print(newHeading)
//        let angle = newHeading.magneticHeading//拿到当前设备朝向 0- 359.9 角度
//        if originalHeading == nil {
//            originalHeading = angle
//        }
//        print("originalHeading: \(originalHeading!)")
//        let arc = CGFloat((angle-originalHeading!) / 180 * Double.pi)//角度转换成为弧度
//        UIView.animate(withDuration: 0.5, animations: {
//            print("radian: \(arc)")
//            let transform = CGAffineTransform(translationX: 0, y: self.pointerBoard.frame.height/3.5)
//                .rotated(by: arc)
//                .translatedBy(x: 0, y: -self.pointerBoard.frame.height/3.5)
//            self.pointer.transform = transform
//        })
//        if(angle-originalHeading! >= 180) {
//            sendBytes(forDirection: angle-originalHeading!-360)
//        } else if (angle-originalHeading! < -180) {
//            sendBytes(forDirection: angle-originalHeading!+360)
//        } else {
//            sendBytes(forDirection: angle-originalHeading!)
//        }
//    }
//}
