//
//  PacketSender.swift
//  Pods
//
//  Created by Jasmin Abou Aldan on 24/04/16.
//
//

import UIKit

protocol PacketSenderDelegate: class {
    func connectionLost()
    func connectionActive()
}

class PacketSender: NSObject, NSStreamDelegate {
    
    var hexapod: Hexapod
    var sendingInterval = 200
    var out: NSOutputStream?
    var openCommunication = true
    var connected = false
    var counter = 0
    weak var delegate: PacketSenderDelegate?
    
    init(hexapod: Hexapod){
        self.hexapod = hexapod
    }
    
    init(hexapod: Hexapod, sendingInterval: Int){
        self.hexapod = hexapod
        self.sendingInterval = sendingInterval
    }

    func startSendingData(){

        //Clear cache if json is saved
        NSURLCache.sharedURLCache().removeAllCachedResponses()

        //Configure for API call to STEMI
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 3
        let session = NSURLSession(configuration: configuration)
        let request = NSURLRequest(URL: NSURL(string: "http://\(self.hexapod.ipAddress)/stemiData.json")!)
        let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in

            //If there is data, try to read it
            if let data = data {
                //Try to read data from json
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    if let valide = jsonData["isValid"] as? Bool {
                        //JSON is OK - start sending data
                        if valide {
                            self.sendData()
                            self.delegate?.connectionActive()
                        } else {
                            self.dropConnection()
                        }
                    }
                }
                //Error with reading data
                catch {
                   self.dropConnection()
                }
            }
            //There is no data on this network -> error
            else {
                self.dropConnection()
            }
        })
        task.resume()
    }

    func stopSendingData(){
        self.openCommunication = false
    }

    private func dropConnection() {
        self.connected = false
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.connectionLost()
        }
        self.stopSendingData()
    }

    private func sendData() {
        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Sending Queue", nil)
        dispatch_async(dataSendQueue, {

            NSStream.getStreamsToHostWithName(self.hexapod.ipAddress, port: self.hexapod.port, inputStream: nil, outputStream: &self.out)

            if let out = self.out {
                out.delegate = self
                out.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                out.open()

                while self.openCommunication == true {

                    NSThread.sleepForTimeInterval(0.2)

                    out.write(self.hexapod.currPacket.toByteArray(), maxLength: self.hexapod.currPacket.toByteArray().count)

                    if out.streamStatus == NSStreamStatus.Open {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.connectionActive()
                        }
                        self.connected = true
                        self.counter = 0
                    } else {
                        self.counter += 1
                        if self.counter == 10 {
                            self.dropConnection()
                            self.counter = 0
                        }
                    }
                }
                
                self.out!.close()
                
            }
            
        })
    }

    @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream == out {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                break
            case NSStreamEvent.OpenCompleted:
                break
            case NSStreamEvent.HasSpaceAvailable:
                break
            default:
                break
            }
        }
    }
}
