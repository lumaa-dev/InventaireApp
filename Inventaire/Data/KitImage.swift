// Made by Lumaa

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct KitImage {
    let data: Data

    init(data: Data) {
        self.data = data
    }

    #if canImport(UIKit)
    var control: UIImage {
        UIImage(data: self.data)!
    }
    #elseif canImport(AppKit)
    var control: NSImage {
        NSImage(data: self.data)!
    }
    #endif
}
