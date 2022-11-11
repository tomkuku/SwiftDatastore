//
//  Logger.swift
//  DatabaseApi
//
//  Created by Tomasz Kukułka on 08/03/2022.
//

import Foundation
import os.log

final class Logger {
    private enum Emoji: String {
        case debug = "ℹ️"
        case error = "⚠️"
        case fatal = "⛔️"
    }
    
    private var isDebug: Bool {
        #if DEBUG
            true
        #else
            false
        #endif
    }
    
    private let logging = OSLog(subsystem: "database.api", category: "basic")
    
    static let log = Logger()
    
    private init() { }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard isDebug else {
            return
        }
        
        let emoji = Emoji.debug.rawValue
        let fileName = file.fileName
        os_log("\n%@ %@ %@:%d:\n %@", log: logging, type: .debug, emoji, fileName, function, line, message)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let emoji = isDebug ? Emoji.error.rawValue : ""
        let fileName = file.fileName
        os_log("\n%@ %@ %@:%d:\n %@", log: logging, type: .debug, emoji, fileName, function, line, message)
    }
    
    func fatal(_ message: String, file: String = #file, function: String = #function, line: Int = #line) -> Never {
        let emoji = isDebug ? Emoji.fatal.rawValue : ""
        let fileName = file.fileName
        os_log("\n%@ %@ %@:%d:\n %@", log: logging, type: .debug, emoji, fileName, function, line, message)
        fatalError("")
    }
}

fileprivate extension String {
    var fileName: String {
        (self as NSString).lastPathComponent
    }
}
