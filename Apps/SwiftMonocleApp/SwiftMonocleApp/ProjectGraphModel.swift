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
                source: packageGraph.node(id: edge.source)?.name ?? edge.source.rawValue,
                target: packageGraph.node(id: edge.target)?.name ?? edge.target.rawValue
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
    var id: String { "\(source)->\(target)" }
    var source: String
    var target: String
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
