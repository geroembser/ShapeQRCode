//
//  DebugStopwatch.swift
//  ShapeQRCode iOS
//
//  Created by Gero Embser on 02.09.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//


// TODO: Various different debug stopwatches via identifiers
import Foundation

//MARK: - stopwatch
typealias 🕰 = DebugStopwatch
public enum DebugStopwatch {
    private(set) public static var running: Bool = false
    private(set) public static var started: Bool = false
    
    private static var startTime: DispatchTime?
    
    private static var elapsedTime: UInt64 = 0
}

//MARK: - time information
public extension DebugStopwatch {
    ///The running time in nanoseconds
    ///Indicates how long the stopwatch is running since start (without the paused times)
    public static var runningTime: UInt64 {
        guard let startTime = startTime else {
            return elapsedTime
        }
        
        return DispatchTime.now().uptimeNanoseconds-startTime.uptimeNanoseconds
    }
}

//MARK: - controlling
public extension DebugStopwatch {
    public static func start() {
        startTime = DispatchTime.now()
        running = true
        started = true
    }
    
    public static func pause() {
        guard running else {
            return //already paused
        }
        
        //running -> false
        running = false
        
        //remember the running time
        elapsedTime += runningTime
        
        //reset the startTime
        startTime = nil
    }
    
    ///Equal to reset
    public static func reset() {
        running = false
        started = false
        startTime = nil
        elapsedTime = 0
    }
}

//MARK: - printing running time
public extension DebugStopwatch {
    public enum TimePrintFormat: String {
        case nanoseconds
        case seconds
        case minutes
        case hours
        case days
        case weeks
        
        var string: String {
            return self.rawValue
        }
    }
    
    public static func runningTime(in format: TimePrintFormat) -> TimeInterval{
        switch format {
        case .nanoseconds:  return TimeInterval(runningTime)
        case .seconds:      return TimeInterval(runningTime) * 0.000_000_001
        case .minutes:      return TimeInterval(runningTime) * 0.000_000_001 * 60
        case .hours:        return TimeInterval(runningTime) * 0.000_000_001 * 60 * 60
        case .days:         return TimeInterval(runningTime) * 0.000_000_001 * 60 * 60 * 24
        case .weeks:        return TimeInterval(runningTime) * 0.000_000_001 * 60 * 60 * 24 * 7
        }
    }
    
    public static func printRunningTimeTime(withFormat format: TimePrintFormat = .seconds) {
        let interval = runningTime(in: format)
        print("⏱ running for: \(interval) \(format.string)")
    }
}
