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
    
    func send(frame: ServerFrame, x: CGFloat, y: CGFloat, r: CGFloat, timestamp: NSTimeInterval)
        -> (x: CGFloat, y: CGFloat, r: CGFloat, beginingFlag: Int, pointX: CGFloat, pointY: CGFloat)? {
            
            var backMessage = String()
            
            if success {
                var message = ":\(uuid):\(x):\(y):\(r)"
                
                switch frame {
                case .M:
                    message = "M\(message):\(timestamp)"
                case .W:
                    message = "W\(message):\(timestamp)"
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

            let (_, x, y, r, beginingFlag, pointX, pointY) = params
            return (x, y, r, beginingFlag, pointX, pointY)
    }

    func send(frame: ServerFrame, x: CGFloat, y: CGFloat, r: CGFloat, pointX: CGFloat, pointY: CGFloat, needNewPoint: Bool, size: CGSize, timestamp: NSTimeInterval)
        -> (x: CGFloat, y: CGFloat, r: CGFloat, beginingFlag: Int, pointX: CGFloat, pointY: CGFloat)? {
        var backMessage = String()
        
        if success {
            var message = ":\(uuid):\(x):\(y):\(r)"
            
            switch frame {
            case .M:
                message = "M\(message):\(timestamp)"
            case .W:
                message = "W\(message):\(timestamp)"
            case .P:
                
                let width = size.width * 7/9
                let height = size.height * 7/9
        
                if needNewPoint {
                    message = "P\(message):\(pointX):\(pointY):1:\(width):\(height):\(timestamp)"
                } else {
                    message = "P\(message):\(pointX):\(pointY):0:\(width):\(height):\(timestamp)"
                }
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
        
        let (_, x, y, r, beginingFlag, pointX, pointY) = params
        return (x, y, r, beginingFlag, pointX, pointY)
    }
    
    private func spliteIncomingMessage(message: String)
        -> (frame: ServerFrame, x: CGFloat, y: CGFloat, r: CGFloat, beginingFlag: Int, pointX: CGFloat, pointY: CGFloat)? {
        
        
        var frame: ServerFrame = .M
        var waiting: Int = 0
        var x, y, r: CGFloat
        var pointPosX: CGFloat = 0.0
        var pointPosY: CGFloat = 0.0
        
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
            
            waiting = f
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = CGFloat(rot)
        case .P:
            print("P")
            guard let posX = Float(splite[1]) else {
                print("posX")
                return nil
            }
            
            guard let posY = Float(splite[2]) else {
                print("posY")
                return nil
            }
            
            guard let rot = Float(splite[3]) else {
                print("rot")
                return nil
            }
            
            guard let pointX = Float(splite[4]) else {
                print("PointX")
                return nil
            }
            
            guard let pointY = Float(splite[5]) else {
                print("PointY")
                return nil
            }

            
            x = CGFloat(posX)
            y = CGFloat(posY)
            r = CGFloat(rot)
            pointPosX = CGFloat(pointX)
            pointPosY = CGFloat(pointY)
        }
        
        return (frame, x, y, r, waiting, pointPosX, pointPosY)
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
