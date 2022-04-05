//
//  Logger.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 05.04.2022.
//

import Foundation

enum Logger {
    enum LogLevel {
        case info
        case warning
        case error
        
        fileprivate var prefix: String {
            switch self {
            case .info:
                return "INFO ℹ️"
            case .warning:
                return "WARNING ⚠️"
            case .error:
                return "ERROR ❌"
            }
        }
    }
    
    struct LogContext {
        let file: String
        let function: String
        let line: Int
        var description: String {
            "\((file as NSString).lastPathComponent): \(line) \(function)"
        }
    }
    
    static func info(
        _ str: String,
        showInConsole: Bool? = true,
        shouldLogContext: Bool? = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logContext = LogContext(
            file: file,
            function: function,
            line: line
        )
        
        Logger.handleLog(
            level: .info,
            str: str,
            showInConsole: showInConsole ?? false,
            shouldLogContext: shouldLogContext ?? false,
            context: logContext
        )
    }
    
    static func warning(
        _ str: String,
        showInConsole: Bool? = true,
        shouldLogContext: Bool? = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logContext = LogContext(
            file: file,
            function: function,
            line: line
        )
        
        Logger.handleLog(
            level: .warning,
            str: str,
            showInConsole: showInConsole ?? false,
            shouldLogContext: shouldLogContext ?? false,
            context: logContext
        )
    }
    
    static func error(
        _ str: String,
        showInConsole: Bool? = true,
        shouldLogContext: Bool? = true,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logContext = LogContext(
            file: file,
            function: function,
            line: line
        )
        
        Logger.handleLog(
            level: .error,
            str: str,
            showInConsole: showInConsole ?? false,
            shouldLogContext: shouldLogContext ?? false,
            context: logContext
        )
    }
    
    fileprivate static func handleLog(
        level: LogLevel,
        str: String,
        showInConsole: Bool,
        shouldLogContext: Bool,
        context: LogContext
    ) {
        let logComponents = ["[\(level.prefix)]", str]
        
        var fullString = logComponents.joined(separator: " ")
        
        if showInConsole {
            if shouldLogContext {
                fullString += " -> \(context.description)"
            }
            
            printDebug(fullString)
        }
    }
}
