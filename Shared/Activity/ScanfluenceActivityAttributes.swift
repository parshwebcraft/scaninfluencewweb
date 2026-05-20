import ActivityKit
import Foundation

struct ScanfluenceActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        enum SavePhase: String, Codable, Hashable {
            case saving
            case saved
        }

        var phase: SavePhase
        var progress: Double
        var statusText: String
        var updatedAt: Date
    }

    var contact: ContactProfile
}
