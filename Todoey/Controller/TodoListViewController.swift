//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var items: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            self.loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedCategory?.name
        self.loadItems()
    }

    
    //MARK: - TableViewDataSource Methods
    
    //método onde informamos o número de linhas que o ListController deve ter
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    //elemento da célula que será exibido a cada passagem do foreach no array de elementos do tablecontroller
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = items?[indexPath.row] {
        
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ?
                .checkmark :
                .none
        
        }else{
        
            cell.textLabel?.text = "Nenhum ítem cadastrado"
        
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
        
    //método executado ao selecionasr uma linha do table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("Error saving item \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    //swipe lateral direito trailingSwipeActionsConfigurationForRowAt
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //acao 1
        //podemos adicionar acoes para o swipe lateral aqui
        let trash = UIContextualAction(style: .destructive, title: "Remover") { (action, vieew, completionHandler) in
            
            if let item = self.items?[indexPath.row] {
                do{
                    try self.realm.write{
                        self.realm.delete(item)
                    }
                }catch{
                    print("Error removing item \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])
        
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
        
    }
    
    
    //MARK: -  Add new itens
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField  = UITextField()
        
        let alert = UIAlertController(title: "Adicione um novo item", message: "🤠🤠🤠", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Adicionar", style: .default) { (action) in
            DispatchQueue.main.async {
                
                if let currentCategorySelected = self.selectedCategory {
                    
                    do {
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategorySelected.items.append(newItem)
                        }
                    }catch{
                        print("Error saving new Item \(error)")
                    }
                    
                }
                
                self.tableView.reloadData()
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancelar", style: .destructive) { (action) in
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Informe o item"
            textField = alertTextField
        }
        
        alert.addAction(actionCancel)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: -  Data
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
}

//MARK: -  SearchBar methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            // tirar o foco do componente
            // aqui o comando de tirar o foco é executado em background
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            tableView.reloadData()
        }
    }
    
}

