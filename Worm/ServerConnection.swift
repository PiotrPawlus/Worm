//
//  ServerConnection.swift
//  Worm
//
//  Created by Piotr Pawluś on 26/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import UIKit

enum ServerFrame {
    case M, W
}

class ServerConnection {
    let clientSocket: TCPClient
    let Address = "Piotrs-MacBook-Pro.local" //"henryk.local"
    let Port = 50000
    let Frames = 33
    var success: Bool
    var errmsg: String
    var uuid: String
    init() {
        self.clientSocket =  TCPClient(addr: self.Address, port: self.Port)
        
        (success, errmsg) = self.clientSocket.connect(timeout: 5)
        uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString

    }

    func send(frame: ServerFrame, x: CGFloat, y: CGFloat, r: CGFloat, timestamp: NSTimeInterval) -> String? {
        var backMessage = String()
        
        if success {
            var incoming = ":\(uuid):\(x):\(y):\(r):\(timestamp)"
            
            switch frame {
            case .M:
                incoming = "M\(incoming)"
            case .W:
                incoming = "W\(incoming)"
            }
            
            let data = incoming.dataUsingEncoding(NSUTF8StringEncoding)!
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
                
                backMessage = mess
            } else {
                print(errmsg)
            }
        } else {
            print(errmsg)
        }
        
    
        
        
        print(backMessage)
        return backMessage
    }
  
    
    private func spliteIncomingMessage(message: String) -> (ServerFrame, CGFloat, CGFloat, CGFloat, NSNumber)? {
        
        var frame: ServerFrame = .M
        var flag: NSNumber = 0
        var x, y, r: CGFloat
        // W : flaga : x : y : r
        
        let splite = message.componentsSeparatedByString(":")
        
        
        if splite[0] == "M" {
            frame = .M
        } else if splite[0] == "W" {
            frame = .W
        }
        
        switch frame {
        case .M:
            guard let posX = Float(splite[1]) else {
                return nil
            }
            
            guard let posY = Float(splite[2]) else {
                return nil
            }
            
            guard let rot = Float(splite[3]) else {
                return nil
            }
            
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = CGFloat(rot)
            
        case .W:
            
            guard let f = NSNumberFormatter().numberFromString(splite[1]) else {
                return nil
            }
            
            guard let posX = NSNumberFormatter().numberFromString(splite[2]) else {
                return nil
            }
            guard let posY = NSNumberFormatter().numberFromString(splite[3]) else {
                return nil
            }
            guard let rot = NSNumberFormatter().numberFromString(splite[4]) else {
                return nil
            }
            
            flag = f
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = CGFloat(rot)
        }
        
            
        return (frame, x, y, r, flag)
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
