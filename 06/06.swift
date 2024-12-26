import Foundation

guard let input = try? String(contentsOfFile: "input.txt", encoding: .utf8) else {
    fatalError("Could not read file")
}

// Task 1
var puzzle = Puzzle.from(input: input)
puzzle.walkUntilGuardLeaves()
print("Number of visited fields: \(puzzle.visitedCount)")

struct Puzzle {
    var fields: [[Field]]
    var g: Guard

    static func from(input: String) -> Puzzle {
        let lines = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let fields = lines.reduce(into: []) { $0.append(parseLine(line: $1)) }
        let g = parseGuard(lines: lines)!
        return Puzzle(fields: fields, g: g)
    }

    private static func parseLine(line: String) -> [Field] {
        line.map { parseField($0) }
    }

    private static func parseField(_ char: Character) -> Field {
        switch char {
        case "#":
            .obstacle
        case "^":
            .visited
        default:
            .plain
        }
    }

    private static func parseGuard(lines: [String]) -> Guard? {
        for (i, line) in lines.enumerated() {
            for (j, char) in line.enumerated() where char == "^" {
                return Guard(position: .init(x: j, y: i))
            }
        }
        return nil
    }

    mutating func walkUntilGuardLeaves() {
        while guardIsInBounds {
            let nextPosition = g.nextPosition
            if isInBounds(nextPosition), fields[nextPosition] == .obstacle {
                g.turn()
            }
            fields[g.position] = .visited
            g.walkOneStep()
        }
    }

    private var guardIsInBounds: Bool {
        isInBounds(g.position)
    }

    private func isInBounds(_ pos: Position) -> Bool {
        pos.x >= 0 && pos.x < width && pos.y >= 0 && pos.y < height
    }

    private var height: Int {
        fields.count
    }

    private var width: Int {
        fields.first!.count
    }

    var visitedCount: Int {
        fields.flatMap { $0 }.reduce(into: 0) { $0 += $1 == .visited ? 1 : 0 }
    }
}

enum Field {
    case plain
    case visited
    case obstacle
}

struct Guard {
    var position: Position
    private var direction: Direction = .up

    init(position: Position) {
        self.position = position
    }

    mutating func walkOneStep() {
        position = nextPosition
    }

    var nextPosition: Position {
        direction.getNextPosition(of: position)
    }

    mutating func turn() {
        direction.turn()
    }
}

struct Position {
    let x: Int
    let y: Int
}

enum Direction {
    case up
    case right
    case down
    case left

    func getNextPosition(of pos: Position) -> Position {
        switch self {
        case .up:
            .init(x: pos.x, y: pos.y - 1)
        case .right:
            .init(x: pos.x + 1, y: pos.y)
        case .down:
            .init(x: pos.x, y: pos.y + 1)
        case .left:
            .init(x: pos.x - 1, y: pos.y)
        }
    }

    mutating func turn() {
        switch self {
        case .up:
            self = .right
        case .right:
            self = .down
        case .down:
            self = .left
        case .left:
            self = .up
        }
    }
}

extension [[Field]] {
    subscript(position: Position) -> Field {
        get {
            self[position.y][position.x]
        }
        set {
            self[position.y][position.x] = newValue
        }
    }
}
