import Foundation

guard let input = try? String(contentsOfFile: "input.txt", encoding: .utf8) else {
    fatalError("Could not read file")
}

let equations = Equation.from(input: input)

// Task 1
let calibrationResult = equations.filter { $0.isFeasible }.reduce(into: 0) { $0 += $1.solution }
print("Calibration result is: \(calibrationResult)")

// Task 2
let concatCalibrationResult = equations.filter { $0.isFeasibleWithConcat}.reduce(into: 0) { $0 += $1.solution }
print("Calibration result with concat is: \(concatCalibrationResult)")

struct Equation {
    let solution: Int
    let components: [Int]

    static func from(input: String) -> [Equation] {
        input
            .components(separatedBy: .newlines)
            .compactMap { Equation.from(line: $0) }
    }

    static func from(line: String) -> Equation? {
        let split = line.split(separator: ": ")
        if split.count != 2 {
            return nil
        }

        guard let solution = Int(split.first!) else {
            return nil
        }
        let components = split.last!.components(separatedBy: .whitespaces).compactMap { Int($0) }
        return Equation(solution: solution, components: components)
    }

    var isFeasible: Bool {
        getSolutions().contains(solution)
    }

    var isFeasibleWithConcat: Bool {
        getSolutions(useConcat: true).contains(solution)
    }

    private func getSolutions(useConcat: Bool = false) -> [Int] {
        assert(components.count >= 2, "did not expect only one component")

        var remaining = components
        let a = remaining.removeFirst()
        let b = remaining.removeFirst()

        var solutions = [Int]()
        getSolution(current: a + b, remaining: remaining, solutions: &solutions, useConcat: useConcat)
        getSolution(current: a * b, remaining: remaining, solutions: &solutions, useConcat: useConcat)
        if useConcat {
            getSolution(current: a.concat(b), remaining: remaining, solutions: &solutions, useConcat: useConcat)
        }

        return solutions
    }

    private func getSolution(current: Int, remaining: [Int], solutions: inout [Int], useConcat: Bool) {
        if remaining.isEmpty {
            solutions.append(current)
            return
        }

        var copy = remaining
        let next = copy.removeFirst()
        getSolution(current: current + next, remaining: copy, solutions: &solutions, useConcat: useConcat)
        getSolution(current: current * next, remaining: copy, solutions: &solutions, useConcat: useConcat)
        if useConcat {
            getSolution(current: current.concat(next), remaining: copy, solutions: &solutions, useConcat: useConcat)
        }
    }
}

extension Int {
    func concat(_ other: Int) -> Int {
        self.moveLeft(by: other.digitCount) + other
    }

    private func moveLeft(by offset: Int) -> Int {
        Int(Double(self) * pow(10.0, Double(offset)))
    }

    private var digitCount: Int {
        Int(floor(log10(Double(self)))) + 1
    }
}
