import Foundation

guard let input = try? String(contentsOfFile: "input.txt", encoding: .utf8) else {
    fatalError("Error reading file")
}

// Task 1
var fs = FileSystem.from(input: input)
fs.moveLeft()
print("Checksum is: \(fs.checksum)")

typealias Id = Int

struct FileSystem {
    var memory: [Id?]

    static func from(input: String) -> FileSystem {
        var input = input
        var memory = [Id?]()
        var currentId = 0

        while true {
            guard let nUsed = input.removeFirstAsInt() else {
                break
            }
            for _ in 0..<nUsed {
                memory.append(currentId)
            }
            currentId += 1

            guard let nFree = input.removeFirstAsInt() else {
                break
            }
            for _ in 0..<nFree {
                memory.append(nil)
            }
        }

        return FileSystem(memory: memory)
    }

    mutating func moveLeft() {
        var left = memory.firstIndex { $0 == nil }!
        var right = memory.count - 1

        while left < right, right >= 0, left < memory.count {
            guard let moveItem = memory[right] else {
                right -= 1
                continue
            }

            memory[right] = nil
            memory[left] = moveItem

            right -= 1
            while true {
                left += 1
                if left == memory.count || memory[left] == nil {
                    break
                }
            }
        }
    }

    var checksum: Int {
        memory.enumerated().reduce(into: 0) { sum, e in
            let index = e.0
            if let id = e.1 {
                sum += index * id
            }
        }
    }
}

extension String {
    mutating func removeFirstAsInt() -> Int? {
        if self.isEmpty {
            nil
        } else {
            Int(String(self.removeFirst()))
        }
    }
}
