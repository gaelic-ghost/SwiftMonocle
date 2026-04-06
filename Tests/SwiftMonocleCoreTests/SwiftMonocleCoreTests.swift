import Foundation
import Testing
@testable import SwiftMonocleCore

// MARK: - Core snapshot tests

@Test func snapshotPreservesCoreAttachments() async throws {
    let workspace = WorkspaceScope(
        rootPath: "/tmp/SwiftMonocle",
        packageIdentity: "SwiftMonocle"
    )

    let snapshot = CodeScopeSnapshot(
        reason: .userCommand,
        workspace: workspace,
        docs: DocScope(
            directMatches: [
                DocumentReference(
                    title: "PackageDescription",
                    url: "https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html",
                    source: "swiftpm",
                    relevanceScore: 1
                )
            ]
        )
    )

    #expect(snapshot.workspace.packageIdentity == "SwiftMonocle")
    #expect(snapshot.docs.directMatches.count == 1)
    #expect(snapshot.provenance.sources.isEmpty)
}

@Test func fileReferenceDerivesDisplayName() async throws {
    let file = FileReference(path: "/tmp/SwiftMonocle/Sources/SwiftMonocleCore/CodeScopeSnapshot.swift")

    #expect(file.displayName == "CodeScopeSnapshot.swift")
}
