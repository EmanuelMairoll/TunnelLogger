//
//  Logfile.swift
//  TunnelLogger
//
//  Created by Emanuel Mairoll on 23.07.18.
//  Copyright © 2018 Emanuel Mairoll. All rights reserved.
//

import Foundation
import CoreLocation

class Logfile {
    let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileUrl:URL
    let startDate:Date
    
    init(filename:String, startDate:Date){
        self.startDate = startDate
        let timestampedFilename = "[\(Logfile.timestamp(for: startDate))] \(filename)"
        var tryfileUrl = documentsDir.appendingPathComponent(timestampedFilename)
        var index = 1
        while FileManager.default.fileExists(atPath: tryfileUrl.path) {
            tryfileUrl = documentsDir.appendingPathComponent("\(timestampedFilename)-\(index)")
            index += 1
        }
        fileUrl = tryfileUrl
        
        do {
            try "".write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
        } catch _ {
        }
        
        print(fileUrl)
    }
    
    func write(location:CLLocation){
        write(message: "#LOCATION \(location.coordinate.latitude) \(location.coordinate.longitude) \(location.altitude) \(location.horizontalAccuracy) \(location.verticalAccuracy) ")
    }
    
    func write(event:TunnelEvent){
        switch event {
        case .EnterTunnel:
            write(message: "#TUNNEL ENTER")
            break
        case .ExitTunnel:
            write(message: "#TUNNEL EXIT")
            break
        case .QuestionMark:
            write(message: "#TUNNEL QM")
            break
        }
    }
    
    func write(message:String){
        do {
            let fileHandle = try FileHandle(forWritingTo: fileUrl)
            let now = Date()
            
            let dateStr = Logfile.timestamp(for: now)
            let secondsPassed = Int(now.timeIntervalSince(startDate))
            
            let timestampedMessage = "[\(dateStr)]-[\(secondsPassed)]-[\(message)]\n"
            let data = timestampedMessage.data(using: .utf8)!
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } catch _ {
        }
    }
    
    func undoLastTunnelEvent() -> TunnelEvent? {
        do {
            let content = try String(contentsOf: fileUrl)
            var lines = content.split(separator: "\n")
            
            guard let lastLineMatching = lines.last(where: { $0.contains("[#TUNNEL ") }) else {
                return nil
            }
            
            guard let index = lines.lastIndex(of: lastLineMatching) else {
                return nil
            }
            
            lines.remove(at: index)
            
            let newContent = lines.joined(separator: "\n") + "\n"
            try newContent.write(to: fileUrl, atomically: true, encoding: .utf8)
            
            let lastPart = lastLineMatching.components(separatedBy: "]-[").last!
            if (lastPart.contains("#TUNNEL ENTER")){
                return .EnterTunnel
            } else if (lastPart.contains("#TUNNEL EXIT")){
                return .ExitTunnel
            } else if (lastPart.contains("#TUNNEL QM")){
                return .QuestionMark
            }
            
        } catch _ {
        }
        return nil
    }
    
    static func timestamp(for date: Date) -> String{
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return String(format:"%02i-%02i-%02i-%02i%02i%02i", day, month, year, hour, minute, second)
    }
    
    public enum TunnelEvent {
        case EnterTunnel
        case ExitTunnel
        case QuestionMark
    }
}
