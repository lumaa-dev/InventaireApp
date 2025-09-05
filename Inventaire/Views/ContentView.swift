// Made by Lumaa

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var searchText: String = ""
    @State private var newIteming: Bool = false
    @State private var itemSelected: Item? = nil
    @State private var itemModifying: Item? = nil

    @State private var tagSelected: Tag? = nil
    @State private var newTagging: Bool = false

    @Query private var items: [Item]
    @Query private var tags: [Tag]

    private var searchItems: [Item] {
        let it: [Item] = tagSelected != nil ? items.filter({ $0.tag == tagSelected }) : items
        return searchText.isEmpty ? it : it.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $itemSelected) {
                if #unavailable(iOS 26.0, macOS 26.0) {
                    topBar
                        .listRowInsets(.init(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                        .listRowSpacing(0.0)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listSectionSpacing(0.0)
                        .listSectionSeparator(.hidden)
                }

                Section {
                    if items.count <= 0 {
                        ContentUnavailableView("no.items", systemImage: "flag.slash", description: Text("no.items.description"))
                    } else if searchItems.count <= 0 && (!searchText.isEmpty || tagSelected != nil) {
                        ContentUnavailableView.search(text: searchText)
                    } else if items.count > 0 {
                        ForEach(searchItems.count > 0 ? searchItems : items) { item in
                            itemRow(item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        guard let i: Int = items.firstIndex(of: item) else { return }

                                        withAnimation {
                                            modelContext.delete(items[i])
                                        }
                                    } label: {
                                        Label("delete", systemImage: "trash.fill")
                                    }
                                    .tint(Color.red)

                                    Button {
                                        self.itemModifying = item
                                    } label: {
                                        Label("edit", systemImage: "pencil")
                                    }
                                    .tint(Color.blue)
                                }
                                .contextMenu {
                                    Button {
                                        self.itemModifying = item
                                    } label: {
                                        Label("item.edit", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        guard let i: Int = items.firstIndex(of: item) else { return }

                                        withAnimation {
                                            modelContext.delete(items[i])
                                        }
                                    } label: {
                                        Label("item.delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .toolbar)
            .navigationTitle(Text("inventory"))
            .navigationBarTitleDisplayMode(.inline)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
#endif
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        self.newIteming.toggle()
                    } label: {
                        Label("new.item", systemImage: "plus")
                    }
                }
            }
            .topExtension {
                topBar
            }
        } detail: {
            #if os(macOS)
            ContentUnavailableView("select.item", systemImage: "cursorarrow.click", description: Text("select.item.splitview"))
            #else
            if let itemSelected {
                AboutItemView(item: itemSelected)
            } else {
                ContentUnavailableView("select.item", systemImage: "sidebar.leading", description: Text("select.item.splitview"))
            }
            #endif
        }
        .sheet(isPresented: $newIteming) {
            NewItemView { newItem in
                guard self.items.count(where: { $0.id == newItem.id }) <= 0 else { return }
                withAnimation {
                    modelContext.insert(newItem)
                }
            }
        }
        .sheet(item: $itemModifying) { item in
            NewItemView(newItem: item) { newItem in
                item.name = newItem.name
                item.location = newItem.location
                item.pictures = newItem.pictures
                item.lastSeen = newItem.lastSeen
                item.tag = newItem.tag
                item.note = newItem.note
            }
        }
        .sheet(isPresented: $newTagging) {
            NewTagView { newTag in
                guard self.tags.count(where: { $0.id == newTag.id }) <= 0 else { return }
                withAnimation {
                    modelContext.insert(newTag)
                }
            }
            .presentationDetents([.height(250)])
            .interactiveDismissDisabled()
        }
    }

    @ViewBuilder
    private func itemRow(_ item: Item) -> some View {
        NavigationLink(value: item) {
            HStack {
                if let firstPic = item.pictures.first {
                    Image(from: .init(data: firstPic))
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 25, maxHeight: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }

                VStack(alignment: .leading) {
                    Text(item.name)

                    if !item.location.isEmpty {
                        Text(item.location)
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func tagRow(_ tag: Tag) -> some View {
        let isSelected: Bool = tag.id == self.tagSelected?.id

        Button {
            withAnimation {
                if isSelected {
                    self.tagSelected = nil
                } else {
                    self.tagSelected = tag
                }
            }
        } label: {
            if #available(iOS 26.0, macOS 26.0, *) {
                Label(tag.name, systemImage: tag.systemImage)
                    .font(.callout)
                    .foregroundStyle(Color.white)
                    .padding(7.5)
                    .glassEffect(.clear.interactive().tint(isSelected ? Color.accentColor : Color.clear), in: .capsule)
            } else {
                Label(tag.name, systemImage: tag.systemImage)
                    .font(.callout)
                    .foregroundStyle(Color.white)
                    .padding(7.5)
                    .background(Capsule().fill(isSelected ? AnyShapeStyle(Color.blue) : AnyShapeStyle(Material.bar)))
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var topBar: some View {
        ScrollView(.horizontal) {
            HStack {
                Button {
                    self.newTagging.toggle()
                } label: {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        Label("create.tag", image: "tag.badge.create")
                            .font(.callout)
                            .foregroundStyle(Color.white)
                            .padding(7.5)
                            .glassEffect(.clear.interactive().tint(Color.green), in: .capsule)
                    } else {
                        Label("create.tag", image: "tag.badge.create")
                            .font(.callout)
                            .foregroundStyle(Color.white)
                            .padding(7.5)
                            .background(Capsule().fill(Color.green))
                    }
                }

                ForEach(tags) { tag in
                    tagRow(tag)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(tag)
                                }
                            } label: {
                                Label("tag.delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .scrollClipDisabled()
    }
}

extension View {
    @ViewBuilder
    func topExtension(content: () -> some View) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.safeAreaBar(edge: .top, content: content)
        } else {
            self
        }
    }
}

extension Image {
    init(from kitImage: KitImage) {
        self.init(kitImage: kitImage.control)
    }

    #if canImport(UIKit)
    init(kitImage: UIImage) {
        self.init(uiImage: kitImage)
    }
    #elseif canImport(AppKit)
    init(kitImage: NSImage) {
        self.init(nsImage: kitImage)
    }
    #endif
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
