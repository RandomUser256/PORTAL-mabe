import Foundation

struct DemoRequestCatalog: Decodable {
    let categories: [DemoRequestCategory]

    static let bundled: DemoRequestCatalog = loadBundledCatalog()

    private static func loadBundledCatalog(bundle: Bundle = .main) -> DemoRequestCatalog {
        guard let url = bundle.url(forResource: "dataSet_demo", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(DemoRequestCatalog.self, from: data) else {
            return DemoRequestCatalog(categories: [])
        }

        return catalog
    }
}

struct DemoRequestCategory: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
    let requests: [DemoRequestItem]
}

struct DemoRequestItem: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
}
