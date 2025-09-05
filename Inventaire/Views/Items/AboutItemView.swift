// Made by Lumaa

import SwiftUI

struct AboutItemView: View {
    var item: Item

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("item.name", value: item.name)
                        .lineLimit(2)

                    if !item.location.isEmpty {
                        LabeledContent("item.location", value: item.location)
                            .lineLimit(2)
                    }
                }

                Section {
                    LabeledContent(String(localized: "item.last-seen"), value: item.lastSeen, format: .dateTime.day().month().year())
                    if let tag = item.tag {
                        LabeledContent("item.tag", value: tag.name)
                    }
                }

                Section(header: Text("item.photos")) {
                    if item.pictures.isEmpty {
                        #if os(macOS)
                        Text("no.photos")
                        #else
                        ContentUnavailableView("no.photos", systemImage: "camera")
                        #endif
                    } else {
                        ScrollView(.horizontal) {
                            LazyHStack(alignment: .top, spacing: 10.0) {
                                ForEach(item.pictures, id: \.self) { data in
                                    Image(from: .init(data: data))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 225, maxHeight: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                }
                            }
                        }
                    }
                }

                if !item.note.isEmpty {
                    Section(header: Text("item.note")) {
                        Text(item.note)
                            .contextMenu {
                                Button {
                                    #if canImport(AppKit)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.note, forType: .string)
                                    #elseif canImport(UIKit)
                                    UIPasteboard.general.string = item.note
                                    #endif
                                } label: {
                                    Label("copy", systemImage: "document.on.document")
                                }
                            }
                    }
                }
            }
            .navigationTitle(Text(item.name))
        }
    }
}

private extension Color {
    #if canImport(UIKit)
    static let label: Color = Color(uiColor: UIColor.label)
    #elseif canImport(AppKit)
    static let label: Color = Color(nsColor: NSColor.labelColor)
    #endif
}

#Preview {
    AboutItemView(item: .init(name: "Among Us"))
}
