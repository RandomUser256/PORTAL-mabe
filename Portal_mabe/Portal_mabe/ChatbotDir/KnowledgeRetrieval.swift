import SwiftData
import Foundation
internal import Combine

// MARK: - Knowledge Source Protocol
/// Represents a source capable of returning context snippets relevant to a chat query.
protocol KnowledgeSource {
    /// A human-readable name for the source (for logging/observability)
    var name: String { get }

    /// Returns relevant context snippets for a user query.
    /// Implementations may query databases, perform vector similarity search, etc.
    func fetchRelevantContext(for query: String) async throws -> [String]
}

// MARK: - Medicine Database Source
/// Fetches Medicine records from SwiftData and returns those whose name,
/// description, or ingredient list contain at least one keyword from the query.
/*struct MedicineDatabaseSource: KnowledgeSource {
    let name = "MedicineDatabase"

    /// Maximum number of matched medicines to include in the context.
    var maxResults: Int = 3

    /// Minimum token length to consider as a meaningful keyword.
    private let minTokenLength = 3

    private let context: ModelContext

    init(context: ModelContext, maxResults: Int = 3) {
        self.context = context
        self.maxResults = maxResults
    }

    func fetchRelevantContext(for query: String) async throws -> [String] {
        // ModelContext must be touched on the actor it was created on (MainActor).
        return try await MainActor.run {
            /// --- 1. Tokenise the query ---
            let tokens = query
                .lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .flatMap { $0.components(separatedBy: .punctuationCharacters) }
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.count >= minTokenLength }

            guard !tokens.isEmpty else { return [] }

            /// --- 2. Fetch all medicines, sorted alphabetically (mirrors refreshFromStore) ---
            let descriptor = FetchDescriptor<Medicine>(
                predicate: nil,
                sortBy: [SortDescriptor(\.normalizedName, order: .forward)]
            )
            let allMedicines = try context.fetch(descriptor)

            /// --- 3. Score each medicine by how many tokens match ---
            let scored: [(medicine: Medicine, score: Int)] = allMedicines.compactMap { med in
                let medName        = med.getName().lowercased()
                let medDescription = med.getDescriptionText().lowercased()
                let medIngredients = med.ingredients
                    .map { $0.getName().lowercased() }
                    .joined(separator: " ")

                /// Count distinct tokens that appear in any searchable field
                let matchCount = tokens.filter { token in
                    medName.contains(token)
                    || medDescription.contains(token)
                    || medIngredients.contains(token)
                }.count

                guard matchCount > 0 else { return nil }
                return (med, matchCount)
            }

            /// --- 4. Sort by descending relevance, take top N ---
            let topMatches = scored
                .sorted { $0.score > $1.score }
                .prefix(maxResults)
                .map(\.medicine)

            /// --- 5. Format each medicine as a context snippet ---
            return topMatches.map { med in
                let ingredientList = med.ingredients
                    .map { $0.getName() }
                    .joined(separator: ", ")

                var snippet = "Medicine[\(med.getName())]: \(med.getDescriptionText())."
                if !ingredientList.isEmpty {
                    snippet += " Active ingredients: \(ingredientList)."
                }
                return snippet
            }
        }
    }
}*/

// MARK: - Knowledge Retriever
/// Queries all registered knowledge sources and merges their context snippets for the chat model.
actor KnowledgeRetriever {
    private let sources: [KnowledgeSource]

    /// Stores the retrieval sources that will be queried for each user request.
    init(sources: [KnowledgeSource]) {
        self.sources = sources
    }

    /// Fan-out to all sources in parallel and gather relevant snippets.
    func retrieveContext(for query: String) async -> [String] {
        await withTaskGroup(of: [String].self) { group in
            for source in sources {
                group.addTask {
                    do { return try await source.fetchRelevantContext(for: query) }
                    catch { return [] }
                }
            }

            var aggregated: [String] = []
            for await snippets in group {
                aggregated.append(contentsOf: snippets)
            }
            // Deduplicate and trim
            let unique = Array(Set(aggregated)).sorted()
            return unique
        }
    }
}
