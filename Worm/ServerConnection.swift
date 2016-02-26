//
//  ServerConnection.swift
//  Worm
//
//  Created by Piotr Pawluś on 26/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import UIKit

class ServerConnection {
    let client: TCPClient = TCPClient(addr: "Piotrs-MacBook-Pro.local", port: 50000)
    
    
    func sendPosition(position: CGPoint) {
        var (success, errmsg) = self.client.connect(timeout: 1)
        if success {
            let (success, errmsg) = self.client.send(str: "\(position)")
            if success {
                print("Sukces")
            } else {
                print(errmsg)
            }
        } else {
            print(errmsg)
        }
        (success, errmsg) = self.client.close()
    }
    
    
    func checkConnection() -> Bool {
        var sukces = false
        var (success, errmsg) = self.client.connect(timeout: 1)
        if success {
            let (success, errmsg) = self.client.send(str: "Connected to server")
            if success {
                print("Sukces")
                sukces = true
            } else {
                print(errmsg)
            }
        } else {
            print(errmsg)
        }
        (success, errmsg) = self.client.close()
        return sukces
    }
}
