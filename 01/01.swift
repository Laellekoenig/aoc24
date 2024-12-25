import Foundation

let input = (try? String(contentsOfFile: "input.txt", encoding: .utf8))!
let (ints1, ints2) = parseInput(input)

// Task 1
let totalDistance = zip(ints1, ints2).reduce(into: 0) { result, tuple in
    result += abs(tuple.0 - tuple.1)
}
print("The sum of total distances is \(totalDistance)")

// Task 2
let counts = ints2.reduce(into: [Int: Int]()) { dict, num in
    dict[num, default: 0] += 1
}
let simScore = ints1
    .map { $0 * counts[$0, default: 0] }
    .reduce(into: 0) { $0 += $1 }
print("The similarity score is \(simScore)")

func parseInput(_ input: String) -> ([Int], [Int]) {
    let split = input
        .split(separator: "\n")
        .map { line in
            let split = line.split(separator: " ")
            return (String(split.first!), String(split.last!))
        }

    let result1 = split.compactMap { Int($0.0) }.sorted()
    let result2 = split.compactMap { Int($0.1) }.sorted()
    assert(result1.count == result2.count, "lists have different lengths")

    return (result1, result2)
}
