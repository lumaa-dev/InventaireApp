// Made by Lumaa

import Foundation
import SwiftData

@Model
final class Item: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var location: String = ""
    var pictures: [Data] = []
    var lastSeen: Date = Date.now
    var note: String = ""
    var tag: Tag?

    init(
        id: String = UUID().uuidString,
        name: String,
        location: String? = nil,
        pngImages: [Data] = [],
        lastSeen: Date = Date.now,
        note: String? = nil,
        tag: Tag? = nil
    ) {
        self.id = id
        self.name = name
        self.location = location ?? ""
        self.pictures = []
        self.lastSeen = lastSeen
        self.note = note ?? ""
        self.tag = tag
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.location, forKey: .location)
        try container.encode(self.pictures, forKey: .pictures)
        try container.encode(self.lastSeen, forKey: .lastSeen)
        try container.encode(self.note, forKey: .note)
        try container.encodeIfPresent(self.tag, forKey: .tag)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.location = try container.decode(String.self, forKey: .location)
        self.pictures = try container.decode([Data].self, forKey: .pictures)
        self.lastSeen = try container.decode(Date.self, forKey: .lastSeen)
        self.note = try container.decode(String.self, forKey: .note)
        self.tag = try container.decodeIfPresent(Tag.self, forKey: .tag)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case location
        case pictures
        case lastSeen
        case note
        case tag
    }
}
