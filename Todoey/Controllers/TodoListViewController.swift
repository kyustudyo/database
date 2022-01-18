//
//  ViewController.swift
//  Todoey
//
//  Created by Angela Yu on 16/11/2017.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import CoreData

let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("my.plist")

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //appdelegate 접근하기 위해서 싱글톤이용 접근. 다운캐스팅.
    //CRUD 의 C
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        //둘다 해줘야함 그리고 순서가 중요.
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        
        saveItems()//변경사항 바로 저장.
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            //Item 클래스는 자동으로 만들어짐.(데이터모델 파일에 만들면)
            //테이블의 row에 해당.
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //원래 loadItems() 였으나,
    //searchBarSearchButtonClicked 을 refactor 하는 과정에서 인자를 받게됨. 따라서 기본 값(default) item.fetchrequest를 준것.
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
            //역시 context 통해서.
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Item> = Item.fetchRequest()
    
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //title이 text를 포함하는지.
        //cd - case, diacitic에 insensitve을 의미.
        //즉 "save"검색 시 온갖 save 출력
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        //순서.
        //배열로 넣어줘야함.
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //뭐썼다가 지웠을때
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
          
        }
    }
}








