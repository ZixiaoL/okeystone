//
//  SteelingWheelModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/13.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import CoreLocation
import Network

class SteelingWheelModeViewController: UIViewController {
    
    let hostUDP: NWEndpoint.Host = "127.0.0.1"
    let portUDP: NWEndpoint.Port = 20131
    @IBOutlet weak var compassView: UIImageView!
    lazy var connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.headingAvailable() {
            locationM.startUpdatingHeading()
        }else {
            print("当前磁力计设备损坏")
        }
        
        connection.stateUpdateHandler = { (newState) in
            print("This is stateUpdateHandler:")
            switch (newState) {
            case .ready:
                print("State: Ready\n")
            case .setup:
                print("State: Setup\n")
            case .cancelled:
                print("State: Cancelled\n")
            case .preparing:
                print("State: Preparing\n")
            default:
                print("ERROR! State not defined!\n")
            }
        }
        connection.start(queue: .global(qos: .userInteractive))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func sendUDP(_ msg:String){
        let contentToSend=msg.data(using: String.Encoding.utf8)
        connection.send(content: contentToSend, completion: NWConnection.SendCompletion.contentProcessed({(NWError) in
            if NWError==nil{
                print("Data was sent to UDP")
            }else{
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        }))
    }
    
    lazy var locationM: CLLocationManager = {
        let locationM = CLLocationManager.shared
        locationM.delegate = self
        return locationM
    }()
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
extension SteelingWheelModeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading)
        let angle = newHeading.magneticHeading//拿到当前设备朝向 0- 359.9 角度
        let arc = CGFloat(angle / 180 * Double.pi)//角度转换成为弧度
        UIView.animate(withDuration: 0.5, animations: {
            self.compassView.transform = CGAffineTransform(rotationAngle: -arc)
        })
        sendUDP("\(arc)")
    }
}
