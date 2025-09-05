// Made by Lumaa

import Foundation
import SwiftData

@Model
final class Tag: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var systemImage: String

    init(id: UUID = UUID(), name: String, systemImage: String = "tag") {
        self.id = id
        self.name = name
        self.systemImage = systemImage
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.systemImage = try container.decode(String.self, forKey: .systemImage)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.systemImage, forKey: .systemImage)
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case systemImage
    }
}
