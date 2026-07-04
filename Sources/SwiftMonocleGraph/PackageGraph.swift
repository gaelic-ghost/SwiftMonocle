import Foundation

// MARK: - Package graph identity

public struct PackageGraphNodeID: Sendable, Codable, Hashable, RawRepresentable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct PackageGraphEdgeID: Sendable, Codable, Hashable, RawRepresentable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - Package graph

public struct PackageGraph: Sendable, Codable, Hashable {
    public var packageIdentity: String
    public var rootPath: String
    public var nodes: [PackageGraphNode]
    public var edges: [PackageGraphEdge]

    public init(
        packageIdentity: String,
        rootPath: String,
        nodes: [PackageGraphNode] = [],
        edges: [PackageGraphEdge] = []
    ) {
        self.packageIdentity = packageIdentity
        self.rootPath = rootPath
        self.nodes = nodes
        self.edges = edges
    }

    public init(
        packageDescription: SwiftPackageDescription,
        rootPath: String? = nil,
        appOverlays: [PackageGraphAppOverlay] = []
    ) {
        let productNodes = packageDescription.products.map { product in
            PackageGraphNode(
                id: .product(product.name),
                name: product.name,
                kind: .product,
                sourcePath: "Package.swift",
                summary: "Package product defined by the SwiftPM manifest."
            )
        }
        let targetNodes = packageDescription.targets.map { target in
            PackageGraphNode(
                id: .target(target.name),
                name: target.name,
                kind: PackageGraphNodeKind(target.type),
                sourcePath: target.path,
                summary: target.summary
            )
        }
        let appNodes = appOverlays.map(\.node)

        let productEdges = packageDescription.products.flatMap { product in
            product.targets.map { target in
                PackageGraphEdge(
                    source: .product(product.name),
                    target: .target(target),
                    kind: .productContainsTarget
                )
            }
        }
        let targetEdges = packageDescription.targets.flatMap { target in
            target.targetDependencies.map { dependency in
                PackageGraphEdge(
                    source: .target(target.name),
                    target: .target(dependency),
                    kind: target.type == .test ? .testTargetTestsTarget : .targetDependsOnTarget
                )
            }
        }
        let appEdges = appOverlays.flatMap { app in
            app.productDependencies.map { product in
                PackageGraphEdge(
                    source: .app(app.name),
                    target: .product(product),
                    kind: .appDependsOnProduct
                )
            }
        }

        self.init(
            packageIdentity: packageDescription.name,
            rootPath: rootPath ?? packageDescription.path,
            nodes: productNodes + targetNodes + appNodes,
            edges: productEdges + targetEdges + appEdges
        )
    }

    public func node(id: PackageGraphNodeID?) -> PackageGraphNode? {
        guard let id else { return nil }

        return nodes.first { $0.id == id }
    }

    public func nodes(kind: PackageGraphNodeKind) -> [PackageGraphNode] {
        nodes.filter { $0.kind == kind }
    }

    public func outgoingEdges(from nodeID: PackageGraphNodeID) -> [PackageGraphEdge] {
        edges.filter { $0.source == nodeID }
    }

    public func relatedTests(for nodeID: PackageGraphNodeID) -> [PackageGraphNode] {
        let testIDs = edges
            .filter { $0.kind == .testTargetTestsTarget && $0.target == nodeID }
            .map(\.source)

        return nodes.filter { testIDs.contains($0.id) }
    }
}

public struct PackageGraphNode: Sendable, Codable, Hashable, Identifiable {
    public var id: PackageGraphNodeID
    public var name: String
    public var kind: PackageGraphNodeKind
    public var sourcePath: String
    public var summary: String

    public init(
        id: PackageGraphNodeID,
        name: String,
        kind: PackageGraphNodeKind,
        sourcePath: String,
        summary: String
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.sourcePath = sourcePath
        self.summary = summary
    }
}

public enum PackageGraphNodeKind: String, Sendable, Codable, Hashable, CaseIterable {
    case product
    case libraryTarget
    case executableTarget
    case testTarget
    case pluginTarget
    case macroTarget
    case systemTarget
    case binaryTarget
    case appTarget

    public init(_ targetType: SwiftPackageTargetType) {
        switch targetType {
            case .library: self = .libraryTarget
            case .executable: self = .executableTarget
            case .test: self = .testTarget
            case .plugin: self = .pluginTarget
            case .macro: self = .macroTarget
            case .system: self = .systemTarget
            case .binary: self = .binaryTarget
        }
    }
}

public struct PackageGraphEdge: Sendable, Codable, Hashable, Identifiable {
    public var id: PackageGraphEdgeID
    public var source: PackageGraphNodeID
    public var target: PackageGraphNodeID
    public var kind: PackageGraphEdgeKind

    public init(
        source: PackageGraphNodeID,
        target: PackageGraphNodeID,
        kind: PackageGraphEdgeKind
    ) {
        id = PackageGraphEdgeID(rawValue: "\(kind.rawValue):\(source.rawValue)->\(target.rawValue)")
        self.source = source
        self.target = target
        self.kind = kind
    }
}

public enum PackageGraphEdgeKind: String, Sendable, Codable, Hashable, CaseIterable {
    case productContainsTarget
    case targetDependsOnTarget
    case testTargetTestsTarget
    case appDependsOnProduct
}

public extension PackageGraphNodeID {
    static func product(_ name: String) -> PackageGraphNodeID {
        PackageGraphNodeID(rawValue: "product:\(name)")
    }

    static func target(_ name: String) -> PackageGraphNodeID {
        PackageGraphNodeID(rawValue: "target:\(name)")
    }

    static func app(_ name: String) -> PackageGraphNodeID {
        PackageGraphNodeID(rawValue: "app:\(name)")
    }
}

public struct PackageGraphAppOverlay: Sendable, Codable, Hashable {
    public var name: String
    public var sourcePath: String
    public var summary: String
    public var productDependencies: [String]

    public var node: PackageGraphNode {
        PackageGraphNode(
            id: .app(name),
            name: name,
            kind: .appTarget,
            sourcePath: sourcePath,
            summary: summary
        )
    }

    public init(
        name: String,
        sourcePath: String,
        summary: String,
        productDependencies: [String]
    ) {
        self.name = name
        self.sourcePath = sourcePath
        self.summary = summary
        self.productDependencies = productDependencies
    }
}

private extension SwiftPackageDescription.Target {
    var summary: String {
        switch type {
            case .library: "SwiftPM library target defined by the package manifest."
            case .executable: "SwiftPM executable target defined by the package manifest."
            case .test: "SwiftPM test target defined by the package manifest."
            case .plugin: "SwiftPM plugin target defined by the package manifest."
            case .macro: "SwiftPM macro target defined by the package manifest."
            case .system: "SwiftPM system library target defined by the package manifest."
            case .binary: "SwiftPM binary target defined by the package manifest."
        }
    }
}
