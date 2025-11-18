//
//  ViewController.swift
//  ProcessManager
//
//  Created by Hoang Pham on 29.3.2021.
//

import Cocoa

final class ProcessesVC: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    private var lastSelectedProcess: ProcessModel?

    var processes: [ProcessModel]? {
        willSet {
            tableView.reloadData()
            guard let process = lastSelectedProcess, let index = newValue?.firstIndex(where: { $0.pid == process.pid })
            else { return }
            tableView.selectRowIndexes(IndexSet(arrayLiteral: index), byExtendingSelection: true)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.action = #selector(onRowClicked)
        observingProcessesInfo()
    }


    @IBAction private func killProcess(_ sender: NSButton) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            guard
                let pid = self.lastSelectedProcess?.pid,
                let name = self.lastSelectedProcess?.name
                else { return }
            
            Service.shared.killProcess(pid: pid) { [name] error in
                DispatchQueue.main.async {
                    self.showAlert(error, name)
                }
            }
            self.lastSelectedProcess = nil
        }
    }
    
    
    @objc private func onRowClicked() {
        guard processes?.indices.contains(tableView.selectedRow) ?? false else { return }
        let index = tableView.selectedRow
        lastSelectedProcess = processes?[index]
    }
    
    // observe running processes every 3 seconds
    private func observingProcessesInfo() {
        DispatchQueue.global().async {
            Service.shared.processesInfoOutput(sleep: 3) { [weak self] processes in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.processes = processes
                }
            }
        }
    }
    
    // show error or success alert after killing a process
    private func showAlert(_ error: Error?, _ name: String) {
        let alert = NSAlert()
        if let error = error as? Service.ServiceError {
            switch error {
            case .killError(let message):
                alert.messageText = "Error"
                alert.informativeText = message
                alert.alertStyle = .critical
            }
        } else {
            alert.messageText = "Success"
            alert.informativeText = "Process \(name) was killed successfully"
            alert.alertStyle = .informational
        }
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
