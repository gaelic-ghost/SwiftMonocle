import SwiftMonocleCore
import SwiftUI

struct ProjectGraphDashboard: View {
    let model: ProjectGraphModel
    @State private var selectedNodeID: ProjectGraphNode.ID?

    private var selectedNode: ProjectGraphNode {
        model.node(id: selectedNodeID) ?? model.nodes[0]
    }

    var body: some View {
        NavigationSplitView {
            List(model.nodes, selection: $selectedNodeID) { node in
                Label(node.name, systemImage: node.kind.systemImage)
                    .tag(node.id)
            }
            .navigationTitle("Graph")
            .frame(minWidth: 220)
        } content: {
            GraphCanvas(model: model, selectedNodeID: selectedNode.id)
                .navigationTitle("SwiftMonocle")
        } detail: {
            NodeInspector(node: selectedNode, snapshot: model.snapshot)
                .frame(minWidth: 280)
        }
        .onAppear {
            selectedNodeID = selectedNodeID ?? model.nodes.first?.id
        }
    }
}

private struct GraphCanvas: View {
    let model: ProjectGraphModel
    let selectedNodeID: ProjectGraphNode.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Package Dependency Graph")
                .font(.title2.bold())

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 14)], spacing: 14) {
                ForEach(model.nodes) { node in
                    GraphNodeCard(
                        node: node,
                        isSelected: node.id == selectedNodeID
                    )
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Edges")
                    .font(.headline)

                ForEach(model.edges) { edge in
                    Text("\(edge.source) -> \(edge.target)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color.black.opacity(0.92))
    }
}

private struct GraphNodeCard: View {
    let node: ProjectGraphNode
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(node.name, systemImage: node.kind.systemImage)
                .font(.headline)

            Text(node.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(isSelected ? Color.cyan.opacity(0.18) : Color.white.opacity(0.06))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.cyan : Color.neonMagenta.opacity(0.55), lineWidth: 1.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

private extension Color {
    static let neonMagenta = Color(red: 1, green: 0.16, blue: 0.82)
}

private struct NodeInspector: View {
    let node: ProjectGraphNode
    let snapshot: CodeScopeSnapshot

    var body: some View {
        Form {
            Section("Node") {
                LabeledContent("Name", value: node.name)
                LabeledContent("Kind", value: node.kind.label)
                LabeledContent("Source", value: node.sourcePath)
                LabeledContent("Summary", value: node.summary)
            }

            if !node.relatedTests.isEmpty {
                Section("Related Tests") {
                    ForEach(node.relatedTests, id: \.self) { testName in
                        Text(testName)
                    }
                }
            }

            Section("Scope Snapshot") {
                LabeledContent("Package", value: snapshot.workspace.packageIdentity ?? "Unknown")
                LabeledContent("Reason", value: snapshot.reason.rawValue)
                LabeledContent("Actions", value: "\(snapshot.actions.count)")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Inspector")
    }
}
