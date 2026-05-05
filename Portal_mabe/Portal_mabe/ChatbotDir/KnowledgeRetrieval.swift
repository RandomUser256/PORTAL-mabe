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

// MARK: - Employee Database Source
/// Fetches Employee records from SwiftData and returns those relevant to the query.
/// Searches through employee names, roles, departments, and hierarchical relationships.
struct EmployeeDatabaseSource: KnowledgeSource {
    let name = "EmployeeDatabase"

    /// Maximum number of matched results to include in the context.
    var maxResults: Int = 5

    /// Minimum token length to consider as a meaningful keyword.
    private let minTokenLength = 3
    
    /// Common Spanish stopwords to ignore during search
    private let stopwords: Set<String> = [
        "el", "la", "los", "las", "un", "una", "unos", "unas",
        "de", "del", "al", "que", "quien", "quienes", "cual", "cuales",
        "donde", "cuando", "como", "para", "por", "con", "sin",
        "sobre", "entre", "es", "son", "está", "están", "ser", "estar"
    ]
    
    /// Synonyms for common organizational terms
    private let synonymMap: [String: [String]] = [
        "jefe": ["supervisor", "manager", "gerente", "encargado", "chief"],
        "trabajador": ["empleado", "operario", "auxiliar", "worker", "assistant"],
        "departamento": ["área", "sección", "división", "department"],
        "producción": ["production", "manufactura", "manufacturing"],
        "calidad": ["quality", "qa"],
        "mantenimiento": ["maintenance", "mtto"],
        "recursos": ["human", "hr", "rrhh"],
        "humanos": ["human", "hr", "rrhh"]
    ]

    private let context: ModelContext

    init(context: ModelContext, maxResults: Int = 5) {
        self.context = context
        self.maxResults = maxResults
    }

    func fetchRelevantContext(for query: String) async throws -> [String] {
        // ModelContext must be touched on the actor it was created on (MainActor).
        return try await MainActor.run {
            /// --- 1. Tokenize and expand the query with synonyms ---
            let baseTokens = query
                .lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .flatMap { $0.components(separatedBy: .punctuationCharacters) }
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.count >= minTokenLength && !stopwords.contains($0) }
            
            // Expand with synonyms
            var expandedTokens = Set(baseTokens)
            for token in baseTokens {
                if let synonyms = synonymMap[token] {
                    expandedTokens.formUnion(synonyms)
                }
            }
            
            let tokens = Array(expandedTokens)
            guard !tokens.isEmpty else { return [] }

            /// --- 2. Fetch all employees ---
            let employeeDescriptor = FetchDescriptor<Employee>(
                predicate: nil,
                sortBy: [SortDescriptor(\.surname, order: .forward)]
            )
            let allEmployees = try context.fetch(employeeDescriptor)

            /// --- 3. Score each employee by relevance ---
            let scored: [(employee: Employee, score: Int, matchReason: String)] = allEmployees.compactMap { emp in
                let fullName = "\(emp.name) \(emp.middleName ?? "") \(emp.surname) \(emp.second_surname ?? "")".lowercased()
                let roleName = emp.employee_role.name.lowercased()
                let roleDescription = emp.employee_role.role_description.lowercased()
                let departmentName = emp.employee_role.department.name.lowercased()
                let departmentDesc = emp.employee_role.department.department_description.lowercased()
                
                var matchCount = 0
                var reasons: [String] = []
                
                // Check name matches (highest weight)
                let nameMatches = tokens.filter { fullName.contains($0) }.count
                if nameMatches > 0 {
                    matchCount += nameMatches * 5
                    reasons.append("nombre")
                }
                
                // Check role matches (medium-high weight)
                let roleMatches = tokens.filter { roleName.contains($0) || roleDescription.contains($0) }.count
                if roleMatches > 0 {
                    matchCount += roleMatches * 3
                    reasons.append("puesto")
                }
                
                // Check department matches (medium weight)
                let deptMatches = tokens.filter { departmentName.contains($0) || departmentDesc.contains($0) }.count
                if deptMatches > 0 {
                    matchCount += deptMatches * 2
                    reasons.append("departamento")
                }
                
                // Check hierarchical relationships (lower weight but still valuable)
                if let superior = emp.employee_superior.superior {
                    let superiorName = "\(superior.name) \(superior.surname)".lowercased()
                    let superiorMatches = tokens.filter { superiorName.contains($0) }.count
                    if superiorMatches > 0 {
                        matchCount += superiorMatches
                        reasons.append("superior")
                    }
                }

                guard matchCount > 0 else { return nil }
                let reasonText = reasons.joined(separator: ", ")
                return (emp, matchCount, reasonText)
            }

            /// --- 4. Sort by descending relevance, take top N ---
            let topMatches = scored
                .sorted { $0.score > $1.score }
                .prefix(maxResults)

            /// --- 5. Format each employee as a context snippet with hierarchical info ---
            return try topMatches.map { match in
                let emp = match.employee
                let fullName = "\(emp.name) \(emp.surname)"
                let role = emp.employee_role.name
                let department = emp.employee_role.department.name
                
                // Get superior information
                var superiorInfo = "Sin superior registrado"
                if let superior = emp.employee_superior.superior {
                    superiorInfo = "Reporta a: \(superior.name) \(superior.surname) (\(superior.employee_role.name))"
                }
                
                // Get subordinates
                let employeeID = emp.id_employee
                let subordinateDescriptor = FetchDescriptor<Employee_superior>(
                    predicate: #Predicate<Employee_superior> { rel in
                        rel.superior != nil && rel.superior!.id_employee == employeeID
                    }
                )
                let subordinateRelations = try context.fetch(subordinateDescriptor)
                let subordinates = subordinateRelations.compactMap { $0.employee }
                
                var subordinateInfo = "Sin subordinados"
                if !subordinates.isEmpty {
                    let subList = subordinates.map { "\($0.name) \($0.surname) (\($0.employee_role.name))" }.joined(separator: "; ")
                    subordinateInfo = "Supervisa a: \(subList)"
                }
                
                let snippet = """
                Empleado[\(fullName)]:
                - Puesto: \(role)
                - Departamento: \(department)
                - Descripción del rol: \(emp.employee_role.role_description)
                - Email: \(emp.institutional_email)
                - \(superiorInfo)
                - \(subordinateInfo)
                - [Relevancia: \(match.score) puntos - coincidió por \(match.matchReason)]
                """
                
                return snippet
            }
        }
    }
}

// MARK: - Department Database Source
/// Fetches Department records and returns those relevant to the query.
struct DepartmentDatabaseSource: KnowledgeSource {
    let name = "DepartmentDatabase"
    var maxResults: Int = 3
    
    private let minTokenLength = 3
    private let stopwords: Set<String> = [
        "el", "la", "los", "las", "un", "una", "unos", "unas",
        "de", "del", "al", "que", "quien", "quienes"
    ]
    
    private let context: ModelContext
    
    init(context: ModelContext, maxResults: Int = 3) {
        self.context = context
        self.maxResults = maxResults
    }
    
    func fetchRelevantContext(for query: String) async throws -> [String] {
        return try await MainActor.run {
            let tokens = query
                .lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .flatMap { $0.components(separatedBy: .punctuationCharacters) }
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.count >= minTokenLength && !stopwords.contains($0) }
            
            guard !tokens.isEmpty else { return [] }
            
            let descriptor = FetchDescriptor<Department>(
                predicate: nil,
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            let allDepartments = try context.fetch(descriptor)
            
            let scored: [(dept: Department, score: Int)] = allDepartments.compactMap { dept in
                let deptName = dept.name.lowercased()
                let deptDesc = dept.department_description.lowercased()
                
                let nameMatches = tokens.filter { deptName.contains($0) }.count
                let descMatches = tokens.filter { deptDesc.contains($0) }.count
                
                let score = (nameMatches * 3) + descMatches
                guard score > 0 else { return nil }
                return (dept, score)
            }
            
            let topMatches = scored
                .sorted { $0.score > $1.score }
                .prefix(maxResults)
            
            return topMatches.map { match in
                """
                Departamento[\(match.dept.name)]:
                - Descripción: \(match.dept.department_description)
                - ID: \(match.dept.id_department)
                """
            }
        }
    }
}

// MARK: - Request Database Source
/// Fetches Request records and employee request events.
struct RequestDatabaseSource: KnowledgeSource {
    let name = "RequestDatabase"
    var maxResults: Int = 5
    
    private let minTokenLength = 3
    private let stopwords: Set<String> = [
        "el", "la", "los", "las", "un", "una", "unos", "unas",
        "de", "del", "al", "que", "quien", "quienes"
    ]
    
    private let context: ModelContext
    
    init(context: ModelContext, maxResults: Int = 5) {
        self.context = context
        self.maxResults = maxResults
    }
    
    func fetchRelevantContext(for query: String) async throws -> [String] {
        return try await MainActor.run {
            let tokens = query
                .lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .flatMap { $0.components(separatedBy: .punctuationCharacters) }
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.count >= minTokenLength && !stopwords.contains($0) }
            
            guard !tokens.isEmpty else { return [] }
            
            // Fetch request classes
            let classDescriptor = FetchDescriptor<Request_class>(predicate: nil)
            let allClasses = try context.fetch(classDescriptor)
            
            let scoredClasses: [(reqClass: Request_class, score: Int)] = allClasses.compactMap { reqClass in
                let className = reqClass.name.lowercased()
                let classDesc = reqClass.request_class_description.lowercased()
                
                let nameMatches = tokens.filter { className.contains($0) }.count
                let descMatches = tokens.filter { classDesc.contains($0) }.count
                
                let score = (nameMatches * 3) + descMatches
                guard score > 0 else { return nil }
                return (reqClass, score)
            }
            
            // Fetch individual requests
            let requestDescriptor = FetchDescriptor<Requests>(predicate: nil)
            let allRequests = try context.fetch(requestDescriptor)
            
            let scoredRequests: [(request: Requests, score: Int)] = allRequests.compactMap { request in
                let requestName = request.name.lowercased()
                let requestDesc = request.request_description.lowercased()
                
                let nameMatches = tokens.filter { requestName.contains($0) }.count
                let descMatches = tokens.filter { requestDesc.contains($0) }.count
                
                let score = (nameMatches * 3) + descMatches
                guard score > 0 else { return nil }
                return (request, score)
            }
            
            var snippets: [String] = []
            
            // Add top request classes
            let topClasses = scoredClasses
                .sorted { $0.score > $1.score }
                .prefix(2)
            
            snippets += topClasses.map { match in
                """
                Tipo de Solicitud[\(match.reqClass.name)]:
                - Descripción: \(match.reqClass.request_class_description)
                - Departamento: \(match.reqClass.department.name)
                """
            }
            
            // Add top requests
            let topRequests = scoredRequests
                .sorted { $0.score > $1.score }
                .prefix(maxResults - topClasses.count)
            
            snippets += topRequests.map { match in
                """
                Solicitud[\(match.request.name)]:
                - Descripción: \(match.request.request_description)
                - Tipo: \(match.request.request_class.name)
                - Departamento: \(match.request.request_class.department.name)
                - Asignada a: \(match.request.employee.name) \(match.request.employee.surname)
                """
            }
            
            return snippets
        }
    }
}

// MARK: - Workday and Overtime Source
/// Fetches workday schedules and overtime records.
struct WorkScheduleDatabaseSource: KnowledgeSource {
    let name = "WorkScheduleDatabase"
    var maxResults: Int = 5
    
    private let context: ModelContext
    
    init(context: ModelContext, maxResults: Int = 5) {
        self.context = context
        self.maxResults = maxResults
    }
    
    func fetchRelevantContext(for query: String) async throws -> [String] {
        return try await MainActor.run {
            let lowerQuery = query.lowercased()
            
            // Check if query is about schedules, hours, or overtime
            let isScheduleQuery = lowerQuery.contains("horario") || 
                                 lowerQuery.contains("hora") ||
                                 lowerQuery.contains("trabaja") ||
                                 lowerQuery.contains("jornada")
            
            let isOvertimeQuery = lowerQuery.contains("tiempo extra") ||
                                 lowerQuery.contains("horas extra") ||
                                 lowerQuery.contains("overtime")
            
            guard isScheduleQuery || isOvertimeQuery else { return [] }
            
            var snippets: [String] = []
            
            // Extract employee name if present in query
            let tokens = lowerQuery
                .components(separatedBy: .whitespacesAndNewlines)
                .map { $0.trimmingCharacters(in: .punctuationCharacters) }
                .filter { $0.count >= 3 }
            
            if isScheduleQuery {
                let workdayDescriptor = FetchDescriptor<Workday>(predicate: nil)
                let allWorkdays = try context.fetch(workdayDescriptor)
                
                // Group by employee
                let groupedByEmployee = Dictionary(grouping: allWorkdays) { $0.employee.id_employee }
                
                for (_, workdays) in groupedByEmployee.prefix(maxResults) {
                    guard let firstWorkday = workdays.first else { continue }
                    let emp = firstWorkday.employee
                    let empName = "\(emp.name) \(emp.surname)".lowercased()
                    
                    // Check if employee name matches query
                    let matches = tokens.filter { empName.contains($0) }.count
                    guard matches > 0 || tokens.isEmpty else { continue }
                    
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    
                    let schedule = workdays.map { wd in
                        let dayName = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"][wd.weekDay % 7]
                        return "\(dayName): \(formatter.string(from: wd.startTime)) - \(formatter.string(from: wd.endTime))"
                    }.joined(separator: ", ")
                    
                    snippets.append("""
                    Horario[\(emp.name) \(emp.surname)]:
                    - Puesto: \(emp.employee_role.name)
                    - Días laborales: \(schedule)
                    """)
                }
            }
            
            if isOvertimeQuery {
                let overtimeDescriptor = FetchDescriptor<Overtime>(predicate: nil)
                let allOvertime = try context.fetch(overtimeDescriptor).sorted { $0.approved && !$1.approved }
                
                let relevantOvertime = allOvertime.filter { overtime in
                    let empName = "\(overtime.employee.name) \(overtime.employee.surname)".lowercased()
                    let matches = tokens.filter { empName.contains($0) }.count
                    return matches > 0 || tokens.isEmpty
                }.prefix(maxResults)
                
                snippets += relevantOvertime.map { overtime in
                    let dayName = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"][overtime.weekDay % 7]
                    let status = overtime.approved ? "Aprobado" : "Pendiente"
                    let notes = overtime.Notes ?? "Sin notas"
                    
                    return """
                    Tiempo Extra[\(overtime.employee.name) \(overtime.employee.surname)]:
                    - Día: \(dayName)
                    - Horas: \(overtime.hours)
                    - Estado: \(status)
                    - Notas: \(notes)
                    """
                }
            }
            
            return snippets
        }
    }
}

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
