//
//  LoginView.swift
//  PORTAL mape
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//
import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject private var userSettings: UserSettings
    
    let onContinue: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            header
            profileSection
            dynamicContent
            Spacer(minLength: 24)
            bottomNavigation
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    private var employee: Employee? {
        userSettings.user
    }
    
    private var fullName: String {
        guard let employee else {
            return "Nombre Apellido"
        }
        
        return [
            employee.name,
            employee.middleName,
            employee.surname,
            employee.second_surname
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    }
    
    private var branchAndCountry: String {
        guard let employee else {
            return "SUCURSAL, PAIS"
        }
        
        return "\(employee.employee_role.department.name.uppercased()), MEXICO"
    }
    
    private var roleAndDepartment: String {
        guard let employee else {
            return "EMPLEO, ROL"
        }
        
        return "\(employee.employee_role.name.uppercased()), \(employee.employee_role.department.name.uppercased())"
    }
    
    private var workdayDescription: String {
        guard let employee else {
            return "JORNADA (MATUTINA/VESPERTINA)"
        }
        
        let sortedWorkdays = employee.workdays.sorted { $0.startTime < $1.startTime }
        guard
            let earliest = sortedWorkdays.first?.startTime,
            let latest = sortedWorkdays.first?.endTime
        else {
            return "JORNADA NO DISPONIBLE"
        }
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: earliest)
        let endHour = calendar.component(.hour, from: latest)
        let shift = endHour <= 15 || startHour < 12 ? "MATUTINA" : "VESPERTINA"
        
        return "JORNADA \(shift)"
    }
    
    private var header: some View {
        HStack {
            Text("Perfil")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 34, height: 34)
        }
        .padding(.bottom, 28)
    }
    
    private var profileSection: some View {
        HStack(alignment: .top, spacing: 18) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 92, height: 92)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(.systemGray3))
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(fullName)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(employee.map { "Clave Empleado: \($0.id_employee)" } ?? "Clave Empleado")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(branchAndCountry)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Text(roleAndDepartment)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Text(workdayDescription)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.bottom, 32)
    }
    
    private var dynamicContent: some View {
        VStack(spacing: 18) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemGray5))
                .frame(height: 44)
            
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray3))
                    .frame(width: 88, height: 32)
                
                Spacer(minLength: 0)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray3))
                    .frame(width: 132, height: 32)
            }
            .padding(.horizontal, 8)
            
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray5))
                .frame(height: 240)
        }
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: 32) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 16, height: 16)
            
            Circle()
                .fill(Color(.systemGray3))
                .frame(width: 18, height: 18)
            
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 16, height: 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
    }
}
