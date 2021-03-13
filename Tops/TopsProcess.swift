//
//  TopsProcess.swift
//  Tops
//
//  Created by Praneet S on 11/03/21.
//

import Foundation
import AppKit

func getCPUUsage() -> Double {
    let process = Process()
    let pipe = Pipe()
    process.standardOutput = pipe
    process.executableURL = URL(fileURLWithPath: "/bin/ps")
    process.arguments = ["-e", "-o", "%cpu"]
    do {
        try process.run()
    } catch {
        print(error)
    }
    guard let cpuUsageData = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) else {
        return 0
    }
    
    let result = Double(cpuUsageData.split(separator: "\n").dropFirst().map({ Float(String($0).trimmingCharacters(in: .whitespaces)) ?? 0 }).reduce(0, +))
    
    return result
}

func getRunningProcesses(policy: NSApplication.ActivationPolicy = .regular) -> [NSRunningApplication] {
    let workspace = NSWorkspace.shared
    let apps = workspace.runningApplications.filter{  $0.activationPolicy == policy }
    return apps
}

func getMemoryStats(pid: pid_t) -> String {
    let process = Process()
    let pipe = Pipe()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/footprint")
    process.standardOutput = pipe
    process.arguments = ["\(pid)"]
    do {
        try process.run()
    } catch {
        print(error)
    }
    let processData = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.split(separator: "\n")
    guard processData != nil else {
        return "System process"
    }
    let memoryInfo = processData?.dropFirst(processData!.count - 4).map({ String($0) })
    guard let memoryInfo_ = memoryInfo else {
        return "System process"
    }
    let detailedMemoryInfo = memoryInfo_[0].split(separator: " ").dropLast().map({ String($0) })
    return "Dirty: \(detailedMemoryInfo[0]) \(detailedMemoryInfo[1])  Clean: \(detailedMemoryInfo[2]) \(detailedMemoryInfo[3])\nReclaimable: \(detailedMemoryInfo[4]) \(detailedMemoryInfo[5])  Regions: \(detailedMemoryInfo[6])"
}
