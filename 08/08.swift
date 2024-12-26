import Foundation

guard let input = try? String(contentsOfFile: "input.txt", encoding: .utf8) else {
    fatalError("Failed to read file")
}

// Task 1
var map = Map.from(input: input)
map.determineAntinodes()
print("Number of antinodes: \(map.antinodeCount)")

// Task 2
map.determineAllAntinodes()
print("Number of all antinodes: \(map.antinodeCount)")

struct Map {
    var map: [[LocationType]]
    let antennas: [Antenna]

    static func from(input: String) -> Map {
        let lines = input
                    .components(separatedBy: .newlines)
                    .filter { !$0.isEmpty }

        let map = [[LocationType]](repeating: [LocationType](repeating: .plain, count: lines.first!.count), count: lines.count)
        let antennas = parseAntennas(lines: lines)
        return .init(map: map, antennas: antennas)
    }

    static func parseAntennas(lines: [String]) -> [Antenna] {
        var antennas = [Antenna]()
        for (i, line) in lines.enumerated() {
            for (j, char) in line.enumerated() {
                if let antenna = Antenna.from(char: char, location: .init(x: j, y: i)) {
                    antennas.append(antenna)
                }
            }
        }
        return antennas
    }

    mutating func determineAntinodes() {
        for a in antennas {
            for b in antennas where a != b && a.id == b.id {
                addAntinodes(a, b)
            }
        }
    }

    private mutating func addAntinodes(_ a: Antenna, _ b: Antenna) {
        let (a, b) = a.getAntinodeLocations(to: b)
        if isInBounds(a) {
            map[a] = .antinode
        }
        if isInBounds(b) {
            map[b] = .antinode
        }
    }

    mutating func determineAllAntinodes() {
        for a in antennas {
            for b in antennas where a != b && a.id == b.id {
                addRepeatingAntinodes(a, b)
            }
        }
    }

    private mutating func addRepeatingAntinodes(_ a: Antenna, _ b: Antenna) {
        map[a.location] = .antinode
        map[b.location] = .antinode

        let delta = a.location - b.location
        var newLocation = a.location + delta
        while isInBounds(newLocation) {
            map[newLocation] = .antinode
            newLocation += delta
        }

        newLocation = b.location - delta
        while isInBounds(newLocation) {
            map[newLocation] = .antinode
            newLocation -= delta
        }
    }

    private func isInBounds(_ location: Location) -> Bool {
        location.x >= 0 && location.x < width && location.y >= 0 && location.y < height
    }

    private var height: Int {
        map.count
    }

    private var width: Int {
        map.first!.count
    }

    var antinodeCount: Int {
        map.flatMap { $0 }.filter { $0 == .antinode }.count
    }
}

enum LocationType {
    case plain
    case antinode
}

struct Antenna: Equatable {
    let id: Character
    let location: Location

    static func from(char: Character, location: Location) -> Antenna? {
        if char == "." {
            nil
        } else {
            Antenna(id: char, location: location)
        }
    }

    static func == (a: Antenna, b: Antenna) -> Bool {
        a.id == b.id && a.location == b.location
    }

    func getAntinodeLocations(to other: Antenna) -> (Location, Location) {
        let delta = self.location - other.location
        return (self.location + delta, other.location - delta)
    }
}

struct Location: Equatable {
    var x: Int
    var y: Int

    static func == (a: Location, b: Location) -> Bool {
        a.x == b.x && a.y == b.y
    }

    static func + (a: Location, b: Location) -> Location {
        .init(x: a.x + b.x, y: a.y + b.y)
    }

    static func += (a: inout Location, b: Location) {
        a.x += b.x
        a.y += b.y
    }

    static func - (a: Location, b: Location) -> Location {
        .init(x: a.x - b.x, y: a.y - b.y)
    }

    static func -= (a: inout Location, b: Location) {
        a.x -= b.x
        a.y -= b.y
    }
}

extension [[LocationType]] {
    subscript(location: Location) -> LocationType {
        get {
            self[location.y][location.x]
        }
        set {
            self[location.y][location.x] = newValue
        }
    }
}
