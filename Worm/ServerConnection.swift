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
    
    func sendPosition(position: CGPoint, rotation: CGFloat) -> String? {
        var message = String()
        if success {
            
            let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
            let string = "M:\(uuid):\(position.x):\(position.y):\(rotation)"
            let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
            let (success, errmsg) = self.clientSocket.send(data: data)

            if success {
                guard let data = clientSocket.read(1024*100) else {
                    print("Server does not send massage")
                    return nil
                }
                
                guard let mess = NSString(data: NSData(bytes: data, length: data.count), encoding: NSUTF8StringEncoding) as? String else {
                    print("not a valid UTF-8 sequence")
                    return nil
                }
                
                message = mess
                
            } else {
                print(errmsg)
            }
        } else {
            print(errmsg)
        }
        
        return message
    }
    
    func closeConnection() {
        let (success, errmsg) = clientSocket.close()
        if success {
            print("Połączenie zamknięte")
        } else {
            print(errmsg)
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
