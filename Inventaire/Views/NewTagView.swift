// Made by Lumaa

import SwiftUI
import SwiftData

struct NewTagView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction

    @State private var newTag: Tag = .init(name: "")
    private let onSubmit: (Tag) -> Void

    init(_ tag: Tag = .init(name: ""), onSubmit: @escaping (Tag) -> Void) {
        self.newTag = tag
        self.onSubmit = onSubmit
    }

    var body: some View {
        NavigationStack {
            List {
                TextField("tag.name", text: $newTag.name)
            }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        Button {
                            self.onSubmit(newTag)
                            self.dismiss()
                        } label: {
                            Label("create.tag", systemImage: "checkmark")
                        }
                        .disabled(newTag.name.isEmpty)
                        .buttonStyle(.glassProminent)
                    } else {
                        Button {
                            self.onSubmit(newTag)
                            self.dismiss()
                        } label: {
                            Label("create.tag", image: "tag.badge.plus")
                        }
                        .disabled(newTag.name.isEmpty)
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        self.dismiss()
                    } label: {
                        Label("cancel", systemImage: "xmark")
                    }
                }
            }
        }
    }
}
