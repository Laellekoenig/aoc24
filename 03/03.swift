import Foundation

let input = (try? String(contentsOfFile: "input.txt", encoding: .utf8))!
let muls = Mul.parse(from: input)

// Task 1
let resultSum = muls.map { $0.result }.reduce(into: 0) { $0 += $1 }
print("Sum of all results is \(resultSum)")

// Task 2
var program = Program(from: input)
print("Sum of all results using dont and do instructions is \(program.execute())")

struct Program {
    var instructions: [Instruction]
    var dont = false
    var sum = 0

    init(from input: String) {
        self.instructions = []
        for dontSplit in input.split(separator: "don't") {
            for doSplit in dontSplit.split(separator: "do") {
                let muls = Mul.parse(from: String(doSplit))
                self.instructions.append(contentsOf: muls)
                self.instructions.append(Do())
            }
            self.instructions.append(Dont())
        }
    }

    mutating func execute() -> Int {
        for instruction in instructions {
            instruction.performAction(program: &self)
        }
        return self.sum
    }
}

protocol Instruction {
    func performAction(program: inout Program)
}

struct Mul: Instruction {
    let a: Int
    let b: Int

    static func parse(from input: String) -> [Mul] {
        input.split(separator: "mul(")
            .flatMap{ $0.split(separator: ")") }
            .compactMap { Mul.from($0) }
    }

    static func from(_ substring: Substring) -> Mul? {
        let list = substring.split(separator: ",")
        if list.count != 2 {
            return nil
        }

        if let a = Int(list.first!), let b = Int(list.last!) {
            return Mul(a: a, b: b)
        }

        return  nil
    }

    var result: Int {
        a * b
    }

    func performAction(program: inout Program) {
        if !program.dont {
            program.sum += result
        }
    }
}

struct Dont: Instruction {
    func performAction(program: inout Program) {
        program.dont = true
    }
}

struct Do: Instruction {
    func performAction(program: inout Program) {
        program.dont = false
    }
}
