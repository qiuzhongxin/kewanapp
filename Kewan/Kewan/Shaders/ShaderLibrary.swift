import SwiftUI

enum ShaderLibrary {
    static let dryIce = Shader(function: .init(
        library: .default,
        name: "fragmentShader"
    ), arguments: [
        .float(0) // time parameter
    ])
} 