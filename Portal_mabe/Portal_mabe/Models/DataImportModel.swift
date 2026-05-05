//
//  DataImportModel.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//

import Foundation
import SwiftData

enum DataImportModel {
    enum ImportError: LocalizedError {
        case missingResource(String)
        case missingDepartment(Int)
        case missingEmployeeRole(Int)
        case missingEmployee(Int)
        case missingRequestClass(Int)
        case missingRequest(Int)

        var errorDescription: String? {
            switch self {
            case .missingResource(let resourceName):
                return "Could not find \(resourceName).json in the app bundle."
            case .missingDepartment(let id):
                return "Missing Department relationship for id \(id)."
            case .missingEmployeeRole(let id):
                return "Missing Employee Role relationship for id \(id)."
            case .missingEmployee(let id):
                return "Missing Employee relationship for id \(id)."
            case .missingRequestClass(let id):
                return "Missing Request Class relationship for id \(id)."
            case .missingRequest(let id):
                return "Missing Request relationship for id \(id)."
            }
        }
    }

    static func importIfNeeded(
        into modelContainer: ModelContainer,
        resourceName: String = "dataSet",
        bundle: Bundle = .main
    ) throws {
        let context = ModelContext(modelContainer)
        let employeeCount = try context.fetchCount(FetchDescriptor<Employee>())

        guard employeeCount == 0 else { return }

        try importData(into: context, resourceName: resourceName, bundle: bundle)
    }

    static func importData(
        into context: ModelContext,
        resourceName: String = "dataSet",
        bundle: Bundle = .main
    ) throws {
        let payload = try decodePayload(resourceName: resourceName, bundle: bundle)

        var departmentsByID: [Int: Department] = [:]
        for departmentRecord in payload.departments {
            let department = Department(
                id_department: departmentRecord.id_department,
                name: departmentRecord.name,
                department_description: departmentRecord.department_description
            )
            context.insert(department)
            departmentsByID[departmentRecord.id_department] = department
        }

        var rolesByID: [Int: Employee_roles] = [:]
        for roleRecord in payload.employee_roles {
            guard let department = departmentsByID[roleRecord.id_department] else {
                throw ImportError.missingDepartment(roleRecord.id_department)
            }

            let role = Employee_roles(
                id_employee_role: roleRecord.id_employee_role,
                name: roleRecord.name,
                role_description: roleRecord.role_description,
                department: department
            )
            context.insert(role)
            rolesByID[roleRecord.id_employee_role] = role
        }

        var employeesByID: [Int: Employee] = [:]
        var employeeSuperiorByEmployeeID: [Int: Employee_superior] = [:]
        for employeeRecord in payload.employees {
            guard let role = rolesByID[employeeRecord.id_employee_role] else {
                throw ImportError.missingEmployeeRole(employeeRecord.id_employee_role)
            }

            let employeeSuperior = Employee_superior()
            context.insert(employeeSuperior)

            let employee = Employee(
                id_employee: employeeRecord.id_employee,
                employee_role: role,
                requests: [],
                workdays: [],
                overtime: [],
                employee_superior: employeeSuperior,
                name: employeeRecord.name,
                middleName: employeeRecord.middleName,
                surname: employeeRecord.surname,
                second_surname: employeeRecord.second_surname,
                institutional_email: employeeRecord.institutional_email,
                birthday: employeeRecord.birthday,
                emergency_contact: employeeRecord.emergency_contact,
                phone: employeeRecord.phone,
                socialSecurityNumber: employeeRecord.socialSecurityNumber,
                bankNumber: employeeRecord.bankNumber
            )

            employeeSuperior.employee = employee
            context.insert(employee)

            employeesByID[employeeRecord.id_employee] = employee
            employeeSuperiorByEmployeeID[employeeRecord.id_employee] = employeeSuperior
        }

        for employeeRecord in payload.employees {
            guard let superiorID = employeeRecord.superior_id else { continue }
            guard let employeeSuperior = employeeSuperiorByEmployeeID[employeeRecord.id_employee] else {
                throw ImportError.missingEmployee(employeeRecord.id_employee)
            }
            guard let superior = employeesByID[superiorID] else {
                throw ImportError.missingEmployee(superiorID)
            }

            employeeSuperior.superior = superior
        }

        var requestClassesByID: [Int: Request_class] = [:]
        for requestClassRecord in payload.request_classes {
            guard let department = departmentsByID[requestClassRecord.id_department] else {
                throw ImportError.missingDepartment(requestClassRecord.id_department)
            }

            let requestClass = Request_class(
                id_request_classification: requestClassRecord.id_request_classification,
                name: requestClassRecord.name,
                request_class_description: requestClassRecord.request_class_description,
                department: department
            )
            context.insert(requestClass)
            requestClassesByID[requestClassRecord.id_request_classification] = requestClass
        }

        var requestsByID: [Int: Requests] = [:]
        for requestRecord in payload.requests {
            guard let requestClass = requestClassesByID[requestRecord.id_request_classification] else {
                throw ImportError.missingRequestClass(requestRecord.id_request_classification)
            }
            guard let employee = employeesByID[requestRecord.id_employee] else {
                throw ImportError.missingEmployee(requestRecord.id_employee)
            }

            let request = Requests(
                id_request: requestRecord.id_request,
                name: requestRecord.name,
                request_description: requestRecord.request_description,
                request_class: requestClass,
                employee: employee
            )
            context.insert(request)
            requestsByID[requestRecord.id_request] = request
        }

        for employeeRequestRecord in payload.employee_requests {
            guard let employee = employeesByID[employeeRequestRecord.id_employee] else {
                throw ImportError.missingEmployee(employeeRequestRecord.id_employee)
            }
            guard let request = requestsByID[employeeRequestRecord.id_request] else {
                throw ImportError.missingRequest(employeeRequestRecord.id_request)
            }

            let employeeRequest = Employee_requests(
                id_request_event: employeeRequestRecord.id_request_event,
                employee: employee,
                request: request,
                event_date: employeeRequestRecord.event_date,
                register_date: employeeRequestRecord.register_date,
                amount: employeeRequestRecord.amount
            )
            context.insert(employeeRequest)
        }

        for workdayRecord in payload.workdays {
            guard let employee = employeesByID[workdayRecord.id_employee] else {
                throw ImportError.missingEmployee(workdayRecord.id_employee)
            }

            let workday = Workday(
                employee: employee,
                weekDay: workdayRecord.weekDay,
                startTime: workdayRecord.startTime,
                endTime: workdayRecord.endTime
            )
            context.insert(workday)
        }

        for overtimeRecord in payload.overtime {
            guard let employee = employeesByID[overtimeRecord.id_employee] else {
                throw ImportError.missingEmployee(overtimeRecord.id_employee)
            }

            let overtime = Overtime(
                id_overtime: overtimeRecord.id_overtime,
                weekDay: overtimeRecord.weekDay,
                hours: overtimeRecord.hours,
                approved: overtimeRecord.approved,
                Notes: overtimeRecord.Notes,
                employee: employee
            )
            context.insert(overtime)
        }

        try context.save()
    }

    private static func decodePayload(resourceName: String, bundle: Bundle) throws -> Payload {
        guard let resourceURL = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw ImportError.missingResource(resourceName)
        }

        let data = try Data(contentsOf: resourceURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Payload.self, from: data)
    }
}

private extension DataImportModel {
    struct Payload: Decodable {
        let departments: [DepartmentRecord]
        let employee_roles: [EmployeeRoleRecord]
        let employees: [EmployeeRecord]
        let request_classes: [RequestClassRecord]
        let requests: [RequestRecord]
        let employee_requests: [EmployeeRequestRecord]
        let workdays: [WorkdayRecord]
        let overtime: [OvertimeRecord]
    }

    struct DepartmentRecord: Decodable {
        let id_department: Int
        let name: String
        let department_description: String
    }

    struct EmployeeRoleRecord: Decodable {
        let id_employee_role: Int
        let name: String
        let id_department: Int
        let role_description: String
    }

    struct EmployeeRecord: Decodable {
        let id_employee: Int
        let id_employee_role: Int
        let name: String
        let middleName: String?
        let surname: String
        let second_surname: String?
        let institutional_email: String
        let birthday: Date?
        let emergency_contact: String?
        let phone: String?
        let socialSecurityNumber: String?
        let bankNumber: String
        let superior_id: Int?
    }

    struct RequestClassRecord: Decodable {
        let id_request_classification: Int
        let name: String
        let id_department: Int
        let request_class_description: String
    }

    struct RequestRecord: Decodable {
        let id_request: Int
        let name: String
        let request_description: String
        let id_request_classification: Int
        let id_employee: Int
    }

    struct EmployeeRequestRecord: Decodable {
        let id_request_event: Int?
        let id_employee: Int
        let id_request: Int
        let event_date: Date
        let register_date: Date
        let amount: Int?
    }

    struct WorkdayRecord: Decodable {
        let id_employee: Int
        let weekDay: Int
        let startTime: Date
        let endTime: Date
    }

    struct OvertimeRecord: Decodable {
        let id_overtime: Int
        let weekDay: Int
        let hours: Int
        let approved: Bool
        let Notes: String?
        let id_employee: Int
    }
}
