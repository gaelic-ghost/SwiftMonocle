import Foundation

public struct SwiftPackageDescription: Sendable, Codable, Hashable {
    public struct Product: Sendable, Codable, Hashable {
        public var name: String
        public var targets: [String]

        public init(name: String, targets: [String]) {
            self.name = name
            self.targets = targets
        }
    }

    public struct Target: Sendable, Codable, Hashable {
        public var name: String
        public var path: String
        public var type: SwiftPackageTargetType
        public var targetDependencies: [String]
        public var productDependencies: [String]

        public init(
            name: String,
            path: String,
            type: SwiftPackageTargetType,
            targetDependencies: [String] = [],
            productDependencies: [String] = []
        ) {
            self.name = name
            self.path = path
            self.type = type
            self.targetDependencies = targetDependencies
            self.productDependencies = productDependencies
        }

        enum CodingKeys: String, CodingKey {
            case name
            case path
            case type
            case targetDependencies = "target_dependencies"
            case productDependencies = "product_dependencies"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            path = try container.decode(String.self, forKey: .path)
            type = try container.decode(SwiftPackageTargetType.self, forKey: .type)
            targetDependencies = try container.decodeIfPresent([String].self, forKey: .targetDependencies) ?? []
            productDependencies = try container.decodeIfPresent([String].self, forKey: .productDependencies) ?? []
        }
    }

    public var name: String
    public var path: String
    public var products: [Product]
    public var targets: [Target]

    public init(
        name: String,
        path: String,
        products: [Product],
        targets: [Target]
    ) {
        self.name = name
        self.path = path
        self.products = products
        self.targets = targets
    }

    public init(jsonData: Data, decoder: JSONDecoder = JSONDecoder()) throws {
        self = try decoder.decode(Self.self, from: jsonData)
    }
}

public enum SwiftPackageTargetType: String, Sendable, Codable, Hashable, CaseIterable {
    case library
    case executable
    case test
    case plugin
    case macro
    case system = "system-target"
    case binary
}
