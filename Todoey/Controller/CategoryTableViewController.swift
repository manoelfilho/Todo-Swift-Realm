//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Manoel Filho on 14/10/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadItems()
    }

    //MARK: - Modal
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField  = UITextField()
        
        let alert = UIAlertController(title: "Adicione uma nova categoria", message: "💁🏻‍♀️", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Adicionar", style: .default) { (action) in
                
            if ( textField.text != ""){

                DispatchQueue.main.async {
                    let newCategory = Category()
                    newCategory.name = textField.text!

                    self.saveData(category: newCategory)
                    
                    self.tableView.reloadData()
                }
                   
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
    
    //método onde informamos o número de linhas que o TableViewListController deve ter
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        //OBS 1 - Tem relação com a OBS 2
        // categorias podem ser nulas, portanto se nao tiver nada retorna um para o numero de celulas
        return self.categories?.count ?? 1
    
    }
    
    //MARK: - TableView Delegate Methods
    
    //elemento da célula que será exibido a cada passagem do foreach no array de elementos do tablecontroller
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        //OBS 2
        // se nao existir categorias, colocar um alerta na primeira celula
        cell.textLabel?.text = categories?[indexPath.row].name ?? "Nenhuma categoria cadastrada"
        
        return cell
    }
        
    //método executado ao selecionar uma linha do table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //metodo executado antes do performSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationViewController.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //swipe lateral direito trailingSwipeActionsConfigurationForRowAt
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //acao 1
        //podemos adicionar acoes para o swipe lateral aqui
        let trash = UIContextualAction(style: .destructive, title: "Remover") { (action, vieew, completionHandler) in
            
            if let category = self.categories?[indexPath.row] {
                do{
                    try self.realm.write{
                        self.realm.delete(category.items)
                        self.realm.delete(category)
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
    
    //MARK: -  Data
    func loadItems() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
        
    func saveData(category: Category) -> Void {
        do {
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error saving context \(error)")
        }
    }

}
