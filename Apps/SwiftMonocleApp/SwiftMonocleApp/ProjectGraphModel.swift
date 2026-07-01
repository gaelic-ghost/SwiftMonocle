import Foundation
import SwiftMonocleCore
import SwiftMonocleGraph

struct ProjectGraphModel: Sendable {
    var nodes: [ProjectGraphNode]
    var edges: [ProjectGraphEdge]
    var snapshot: CodeScopeSnapshot

    init(packageGraph: PackageGraph, snapshot: CodeScopeSnapshot) {
        self.nodes = packageGraph.nodes.map { node in
            ProjectGraphNode(
                id: node.id.rawValue,
                name: node.name,
                kind: ProjectGraphNodeKind(node.kind),
                sourcePath: node.sourcePath,
                summary: node.summary,
                relatedTests: packageGraph.relatedTests(for: node.id).map(\.name)
            )
        }
        self.edges = packageGraph.edges.map { edge in
            ProjectGraphEdge(
                id: edge.id.rawValue,
                source: qualifiedLabel(for: packageGraph.node(id: edge.source), fallback: edge.source.rawValue),
                target: qualifiedLabel(for: packageGraph.node(id: edge.target), fallback: edge.target.rawValue)
            )
        }
        self.snapshot = snapshot
    }

    func node(id: ProjectGraphNode.ID?) -> ProjectGraphNode? {
        guard let id else { return nil }
        return nodes.first { $0.id == id }
    }
}

struct ProjectGraphNode: Sendable, Identifiable, Hashable {
    var id: String
    var name: String
    var kind: ProjectGraphNodeKind
    var sourcePath: String
    var summary: String
    var relatedTests: [String]
}

enum ProjectGraphNodeKind: String, Sendable, CaseIterable {
    case product
    case libraryTarget
    case testTarget
    case appTarget

    var label: String {
        switch self {
        case .product: "Product"
        case .libraryTarget: "Library Target"
        case .testTarget: "Test Target"
        case .appTarget: "App Target"
        }
    }

    var systemImage: String {
        switch self {
        case .product: "shippingbox"
        case .libraryTarget: "square.stack.3d.up"
        case .testTarget: "checkmark.seal"
        case .appTarget: "macwindow"
        }
    }

    init(_ graphKind: PackageGraphNodeKind) {
        switch graphKind {
        case .product: self = .product
        case .libraryTarget: self = .libraryTarget
        case .testTarget: self = .testTarget
        case .appTarget: self = .appTarget
        }
    }
}

struct ProjectGraphEdge: Sendable, Identifiable, Hashable {
    var id: String
    var source: String
    var target: String

    init(id: String, source: String, target: String) {
        self.id = id
        self.source = source
        self.target = target
    }
}

extension ProjectGraphModel {
    static let swiftMonocleBootstrap = ProjectGraphModel(
        packageGraph: .swiftMonocleBootstrap,
        snapshot: CodeScopeSnapshot(
            reason: .manualRefresh,
            workspace: WorkspaceScope(
                rootPath: ".",
                packageIdentity: "SwiftMonocle"
            ),
            actions: [
                RecommendedAction(
                    kind: .refreshScope,
                    title: "Generate project graph",
                    rationale: "Replace bootstrap graph data with package-derived graph extraction."
                ),
            ]
        )
    )
}

private func qualifiedLabel(for node: PackageGraphNode?, fallback: String) -> String {
    guard let node else { return fallback }
    return "\(node.name) [\(ProjectGraphNodeKind(node.kind).label)]"
}
