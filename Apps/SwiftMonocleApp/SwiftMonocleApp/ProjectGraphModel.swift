import Foundation
import SwiftMonocleCore

struct ProjectGraphModel: Sendable {
    var nodes: [ProjectGraphNode]
    var edges: [ProjectGraphEdge]
    var snapshot: CodeScopeSnapshot

    func node(id: ProjectGraphNode.ID?) -> ProjectGraphNode? {
        guard let id else { return nil }
        return nodes.first { $0.id == id }
    }
}

struct ProjectGraphNode: Sendable, Identifiable, Hashable {
    var id: String { name }
    var name: String
    var kind: ProjectGraphNodeKind
    var summary: String
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
}

struct ProjectGraphEdge: Sendable, Identifiable, Hashable {
    var id: String { "\(source)->\(target)" }
    var source: String
    var target: String
}

extension ProjectGraphModel {
    static let swiftMonocleBootstrap = ProjectGraphModel(
        nodes: [
            ProjectGraphNode(
                name: "SwiftMonocle",
                kind: .product,
                summary: "Umbrella package product for the current code-scope surface."
            ),
            ProjectGraphNode(
                name: "SwiftMonocleCore",
                kind: .libraryTarget,
                summary: "Shared snapshot identity, provenance, references, and scope models."
            ),
            ProjectGraphNode(
                name: "SwiftMonocleCodeScope",
                kind: .libraryTarget,
                summary: "Syntax-backed scope extraction and CodeScopeInput assembly."
            ),
            ProjectGraphNode(
                name: "SwiftMonocleApp",
                kind: .appTarget,
                summary: "macOS app shell for dependency graph and API visualization."
            ),
        ],
        edges: [
            ProjectGraphEdge(source: "SwiftMonocle", target: "SwiftMonocleCodeScope"),
            ProjectGraphEdge(source: "SwiftMonocleCodeScope", target: "SwiftMonocleCore"),
            ProjectGraphEdge(source: "SwiftMonocleApp", target: "SwiftMonocle"),
            ProjectGraphEdge(source: "SwiftMonocleApp", target: "SwiftMonocleCore"),
        ],
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
