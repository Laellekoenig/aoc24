import Foundation

typealias Matrix = [[Character]]

let input = (try? String(contentsOfFile: "input.txt", encoding: .utf8))!

let wordsearch = Wordsearch(input: input)
// Task 1
print("occurences of XMAS: \(wordsearch.xmasCount)")

// Task 2
print("ocurrences of crossed MAS: \(wordsearch.crossedMasCount)")

struct Wordsearch {
    let input: String

    var xmasCount: Int {
        horizontalCount + verticalCount + diagonalCount
    }

    private var horizontalCount: Int {
        input.countAllOccurencesOfXMas()
    }

    private var verticalCount: Int {
        input.rotate().countAllOccurencesOfXMas()
    }

    private var diagonalCount: Int {
        input.diagonals.reduce(into: 0) { sum, diagonal in
            sum += diagonal.countAllOccurencesOfXMas()
        }
    }

    var crossedMasCount: Int {
        var count = 0
        let matrix = input.toMatrix()

        for i in 1..<matrix.n-1 {
            for j in 1..<matrix.m-1 where isCrossedMas(i: i, j: j, matrix: matrix) {
                count += 1
            }
        }

        return count
    }

    private func isCrossedMas(i: Int, j: Int, matrix: Matrix) -> Bool {
        matrix[i][j] == "A" && checkUp(i: i, j: j, matrix: matrix) && checkDown(i: i, j: j, matrix: matrix)
    }

    private func checkUp(i: Int, j: Int, matrix: Matrix) -> Bool {
        var word = ""
        word.append(matrix[i+1][j-1])
        word.append(matrix[i-1][j+1])
        return word == "MS" || word == "SM"
    }

    private func checkDown(i: Int, j: Int, matrix: Matrix) -> Bool {
        var word = ""
        word.append(matrix[i-1][j-1])
        word.append(matrix[i+1][j+1])
        return word == "MS" || word == "SM"
    }
}

extension String {
    func countAllOccurencesOfXMas() -> Int {
        self.countOcurrances(of: "XMAS") + self.reverseLines().countOcurrances(of: "XMAS")

    }

    private func countOcurrances(of substr: String) -> Int {
        self.components(separatedBy: substr).count - 1
    }

    private func reverseLines() -> String {
        self.components(separatedBy: .newlines).map { String($0.reversed()) }.joined(separator: "\n")
    }

    func toMatrix() -> [[Character]] {
        self.components(separatedBy: .newlines).filter { !$0.isEmpty }.map { Array($0) }
    }

    func rotate() -> String {
        self.toMatrix().rotate().toString()
    }

    var diagonals: [String] {
        var result = [String]()

        let matrix = self.toMatrix()
        for i in 0..<matrix.n {
            for j in 0..<matrix.m {
                if i > 0, j > 0 {
                    continue
                }

                var tmpI = i
                var tmpJ = j
                var line = ""
                while tmpI < matrix.n, tmpJ < matrix.m {
                    line.append(matrix[tmpI][tmpJ])
                    tmpI += 1
                    tmpJ += 1
                }
                result.append(line)
            }
        }

        for i in 0..<matrix.n {
            for j in 0..<matrix.m {
                if i < matrix.n - 1, j > 0 {
                    continue
                }

                var tmpI = i
                var tmpJ = j
                var line = ""
                while tmpI >= 0, tmpJ < matrix.m {
                    line.append(matrix[tmpI][tmpJ])
                    tmpI -= 1
                    tmpJ += 1
                }
                result.append(line)
            }
        }

        return result
    }
}

extension Matrix {
    func toString() -> String {
        self.map { String($0) }.joined(separator: "\n")
    }

    func rotate() -> [[Character]] {
        var result = [[Character]](repeating: [Character](repeating: .init(" "), count: n), count: m)
        for i in 0..<n {
            for j in 0..<m {
                result[j][n - i - 1] = self[i][j]
            }
        }
        return result
    }

    var n: Int {
        self.count
    }

    var m: Int {
        self.first?.count ?? -1
    }
}
