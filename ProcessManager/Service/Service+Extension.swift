//
//  Service+Extension.swift
//  ProcessManager
//
//  Created by Hoang Pham on 5.4.2021.
//

import Foundation

extension Service {
    
    // Parse string array to ProcessModel array
    func parse(values: [String]) -> [ProcessModel] {
        return values.dropFirst(1).map { allProcessInfo in
            allProcessInfo.components(separatedBy: .whitespaces).filter { $0 != "" }
        }.map { processInfo in
            ProcessModel(pid: Int(processInfo[1])!,
                         name: processInfo[10],
                         cpuPercentage: Float(processInfo[2])!,
                         memPercentage: Float(processInfo[3])!,
                         time: convertCPUTime(time: processInfo[9]),
                         user: processInfo[0])
        }
    }


    // Convert from "MM:SS.ss" to "HH:MM:SS"
    func convertCPUTime(time: String) -> String {
        let splitTime = time.components(separatedBy: ":")

        guard let strMinutes = splitTime.first,
              let strSeconds = splitTime.last?.components(separatedBy: ".").first,
              let minutes = Int(strMinutes) else {
            return "N/A"
        }

        let shortMinutes = minutes % 60
        let hours = (minutes - shortMinutes) / 60

        return "\(hours):\(shortMinutes):\(strSeconds)"
    }
}
