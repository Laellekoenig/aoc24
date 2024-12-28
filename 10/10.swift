import Foundation

guard let input = try? String(contentsOfFile: "input.txt", encoding: .utf8) else {
    fatalError("Could not read file")
}

// Task 1
let map = Map.from(input: input)
print("Trailhead score sum is: \(map.trailheadScoreSum)")

struct Map {
    private static let start = 0
    private static let end = 9

    private let grid: [[Int]]
    private let trailheads: [Point]

    static func from(input: String) -> Map {
        let grid = parseGrid(input)
        let trailheads = getTrailheads(grid)
        return Map(grid: grid, trailheads: trailheads)
    }

    private static func parseGrid(_ input: String) -> [[Int]] {
        input
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { parseLine($0) }
    }

    private static func parseLine(_ line: String) -> [Int] {
        line.map { Int(String($0))! }
    }

    private static func getTrailheads(_ grid: [[Int]]) -> [Point] {
        var heads = [Point]()
        for (i, row) in grid.enumerated() {
            for (j, item) in row.enumerated() where item == start {
                heads.append(Point(x: j, y: i))
            }
        }
        return heads
    }

    var trailheadScoreSum: Int {
        trailheads.reduce(into: 0) { $0 += getTrailheadScore($1) }
    }

    private func getTrailheadScore(_ head: Point) -> Int {
        let visited = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)
        var reached = [Point]()
        trailheadHelper(current: head, visited: visited, reached: &reached)
        return reached.count
    }

    private func trailheadHelper(current: Point, visited: [[Bool]], reached: inout [Point]) {
        var visited = visited
        visited[current] = true

        if grid[current] == Map.end {
            if !reached.contains(current) {
                reached.append(current)
            }
            return
        }

        let candidates = Direction.all.map { current.go(direction: $0) }.filter { isCandidateValid($0) }
        for candidate in candidates where grid[current] + 1 == grid[candidate] {
            trailheadHelper(current: candidate, visited: visited, reached: &reached)
        }
    }

    private func isCandidateValid(_ candidate: Point) -> Bool {
        candidate.x >= 0 && candidate.x < height && candidate.y >= 0 && candidate.y < width
    }

    private var height: Int {
        grid.count
    }

    private var width: Int {
        grid.first!.count
    }
}

struct Point: Equatable {
    let x: Int
    let y: Int

    static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }

    func go(direction: Direction) -> Point {
        switch direction {
        case .up:
            Point(x: x, y: y - 1)

        case .right:
            Point(x: x + 1, y: y)

        case .down:
            Point(x: x, y: y + 1)

        case .left:
            Point(x: x - 1, y: y)
        }
    }
}

enum Direction {
    case up
    case right
    case down
    case left

    static var all: [Direction] {
        [.up, .right, .down, .left]
    }
}

extension Array where Element: MutableCollection, Element.Index == Int {
    subscript(point: Point) -> Element.Element {
        get {
            self[point.y][point.x]
        }
        set {
            self[point.y][point.x] = newValue
        }
    }
}
