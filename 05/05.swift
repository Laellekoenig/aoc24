import Foundation

guard let input = try? String(contentsOfFile: "input.txt", encoding: .utf8) else {
    fatalError("Could not read file")
}

let rules = Rule.from(input: input)
let pages = Pages.from(input: input)

// Task 1
let middlePageSum = pages
                        .filter { $0.passesRules(rules) }
                        .reduce(into: 0) { $0 += $1.middlePage }
print("The sum of all valid middle pages: \(middlePageSum)")

// Task 2
let reorderedSum = pages
                        .filter { !$0.passesRules(rules) }

struct Rule {
    let before: Int
    let after: Int

    static func from(input: String) -> [Rule] {
        input
            .split(separator: "\n\n")
            .first?
            .components(separatedBy: .newlines)
            .compactMap { Rule.from(line: $0) } ?? []
    }

    static func from(line: String) -> Rule? {
        let split = line.split(separator: "|")
        if split.count != 2 {
            return nil
        }
        if let first = Int(split.first!), let second = Int(split.last!) {
            return Rule(before: first, after: second)
        }
        return nil
    }
}

struct Pages {
    let pages: [Int]

    static func from(input: String) -> [Pages] {
        input
            .split(separator: "\n\n")
            .last?
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { Pages.from(line: $0) } ?? []
    }

    static func from(line: String) -> Pages {
        Pages(
            pages: line.split(separator: ",").compactMap { Int($0) }
        )
    }

    func passesRules(_ rules: [Rule]) -> Bool {
        rules.first { !passesRule($0) } == nil
    }

    private func passesRule(_ rule: Rule) -> Bool {
        pages.firstIndex(of: rule.before) ?? -1 < pages.firstIndex(of: rule.after) ?? pages.count
    }

    var middlePage: Int {
        pages[pages.count/2]
    }
}
