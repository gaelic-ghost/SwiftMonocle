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
    case testTarget
    case appTarget
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
        self.id = PackageGraphEdgeID(rawValue: "\(kind.rawValue):\(source.rawValue)->\(target.rawValue)")
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
