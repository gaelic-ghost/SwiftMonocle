import Foundation

// MARK: - File and text references

public struct FileReference: Sendable, Codable, Hashable {
    public var path: String
    public var displayName: String

    public init(path: String, displayName: String? = nil) {
        self.path = path
        self.displayName = displayName ?? URL(fileURLWithPath: path).lastPathComponent
    }
}

public struct TextRange: Sendable, Codable, Hashable {
    public var startLine: Int
    public var startColumn: Int
    public var endLine: Int
    public var endColumn: Int

    public init(startLine: Int, startColumn: Int, endLine: Int, endColumn: Int) {
        self.startLine = startLine
        self.startColumn = startColumn
        self.endLine = endLine
        self.endColumn = endColumn
    }
}

public struct TextSelection: Sendable, Codable, Hashable {
    public var range: TextRange

    public init(range: TextRange) {
        self.range = range
    }
}

public struct TextCursor: Sendable, Codable, Hashable {
    public var line: Int
    public var column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

public struct BufferVersion: Sendable, Codable, Hashable {
    public var value: String

    public init(value: String) {
        self.value = value
    }
}

// MARK: - Project references

public struct TargetReference: Sendable, Codable, Hashable {
    public var name: String

    public init(name: String) {
        self.name = name
    }
}

public struct RelatedFile: Sendable, Codable, Hashable {
    public var file: FileReference
    public var relevanceScore: Double
    public var rationale: String

    public init(file: FileReference, relevanceScore: Double, rationale: String) {
        self.file = file
        self.relevanceScore = relevanceScore
        self.rationale = rationale
    }
}

public struct RelatedTest: Sendable, Codable, Hashable {
    public var name: String
    public var file: FileReference?
    public var relevanceScore: Double
    public var rationale: String

    public init(
        name: String,
        file: FileReference? = nil,
        relevanceScore: Double,
        rationale: String
    ) {
        self.name = name
        self.file = file
        self.relevanceScore = relevanceScore
        self.rationale = rationale
    }
}

// MARK: - Symbol references

public struct SymbolReference: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var kind: SymbolKind
    public var file: FileReference
    public var range: TextRange
    public var detail: String?
    public var relevanceScore: Double

    public init(
        id: UUID = UUID(),
        name: String,
        kind: SymbolKind,
        file: FileReference,
        range: TextRange,
        detail: String? = nil,
        relevanceScore: Double = 0
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.file = file
        self.range = range
        self.detail = detail
        self.relevanceScore = relevanceScore
    }
}

public enum SymbolKind: String, Sendable, Codable, CaseIterable {
    case `struct`
    case `class`
    case actor
    case `enum`
    case `protocol`
    case extensionDecl
    case function
    case initializer
    case property
    case variable
    case typeAlias
    case unknown
}

// MARK: - Diagnostics and docs

public struct DiagnosticRecord: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID
    public var severity: DiagnosticSeverity
    public var message: String
    public var source: String
    public var file: FileReference
    public var range: TextRange?
    public var relevanceScore: Double

    public init(
        id: UUID = UUID(),
        severity: DiagnosticSeverity,
        message: String,
        source: String,
        file: FileReference,
        range: TextRange? = nil,
        relevanceScore: Double = 0
    ) {
        self.id = id
        self.severity = severity
        self.message = message
        self.source = source
        self.file = file
        self.range = range
        self.relevanceScore = relevanceScore
    }
}

public enum DiagnosticSeverity: String, Sendable, Codable, CaseIterable {
    case error
    case warning
    case note
}

public struct DocumentReference: Sendable, Codable, Hashable, Identifiable {
    public var id: UUID
    public var title: String
    public var url: String
    public var source: String
    public var summary: String?
    public var relevanceScore: Double

    public init(
        id: UUID = UUID(),
        title: String,
        url: String,
        source: String,
        summary: String? = nil,
        relevanceScore: Double = 0
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.source = source
        self.summary = summary
        self.relevanceScore = relevanceScore
    }
}
