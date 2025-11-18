//
//  Service.swift
//  ProcessManager
//
//  Created by Hoang Pham on 31.3.2021.
//

import Foundation

final class Service {
    
    enum ServiceError: Error {
        case killError(String)
    }
    
    static let shared = Service()
    
    private init() {}
    
    // after every "sleep value", get processess info by "ps aux -c" command and parse string output to ProcessModel
    func processesInfoOutput(sleep value: UInt32, completion: @escaping ([ProcessModel]) -> Void) {
        while (true) {
            request(command: "/bin/ps", arguments: ["aux", "-c"], completion: { [weak self] result in
                guard let self = self else { return }
                completion(self.parse(values: result))
            })
            sleep(value)
        }
    }
    
    
    func killProcess(pid: Int, failure: @escaping (Error?) -> Void) {
        kill(pid: pid, completion: { message in
            !message.isEmpty ? failure(ServiceError.killError(message)) : failure(nil)
        })
    }
    
    // kill a process by its PID, get error output in completion
    private func kill(pid: Int, completion: @escaping (String) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "kill -9 \(pid)"]
        
        let outputPipe = Pipe()
        process.standardError = outputPipe
        do {
            try process.run()
        } catch {
            print(error.localizedDescription)
        }
        
        let outputString = String(decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        completion(outputString)
    }
    
    // run a terminal command and get its output in completion
    private func request(command: String, arguments: [String], completion: @escaping ([String]) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        do {
            try process.run()
        } catch {
            print(error.localizedDescription)
        }
        
        let outputString = String(decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
            .components(separatedBy: .newlines)
            .filter { $0 != "" }
        completion(outputString)
    }
}
