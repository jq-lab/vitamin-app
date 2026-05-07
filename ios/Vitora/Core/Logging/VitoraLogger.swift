import Foundation
import OSLog

enum VitoraLogCategory: String {
    case app
    case navigation
    case persistence
    case privacy
    case ai
}

struct VitoraLogger {
    private let logger: Logger

    init(category: VitoraLogCategory) {
        logger = Logger(subsystem: "com.vitora.app", category: category.rawValue)
    }

    func event(_ name: String, metadata: [String: String] = [:]) {
        let message = Self.sanitizedEvent(name: name, metadata: metadata)
        logger.info("\(message, privacy: .public)")
    }

    static func sanitizedEvent(name: String, metadata: [String: String]) -> String {
        let safeName = sanitize(name)
        let safePairs = metadata
            .map { key, value in "\(sanitize(key))=\(sanitize(value))" }
            .sorted()
            .joined(separator: ",")
        return safePairs.isEmpty ? safeName : "\(safeName) \(safePairs)"
    }

    static func sanitize(_ value: String) -> String {
        let privateTextRedacted = redactPrivatePayloads(value)
        let healthRedacted = redactHealthValues(privateTextRedacted)
        return healthRedacted.count > 120 ? String(healthRedacted.prefix(120)) : healthRedacted
    }

    private static func redactPrivatePayloads(_ value: String) -> String {
        let markers = [
            "rawRecord:",
            "record:",
            "prompt:",
            "aiOutput:",
            "AI output:",
            "完整 AI 输出:",
        ]

        var result = value
        for marker in markers {
            if let range = result.range(of: marker, options: [.caseInsensitive]) {
                let prefix = result[..<range.lowerBound]
                result = "\(prefix)[private-text]"
            }
        }
        return result
    }

    private static func redactHealthValues(_ value: String) -> String {
        var result = value
        let patterns = [
            #"(?i)\d+(\.\d+)?\s*(h|hr|hrs|hour|hours|ms|bpm|%)"#,
            #"\d+(\.\d+)?\s*(小时|分钟|毫秒|次/分)"#,
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                continue
            }
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: "[health-value]"
            )
        }
        return result
    }
}
