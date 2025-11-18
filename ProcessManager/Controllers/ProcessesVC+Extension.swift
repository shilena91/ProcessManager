//
//  ProcessesVC+Extension.swift
//  ProcessManager
//
//  Created by Hoang Pham on 5.4.2021.
//

import Cocoa

extension ProcessesVC: NSTableViewDelegate, NSTableViewDataSource {
    
    private enum CellIdentifiers {
        static let pidCell = "pidCellId"
        static let nameCell = "nameCellId"
        static let cpuCell = "cpuPercentageCellId"
        static let cpuTimeCell = "cpuTimeCellId"
        static let memCell = "memPercentageCellId"
        static let userCell = "userCellId"
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard processes?.indices.contains(row) ?? false, let item = processes?[row] else { return nil }
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.name
            cellIdentifier = CellIdentifiers.nameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = "\(item.cpuPercentage)"
            cellIdentifier = CellIdentifiers.cpuCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = "\(item.time)"
            cellIdentifier = CellIdentifiers.cpuTimeCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = "\(item.memPercentage)"
            cellIdentifier = CellIdentifiers.memCell
        } else if tableColumn == tableView.tableColumns[4] {
            text = "\(item.pid)"
            cellIdentifier = CellIdentifiers.pidCell
        } else if tableColumn == tableView.tableColumns[5] {
            text = "\(item.user)"
            cellIdentifier = CellIdentifiers.userCell
        }
        
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView else { return nil }
        cell.textField?.stringValue = text
        return cell
    }

    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return processes?.count ?? 0
    }
}
