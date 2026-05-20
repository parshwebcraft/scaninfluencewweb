import Foundation

struct ContactProfile: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let designation: String
    let company: String
    let status: String

    var initials: String {
        name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
    }

    static let sarahChen = ContactProfile(
        id: UUID(uuidString: "5C37D795-F724-4AD3-96F6-67C95519DE55")!,
        name: "Sarah Chen",
        designation: "Product Designer",
        company: "Scanfluence",
        status: "Connection Added"
    )
}
