import Foundation
import SwiftMonocleCore
import SwiftMonocleGraph

struct ProjectGraphModel {
    var nodes: [ProjectGraphNode]
    var edges: [ProjectGraphEdge]
    var snapshot: CodeScopeSnapshot

    init(packageGraph: PackageGraph, snapshot: CodeScopeSnapshot) {
        nodes = packageGraph.nodes.map { node in
            ProjectGraphNode(
                id: node.id.rawValue,
                name: node.name,
                kind: ProjectGraphNodeKind(node.kind),
                sourcePath: node.sourcePath,
                summary: node.summary,
                relatedTests: packageGraph.relatedTests(for: node.id).map(\.name)
            )
        }
        edges = packageGraph.edges.map { edge in
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

struct ProjectGraphNode: Identifiable, Hashable {
    var id: String
    var name: String
    var kind: ProjectGraphNodeKind
    var sourcePath: String
    var summary: String
    var relatedTests: [String]
}

enum ProjectGraphNodeKind: String, CaseIterable {
    case product
    case libraryTarget
    case executableTarget
    case testTarget
    case pluginTarget
    case macroTarget
    case systemTarget
    case binaryTarget
    case appTarget

    var label: String {
        switch self {
            case .product: "Product"
            case .libraryTarget: "Library Target"
            case .executableTarget: "Executable Target"
            case .testTarget: "Test Target"
            case .pluginTarget: "Plugin Target"
            case .macroTarget: "Macro Target"
            case .systemTarget: "System Target"
            case .binaryTarget: "Binary Target"
            case .appTarget: "App Target"
        }
    }

    var systemImage: String {
        switch self {
            case .product: "shippingbox"
            case .libraryTarget: "square.stack.3d.up"
            case .executableTarget: "terminal"
            case .testTarget: "checkmark.seal"
            case .pluginTarget: "puzzlepiece.extension"
            case .macroTarget: "curlybraces"
            case .systemTarget: "gearshape.2"
            case .binaryTarget: "shippingbox.circle"
            case .appTarget: "macwindow"
        }
    }

    init(_ graphKind: PackageGraphNodeKind) {
        switch graphKind {
            case .product: self = .product
            case .libraryTarget: self = .libraryTarget
            case .executableTarget: self = .executableTarget
            case .testTarget: self = .testTarget
            case .pluginTarget: self = .pluginTarget
            case .macroTarget: self = .macroTarget
            case .systemTarget: self = .systemTarget
            case .binaryTarget: self = .binaryTarget
            case .appTarget: self = .appTarget
        }
    }
}

struct ProjectGraphEdge: Identifiable, Hashable {
    var id: String
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

private func qualifiedLabel(for node: PackageGraphNode?, fallback: String) -> String {
    guard let node else { return fallback }

    return "\(node.name) [\(ProjectGraphNodeKind(node.kind).label)]"
}
