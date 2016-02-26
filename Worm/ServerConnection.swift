//
//  ServerConnection.swift
//  Worm
//
//  Created by Piotr Pawluś on 26/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import UIKit

class ServerConnection {
    let clientSocket: TCPClient
    let Address = "Piotrs-MacBook-Pro.local"
    let Port = 50000
    let Frames = 33
    var success: Bool
    var errmsg: String
    
    init() {
        self.clientSocket =  TCPClient(addr: self.Address, port: self.Port)
        
        (success, errmsg) = self.clientSocket.connect(timeout: 5)
    }
    
    func sendPosition(position: CGPoint) {
        if success {
            let (success, errmsg) = self.clientSocket.send(str: "\(position)")
            if success {
                print("Sukces")
            } else {
                print(errmsg)
            }
        } else {
            print(errmsg)
        }
    }
    
    func closeConnection() {
        if success {
            self.clientSocket.close()
        }
    }
    
    
    func checkConnection() -> Bool {
        defer { (success, errmsg) = self.clientSocket.close() }
        var connected  = false
        if success {
            let (success, errmsg) = self.clientSocket.send(str: "Connected to server")
            if success {
                print("Sukces")
                connected = true
            } else {
                print(errmsg)
            }
        } else {
            print(errmsg)
        }
        return connected
    }
}
