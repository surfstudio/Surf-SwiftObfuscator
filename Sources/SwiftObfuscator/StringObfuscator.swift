import Foundation

final class StringObfuscator {

    // MARK: - Constants

    private enum Constants {
        static let multiLineCommentRegex = #"(?<!\/)\/\*((?:(?!\*\/).|\s)*)\*\/"#
        static let singleLineCommentRegex = #"\/\/[^\r\n]*(?:(?<=\\)\r?\n[^\r\n]*)*"#

        static let stringRegex = #"([\"'])(?:(?=(\\?))\2.)*?\1"#

        static let interpolationRegex = #"[^\\]\\\((.*?)\)"#
    }

    // MARK: - Properties

    private let contents: String
    private let salt: String

    private var fullFileRange: NSRange {
        NSRange(location: 0, length: contents.count)
    }

    // MARK: - Initialization

    init(contents: String, salt: String) {
        self.contents = contents
        self.salt = salt
    }

    // MARK: - Internal methods

    func obfuscate(line: Int?) throws -> String {
        let searchRange: NSRange
        if let line = line {
            searchRange = getRange(of: line)
        } else {
            searchRange = fullFileRange
        }

        let commentRanges = try getAllCommentRanges()
        let stringRanges = try getStringRanges(on: searchRange, excluding: commentRanges)
            .sorted(by: {
                $0.lowerBound > $1.lowerBound
            })

        var obfuscatedContents = contents

        for stringRange in stringRanges {
            let start = contents.index(contents.startIndex, offsetBy: stringRange.lowerBound)
            let end = contents.index(contents.startIndex, offsetBy: stringRange.upperBound)
            let range = start..<end
            let rawString = contents[range]
                .dropFirst()
                .dropLast()

            if rawString.isEmpty {
                continue
            }

            let bytes = bytesByObfuscatingString(string: String(rawString))
            let obfuscatedString = "Obfuscator.default.reveal(key: \(bytes)) ?? \"\""

            obfuscatedContents.replaceSubrange(range, with: obfuscatedString)
        }

        return obfuscatedContents
    }

    // MARK: - Private methods

    private func getAllCommentRanges() throws -> [NSRange] {
        let multiLineCommentRegexp = try NSRegularExpression(pattern: Constants.multiLineCommentRegex)
        let singleLineCommentRegexp = try NSRegularExpression(pattern: Constants.singleLineCommentRegex)

        var matches: [NSTextCheckingResult] = []
        matches.append(contentsOf: multiLineCommentRegexp.matches(in: contents, range: fullFileRange))
        matches.append(contentsOf: singleLineCommentRegexp.matches(in: contents, range: fullFileRange))

        return matches.map(\.range)
    }

    private func getStringRanges(on range: NSRange, excluding: [NSRange]) throws -> [NSRange] {
        let stringsRegexp = try NSRegularExpression(pattern: Constants.stringRegex)

        let interpolationRegexp = try NSRegularExpression(pattern: Constants.interpolationRegex)

        return stringsRegexp.matches(in: contents, range: range)
            .map(\.range)
            .filter { stringRange in
                let isInsideExcludiong = !excluding.contains(where: { excludingRange in
                    NSIntersectionRange(stringRange, excludingRange).length > 0 && excludingRange.lowerBound < stringRange.lowerBound
                })

                let string = contents[stringRange]
                let hasInterpolation = interpolationRegexp.matches(in: string, range: NSRange(location: 0, length: string.count)).isEmpty

                return isInsideExcludiong && hasInterpolation
            }
    }

    private func bytesByObfuscatingString(string: String) -> [UInt8] {
        let text = [UInt8](string.utf8)
        let cipher = [UInt8](salt.utf8)
        let length = cipher.count

        var encrypted = [UInt8]()

        for (index, element) in text.enumerated() {
            encrypted.append(element ^ cipher[index % length])
        }

        return encrypted
    }

    private func getRange(of lineNumber: Int) -> NSRange {
        let lineNumber = lineNumber - 1
        let lines = contents.components(separatedBy: .newlines)
        let line = lines[lineNumber]
        let count = lines[..<lineNumber].map(\.count).reduce(0, +) + lineNumber
        return NSRange(location: count, length: line.count)
    }

}

fileprivate extension String {

    subscript(_ range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }

}
