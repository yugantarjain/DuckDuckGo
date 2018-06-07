//
//  BookmarksViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import UIKit
import Core

class BookmarksViewController: UITableViewController {
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    weak var delegate: BookmarksDelegate?
    
    fileprivate lazy var dataSource = BookmarksDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        addAplicationActiveObserver()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            showEditBookmarkAlert(forIndex: indexPath.row)
        } else {
            selectBookmark(dataSource.bookmark(atIndex: indexPath.row))
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ImportBookmarksViewController {
            controller.delegate = self
        }
    }
    
    private func addAplicationActiveObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationBecameActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
    }
    
    @objc func onApplicationBecameActive(notification: NSNotification) {
        tableView.reloadData()
    }
    
    @IBAction func onActionPressed(_ sender: UIBarButtonItem) {
     
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if !dataSource.isEmpty {
            menu.addAction(menuEditAction())
            menu.addAction(menuExportAction())
        }
        
        menu.addAction(menuImportAction())
        menu.addAction(menuCancelAction())

        present(controller: menu, fromButtonItem: editButtonItem)
    }
    
    private func menuCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel)
    }
    
    private func menuEditAction() -> UIAlertAction {
        return UIAlertAction(title: "Edit", style: .default, handler: { actionButton in
            self.startEditing()
        })
    }
    
    private func menuExportAction() -> UIAlertAction {
        return UIAlertAction(title: "Export", style: .default, handler: { actionButton in
            self.performSegue(withIdentifier: "exportBookmarks", sender: self)
        })
    }

    private func menuImportAction() -> UIAlertAction {
        return UIAlertAction(title: "Import", style: .default, handler: { actionButton in
            self.performSegue(withIdentifier: "importBookmarks", sender: self)
        })
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing && !dataSource.isEmpty {
            finishEditing()
        } else {
            dismiss()
        }
    }
    
    private func startEditing() {
        tableView.isEditing = true
        actionButton.isEnabled = false
    }
    
    private func finishEditing() {
        tableView.isEditing = false
        actionButton.isEnabled = true
    }
    
    fileprivate func showEditBookmarkAlert(forIndex index: Int) {
        let title = UserText.alertEditBookmark
        let bookmark = dataSource.bookmark(atIndex: index)
        let alert = EditBookmarkAlert.buildAlert(
            title: title,
            bookmark: bookmark,
            saveCompletion: { [weak self] (updatedBookmark) in self?.updateBookmark(updatedBookmark, atIndex: index) },
            cancelCompletion: {}
        )
        present(alert, animated: true)
    }
    
    private func updateBookmark(_ updatedBookmark: Link, atIndex index: Int) {
        let bookmarksManager = BookmarksManager()
        bookmarksManager.update(index: index, withBookmark: updatedBookmark)
        tableView.reloadData()
    }
    
    fileprivate func selectBookmark(_ bookmark: Link) {
        dismiss()
        delegate?.bookmarksDidSelect(link:  bookmark)
    }
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }

}

extension BookmarksViewController: ImportBookmarksDelegate {
    
    func finished(controller: ImportBookmarksViewController) {
        tableView.reloadData()
    }
    
}

