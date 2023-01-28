//
//  CLLocationManager+shared.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/14.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import CoreMotion
import CoreLocation

extension CMMotionManager {
    static var shared = CMMotionManager()
}

extension CLLocationManager {
     static var shared = CLLocationManager()
 }
