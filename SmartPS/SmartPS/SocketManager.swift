//
//  SocketManager.swift
//  SmartPS
//
//  Created by Princess Lyons on 4/3/17.
//  Copyright © 2017 Princess Lyons. All rights reserved.
//

import UIKit

class SocketManager: NSObject, StreamDelegate {
    
    static let sharedInstance = SocketManager()
    
    //Button
    var buttonConnect : UIButton!
    
    //Label
    var label : UILabel!
    var labelConnection : UILabel!

    //Socket server
    let addr = "10.7.137.31"
    let port = 9876
    
    //Network variables
    var inStream : InputStream?
    var outStream: OutputStream?
    
    //Data received
    var buffer = [UInt8](repeating: 0, count: 200)
    
    
    // Function: sendMessage - send a message
    func sendMessage(message: String) {
        print("Outgoing Message sent")
        let data : NSData = message.data(using: String.Encoding.utf8)! as NSData
        outStream?.write(data.bytes.assumingMemoryBound(to: UInt8.self), maxLength: data.length)
    }
    
    // Function: readMessage - read a message
    func readMessage() {
        print("Incoming message read")
        
        inStream!.read(&buffer, maxLength: buffer.count)
        let bufferStr = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
        print(bufferStr!)
        
    }
    
    // Function: Quit
    func btnQuitPressed(sender: UIButton) {
        let data : NSData = "Quit".data(using: String.Encoding.utf8)! as NSData
        outStream?.write(data.bytes.assumingMemoryBound(to: UInt8.self), maxLength: data.length)
    }
    
    //Network functions
    func NetworkEnable() {
        
        print("NetworkEnable")
        Stream.getStreamsToHost(withName: addr, port: port, inputStream: &inStream, outputStream: &outStream)
        
        inStream?.delegate = self
        outStream?.delegate = self
        
        inStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        inStream?.open()
        outStream?.open()
        
        buffer = [UInt8](repeating: 0, count: 200)
    }
    
    func NetworkDisable(){
        print("NetworkDisable")
        inStream?.close()
        outStream?.close()
    }
    
    // Where in the code is this function used?? - Find
    func stream(aStream: Stream, handleEvent eventCode: Stream.Event) {
        
        switch eventCode {
            case Stream.Event.endEncountered:
                print("EndEncountered")
                inStream?.close()
                inStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                outStream?.close()
                print("Stop outStream currentRunLoop")
                outStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                buttonConnect.alpha = 1
                buttonConnect.isEnabled = true
            
            case Stream.Event.errorOccurred:
                print("ErrorOccurred")
                inStream?.close()
                inStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                outStream?.close()
                outStream?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                buttonConnect.alpha = 1
                buttonConnect.isEnabled = true
            
            case Stream.Event.hasBytesAvailable:
                print("HasBytesAvailable")
                
                if aStream == inStream {
                    inStream!.read(&buffer, maxLength: buffer.count)
                    let bufferStr = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
                    //label.text = bufferStr! as String
                    print(bufferStr!)
                }
                
            case Stream.Event.hasSpaceAvailable:
                print("HasSpaceAvailable")
            //case Stream.Event.None:
            //    print("None")
            case Stream.Event.openCompleted:
                print("OpenCompleted")
            default:
                print("Unknown")
        }
    }
    
    
}
