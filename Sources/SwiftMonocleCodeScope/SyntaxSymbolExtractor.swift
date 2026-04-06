import Foundation
import SwiftMonocleCore
import SwiftParser
import SwiftSyntax

// MARK: - Syntax symbol extraction

private typealias ScopeTextRange = SwiftMonocleCore.TextRange

struct SyntaxSymbolExtraction: Sendable {
    var candidates: [SymbolReference]
    var source: ScopeSourceRecord
}

struct SyntaxSymbolExtractor: Sendable {
    func extract(from editor: CodeScopeEditorInput) -> SyntaxSymbolExtraction? {
        guard let bufferText = editor.bufferText, !bufferText.isEmpty else {
            return nil
        }

        let sourceFile = Parser.parse(source: bufferText)
        let converter = SourceLocationConverter(
            fileName: editor.scope.file.path,
            tree: sourceFile
        )
        let focus = focusPosition(in: editor.scope)
        let collector = DeclarationCollector(
            file: editor.scope.file,
            converter: converter,
            focus: focus
        )
        let candidates = collector.collect(from: sourceFile)

        guard !candidates.isEmpty else {
            return nil
        }

        return SyntaxSymbolExtraction(
            candidates: candidates,
            source: ScopeSourceRecord(
                source: .swiftSyntax,
                observedAt: editor.source.observedAt,
                freshness: editor.source.freshness,
                notes: "Derived from the active editor buffer using SwiftSyntax."
            )
        )
    }

    private func focusPosition(in scope: EditorScope) -> TextCursor? {
        if let cursor = scope.cursor {
            return cursor
        }

        return scope.selections.first.map {
            TextCursor(
                line: $0.range.startLine,
                column: $0.range.startColumn
            )
        }
    }
}

private final class DeclarationCollector: SyntaxVisitor {
    private let file: FileReference
    private let converter: SourceLocationConverter
    private let focus: TextCursor?
    private var candidates: [SymbolReference] = []

    init(
        file: FileReference,
        converter: SourceLocationConverter,
        focus: TextCursor?
    ) {
        self.file = file
        self.converter = converter
        self.focus = focus
        super.init(viewMode: .sourceAccurate)
    }

    func collect(from sourceFile: SourceFileSyntax) -> [SymbolReference] {
        walk(sourceFile)
        return deduplicated(candidates)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.name.text,
            kind: .struct,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.name.text,
            kind: .class,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.name.text,
            kind: .actor,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.name.text,
            kind: .enum,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.name.text,
            kind: .protocol,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.extendedType.trimmedDescription,
            kind: .extensionDecl,
            syntax: Syntax(node),
            detail: "extension"
        )
        return .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: node.name.text,
            kind: .function,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        append(
            name: "init",
            kind: .initializer,
            syntax: Syntax(node)
        )
        return .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }

            append(
                name: identifier.identifier.text,
                kind: .variable,
                syntax: Syntax(binding),
                detail: node.bindingSpecifier.text
            )
        }

        return .visitChildren
    }

    private func append(
        name: String,
        kind: SymbolKind,
        syntax: some SyntaxProtocol,
        detail: String? = nil
    ) {
        let range = textRange(for: syntax)

        candidates.append(
            SymbolReference(
                name: name,
                kind: kind,
                file: file,
                range: range,
                detail: detail,
                relevanceScore: relevance(for: range)
            )
        )
    }

    private func textRange(for syntax: some SyntaxProtocol) -> ScopeTextRange {
        let sourceRange = syntax.sourceRange(converter: converter)

        return ScopeTextRange(
            startLine: sourceRange.start.line,
            startColumn: sourceRange.start.column,
            endLine: sourceRange.end.line,
            endColumn: sourceRange.end.column
        )
    }

    private func relevance(for range: ScopeTextRange) -> Double {
        guard let focus else {
            return 0.25
        }

        if contains(range, cursor: focus) {
            let span = max(1, range.endLine - range.startLine)
            let containmentBias = 1.0 / Double(span)
            return 1.0 + containmentBias
        }

        let distance = lineDistance(from: focus, to: range)
        return max(0.05, 0.7 - (Double(distance) * 0.05))
    }

    private func contains(_ range: ScopeTextRange, cursor: TextCursor) -> Bool {
        let afterStart =
            cursor.line > range.startLine ||
            (cursor.line == range.startLine && cursor.column >= range.startColumn)
        let beforeEnd =
            cursor.line < range.endLine ||
            (cursor.line == range.endLine && cursor.column <= range.endColumn)

        return afterStart && beforeEnd
    }

    private func lineDistance(from focus: TextCursor, to range: ScopeTextRange) -> Int {
        if contains(range, cursor: focus) {
            return 0
        }

        if focus.line < range.startLine {
            return range.startLine - focus.line
        }

        return focus.line - range.endLine
    }

    private func deduplicated(_ candidates: [SymbolReference]) -> [SymbolReference] {
        var seen: Set<String> = []
        var unique: [SymbolReference] = []

        for candidate in candidates {
            let key = [
                candidate.file.path,
                candidate.name,
                candidate.kind.rawValue,
                "\(candidate.range.startLine)",
                "\(candidate.range.startColumn)",
                "\(candidate.range.endLine)",
                "\(candidate.range.endColumn)",
            ].joined(separator: "|")

            if seen.insert(key).inserted {
                unique.append(candidate)
            }
        }

        return unique
    }
}
