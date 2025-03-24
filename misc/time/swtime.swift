import Foundation

let now = Date()
let timeInterval = now.timeIntervalSince1970
let seconds = Int(timeInterval)
let nanoseconds = Int((timeInterval - Double(seconds)) * 1_000_000_000)
print("\(seconds).\(String(format: "%09d", nanoseconds))")

