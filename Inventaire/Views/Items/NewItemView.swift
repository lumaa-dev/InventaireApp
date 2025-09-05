// Made by Lumaa

import SwiftUI
import PhotosUI
import SwiftData

struct NewItemView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction

    @Query private var tags: [Tag]

    @State var newItem: Item = .init(name: "")

    #if canImport(UIKit)
    @State private var takingImage: Bool = false
    @State private var choosingImage: Bool = false

    @State private var takenImage: UIImage? = nil
    @State private var chosenImage: PhotosPickerItem? = nil
    #endif

    var onSave: (Item) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("item.name", text: $newItem.name)
                        .autocorrectionDisabled()

                    TextField("item.location", text: $newItem.location)
                        .textContentType(.location)
                        .autocorrectionDisabled()
                }

                Section {
                    DatePicker("item.last-seen", selection: $newItem.lastSeen, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    Picker("item.tag", selection: $newItem.tag) {
                        ForEach(tags) { t in
                            Label(t.name, systemImage: t.systemImage)
                                .tag(t)
                        }
                    }
                    .disabled(tags.isEmpty)
                    .pickerStyle(.navigationLink)
                }

                Section(header: Text("item.photos")) {
                    // menu > photos or camera
                    #if os(macOS)
                    ContentUnavailableView("add.photos.mac", systemImage: "ipad.landscape.and.iphone", description: Text("add.photos.mac.description"))
                        .scrollDisabled(true)
                    #else
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 10.0) {
                            ContentUnavailableView {
                                Label("item.add.photos", systemImage: "photo.badge.plus")
                            } description: {
                                Text("item.add.photos.description")
                            } actions: {
                                Menu {
                                    Button {
                                        self.choosingImage.toggle()
                                    } label: {
                                        Label("photos.library", systemImage: "photo.on.rectangle.angled")
                                    }

                                    Button {
                                        self.takingImage.toggle()
                                    } label: {
                                        Label("photos.camera", systemImage: "camera.fill")
                                    }
                                } label: {
                                    Text("add.photos")
                                }
                                .menuStyle(.borderlessButton)
                            }
                            .frame(width: 270)
                            .imgBg()
                            .onChange(of: self.chosenImage) { _, img in
                                guard let img else { return }

                                img.loadTransferable(type: Data.self) { res in
                                    switch res {
                                        case .success(let success):
                                            self.newItem.pictures.append(success ?? Data())
                                            self.chosenImage = nil
                                        case .failure(let failure):
                                            print(failure)
                                    }
                                }
                            }

                            ForEach(self.newItem.pictures, id: \.self) { data in
                                Image(from: .init(data: data))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 270, alignment: .top)
                                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                                    .imgBg()
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                self.newItem.pictures.removeAll(where: { data == $0 })
                                            }
                                        } label: {
                                            Label("remove", systemImage: "trash.fill")
                                        }

#if canImport(UIKit)
                                        Button {
                                            guard let ui = UIImage(data: data) else { return }
                                            UIImageWriteToSavedPhotosAlbum(ui, nil, nil, nil)
                                        } label: {
                                            Label("save.photo", systemImage: "photo.badge.arrow.down")
                                        }
#endif
                                    }
                            }
                        }
                    }
                    .scrollClipDisabled()
                    .listRowSpacing(0.0)
                    .listRowInsets(.init(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                    .listRowBackground(Color.clear)
                    .photosPicker(
                        isPresented: $choosingImage,
                        selection: $chosenImage,
                        matching: .any(of: [.images, .screenshots])
                    )
                    .sheet(isPresented: $takingImage) {
                        if let image = takenImage {
                            let data: Data = image.pngData() ?? Data()
                            self.newItem.pictures.append(data)

                            takenImage = nil
                        }
                    } content: {
                        CameraView(selectedImage: $takenImage)
                            .ignoresSafeArea()
                    }
                    #endif
                }

                #if os(macOS)
                Section(header: Text("item.note")) {
                    TextField("item.note", text: $newItem.note, axis: .vertical)
                        .frame(height: 300, alignment: .topLeading)
                        .labelsHidden()
                }
                #else
                Section(header: Text("item.note")) {
                    TextField("item.note", text: $newItem.note, axis: .vertical)
                        .frame(height: 300, alignment: .topLeading)
                }
                #endif
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        Button {
                            onSave(self.newItem)
                            dismiss()
                        } label: {
                            Label("create.item", systemImage: "checkmark")
                        }
                        .disabled(newItem.name.isEmpty)
                        .buttonStyle(.glassProminent)
                    } else {
                        Button {
                            onSave(self.newItem)
                            dismiss()
                        } label: {
                            Label("create.item", systemImage: "plus")
                        }
                        .disabled(newItem.name.isEmpty)
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("cancel", systemImage: "xmark")
                    }
                }
            }
            #if os(macOS)
            .padding()
            #endif
        }
    }
}

extension View {
    @ViewBuilder
    func imgBg() -> some View {
        self
            .padding(10.0)
        #if canImport(UIKit)
            .background(Color(uiColor: UIColor.secondarySystemBackground))
        #else
            .background(Color(nsColor: NSColor.windowBackgroundColor))
        #endif
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
}
