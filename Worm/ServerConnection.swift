//
//  ServerConnection.swift
//  Worm
//
//  Created by Piotr Pawluś on 26/02/16.
//  Copyright © 2016 Piotr Pawluś. All rights reserved.
//

import UIKit

enum ServerFrame {
    case M, W, P
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

    func send(frame: ServerFrame, x: CGFloat, y: CGFloat, r: CGFloat, timestamp: NSTimeInterval) -> (frame: ServerFrame, posX: CGFloat, posY: CGFloat, rot: CGFloat, flag: Int)? {
        var backMessage = String()
        
        if success {
            var message = ":\(uuid):\(x):\(y):\(r):\(timestamp)"
            
            switch frame {
            case .M:
                message = "M\(message)"
            case .W:
                message = "W\(message)"
            case .P:
                return nil
            }
            
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)!
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
    
        guard let params = spliteIncomingMessage(backMessage) else {
            return nil
        }
        
        print("Splite: \(params)")
        return params
    }
    
    func sendPoint(frame: ServerFrame, pointCollected: Bool) -> String? {
        // P:uuid:1 or P:uuid:0 - point:id_phone:collected
        
        var backMessage = String()
        if success {
            var message = ":\(uuid):"
            switch frame {
            case .P:
                message = "P\(message)"
                if pointCollected {
                    message = "\(message)1"
                } else {
                    message = "\(message)0"
                }
            default:
                return nil
            }
            
            let data = message.dataUsingEncoding(NSUTF8StringEncoding)!
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
        

        return backMessage
    }
  
    
    private func spliteIncomingMessage(message: String) -> (ServerFrame, CGFloat, CGFloat, CGFloat, Int)? {
        
        
        var frame: ServerFrame = .M
        var flag: Int = 0
        var x, y, r: CGFloat
        
        let splite = message.componentsSeparatedByString(":")
        if splite.count < 2 {
            return nil
        }
        
        if splite[0] == "M" {
            frame = .M
        } else if splite[0] == "W" {
            frame = .W
        } else if splite[0] == "P" {
            frame = .P
        }
        
        switch frame {
        case .M:
            print("M")
            guard let posX = Float(splite[1]) else {
                print("posx")
                return nil
            }
            
            guard let posY = Float(splite[2]) else {
                print("posY")
                return nil
            }
            
            guard let rot = Float(splite[3]) else {
                print("Rotacja")
                return nil
            }
            
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = CGFloat(rot)
            
        case .W:
            print("W")
            guard let f = Int(splite[1]) else {
                print("flaga")
                return nil
            }
            
            guard let posX = Float(splite[2]) else {
                print("posx")
                return nil
            }
            guard let posY = Float(splite[3]) else {
                print("posY")
                return nil
            }
            guard let rot = Float(splite[4]) else {
                print("Rotacja")
                return nil
            }
            
            flag = f
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = CGFloat(rot)
        case .P:
            print("W")
            // P:1:x:y or P:0:x:y - point:collected:x,y
            guard let f = Int(splite[1]) else {
                print("flaga")
                return nil
            }
            
            guard let posX = Float(splite[2]) else {
                print("posx")
                return nil
            }
            guard let posY = Float(splite[3]) else {
                print("posY")
                return nil
            }

            flag = f
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = 0.0
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
