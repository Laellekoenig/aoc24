import Foundation

let input = (try? String(contentsOfFile: "input.txt", encoding: .utf8))!
let reports = input.split(separator: "\n").map { Report(from: String($0)) }

// Task 1
let safeReports = reports.filter { $0.isSafe }
print("number of safe reports: \(safeReports.count)")

// Task 2
let dampenerSafeReports = reports.filter { $0.removeLevelSafe }
print("number of safe reports with the dampener: \(dampenerSafeReports.count)")

struct Report {
    let levels: [Int]

    init(from str: String) {
        assert(!str.isEmpty, "string must not be empty")
        self.levels = str.split(separator: " ").compactMap { Int($0) }
    }

    init(levels: [Int]) {
        self.levels = levels
    }

    var isSafe: Bool {
        if !isIncreasing, !isDecreasing {
            return false
        }

        for (i, j) in zip(levels, levels.dropFirst()) {
            let diff = j - i

            if diff < 0, !isDecreasing {
                return false
            }

            if diff > 1, !isIncreasing {
                return false
            }

            if abs(diff) < 1 || abs(diff) > 3 {
                return false
            }
        }

        return true
    }

    private var isIncreasing: Bool {
        for (i, j) in zip(levels, levels.dropFirst()) {
            if i >= j {
                return false
            }
        }
        return true
    }

    private var isDecreasing: Bool {
        for (i, j) in zip(levels, levels.dropFirst()) {
            if i <= j {
                return false
            }
        }
        return true
    }

    var removeLevelSafe: Bool {
        if isSafe {
            return true
        }

        for i in levels.indices {
            let newLevels = Array(levels[..<i] + levels[(i+1)...])
            if Report(levels: newLevels).isSafe {
                return true
            }
        }

        return false
    }
}
