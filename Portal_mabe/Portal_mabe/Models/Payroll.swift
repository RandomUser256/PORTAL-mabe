//
//  PdfModel.swift
//  Portal_mabe
//
//  Created by Máximo Magallanes Urtuzuástegui on 05/05/26.
//

import Foundation
import UIKit

import TPPDF
import SwiftData

struct ExternalPayrollInfo {
    let companyName: String
    let companyAddress: String
    let companyRFC: String
    let periodStart: Date
    let periodEnd: Date
    let baseSalary: Double
    let isrRate: Double = 0.019 // Example 1.9%
    let socialSecurityRate: Double = 0.062 // Example 6.2%
}

class PayrollPDFGenerator {
    private let employee: Employee
    private let info: ExternalPayrollInfo
    private let document: PDFDocument
    
    init(employee: Employee, info: ExternalPayrollInfo) {
        self.employee = employee
        self.info = info
        self.document = PDFDocument(format: .a4)
    }
    
    func generate() throws -> URL {
        setupLayout()
        addHeaderSection()
        addPeriodInfo()
        addPerceptionsTable()
        addDeductionsTable()
        addTotalsAndFooter()
        
        let generator = PDFGenerator(document: document)
        return try generator.generateURL(filename: "Payroll_\(employee.surname).pdf")
    }
    
    private func setupLayout() {
        document.layout.margin = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
    }
    
    // MARK: - Sections
    
    private func addHeaderSection() {
        let table = PDFTable(rows: 5, columns: 2)
        table.widths = [0.5, 0.5]
        
        // Header Styling
        let headerStyle = PDFTableCellStyle(
            colors: (fill: UIColor(red: 0, green: 0.45, blue: 0.6, alpha: 1.0), text: .white),
            font: .boldSystemFont(ofSize: 10)
        )
        do {
            table[row: 0].style = [headerStyle]
            table[row: 0].allCellsStyle = PDFTableCellStyle(font: .systemFont(ofSize: 8))
            
            try table[0, 0].content = PDFTableContent(content: "NOMBRE DE LA EMPRESA")
            try table[0, 1].content = PDFTableContent(content:"TRABAJADOR")
            
            // Data rows
            try table[1, 0].content = PDFTableContent(content:"Nombre: \(info.companyName)")
            try table[2, 0].content = PDFTableContent(content:"Domicilio: \(info.companyAddress)")
            try table[3, 0].content = PDFTableContent(content:"RFC: \(info.companyRFC)")
            
            try table[1, 1].content = PDFTableContent(content:"Nombre: \(employee.name) \(employee.surname)")
            try table[2, 1].content = PDFTableContent(content:"NSS: \(employee.socialSecurityNumber ?? "N/A")")
            try table[3, 1].content = PDFTableContent(content:"Banco: \(employee.bankNumber)")
        }
        catch {
            fatalError("Error loading information for table \(error.localizedDescription)")
        }
        //table.allCellsStyle = PDFTableCellStyle(font: .systemFont(ofSize: 8))
        document.add(table: table)
    }
    
    private func addPeriodInfo() {
        document.add(space: 10)
        let periodText = "Periodo de liquidación: \(info.periodStart.formatted(date: .abbreviated, time: .omitted)) al \(info.periodEnd.formatted(date: .abbreviated, time: .omitted))"
        document.add(text: periodText)
        document.addLineSeparator(style: PDFLineStyle(type: .full, color: .black, width: 1))
    }
    
    private func addPerceptionsTable() {
        // We calculate rows based on Overtime records in the Employee object
        let overtimeEntries = employee.overtime.filter { $0.approved }
        let totalRows = 2 + overtimeEntries.count // Header + Base Salary + Overtime items
        
        let table = PDFTable(rows: totalRows + 1, columns: 4)
        table.widths = [0.4, 0.2, 0.2, 0.2]
        
        // Table Headers
        table[row: 0].content = ["PERCEPCIONES", "CANTIDAD", "PRECIO", "TOTALES"]
        table[row: 0].allCellsStyle = PDFTableCellStyle(colors: (fill: .lightGray, text: .black), font: .boldSystemFont(ofSize: 9))
        
        // Base Salary
        do {
            try table[1, 0].content = PDFTableContent(content: "Salario Base")
            try table[1, 3].content = PDFTableContent(content: String(format: "$%.2f", info.baseSalary))
        }
        catch {
            fatalError("Error loading base salary information: \(error)")
        }
        // Overtime Perceptions
        var rowTrack = 2
        for entry in overtimeEntries {
            do {
                try table[rowTrack, 0].content = PDFTableContent(content: "Horas extras (Día \(entry.weekDay))")
                try table[rowTrack, 1].content = PDFTableContent(content: "\(entry.hours)")
                try table[rowTrack, 3].content = PDFTableContent(content: "Variable") // Logic depends on your hourly rate
                rowTrack += 1
            }
            catch {
                fatalError("Error loading overtime perception.")
            }
        }
        
        table.showHeadersOnEveryPage = true // Handle page breaks automatically
        document.add(table: table)
    }
    
    private func addDeductionsTable() {
        document.add(space: 10)
        let table = PDFTable(rows: 3, columns: 2)
        table.widths = [0.8, 0.2]
        
        table[row: 0].content = ["DEDUCCIONES", "TOTALES"]
        table[row: 0].allCellsStyle = PDFTableCellStyle(colors: (fill: .lightGray, text: .black), font: .boldSystemFont(ofSize: 9))
        
        let isrAmount = info.baseSalary * info.isrRate
        do {
            try table[1, 0].content = PDFTableContent(content:"Retención ISR (\(info.isrRate * 100)%)")
            try table[1, 1].content = PDFTableContent(content:String(format: "$%.2f", isrAmount))
            
            let imssAmount = info.baseSalary * info.socialSecurityRate
            try table[2, 0].content = PDFTableContent(content:"Seguro Social (\(info.socialSecurityRate * 100)%)")
            try table[2, 1].content = PDFTableContent(content:String(format: "$%.2f", imssAmount))
            
            document.add(table: table)
        }
        catch {
            fatalError("Error loading ISR or IMSS information: \(error.localizedDescription)")
        }
    }
    
    private func addTotalsAndFooter() {
        document.add(space: 20)
        document.add(.contentRight,text: "NETO A RECIBIR: $XXXX.XX")
        
        document.add(space: 50)
        document.add(.contentCenter, text: "__________________________")
        document.add(.contentCenter ,text: "Firma del trabajador")
    }
}
