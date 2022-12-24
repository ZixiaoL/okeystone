//
//  PcConnectionService.swift
//  okeystone
//
//  Created by Zixiao Li on 12/24/22.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import Foundation
import Network

class PcConnectionService {
    private var connection: NWConnection
    
    init(_ host: String, _ port: String) {
        self.connection = NWConnection(host: NWEndpoint.Host(host), port: NWEndpoint.Port(port)!, using: .udp)
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
        connection.start(queue: .global())
    }
    
    func sendUDP(_ msg: [UInt8]){
        connection.send(content: msg, completion: NWConnection.SendCompletion.contentProcessed({(NWError) in
            if NWError == nil{
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        }))
    }
}
