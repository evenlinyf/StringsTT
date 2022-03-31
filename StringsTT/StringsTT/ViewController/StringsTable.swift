//
//  StringsTable.swift
//  StringsTT
//
//  Created by EvenLin on 2022/3/31.
//

import Cocoa

class StringsTable: NSViewController {
    
    var paths: [String] = []
    
    var tableView: NSTableView = NSTableView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))

    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
}

extension StringsTable: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return paths.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return NSView()
    }
}
