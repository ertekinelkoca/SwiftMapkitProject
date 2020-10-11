//
//  ListViewController.swift
//  SwiftMapkitProject
//
//  Created by mac on 11.10.2020.
//

import UIKit
import CoreData

class ListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
   
    
    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self , action: #selector(addButtonClicked))
        
        getData()
    }
    
    func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchrequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchrequest)
            
            if results.count > 0{
                
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
            
                for result in results as! [NSManagedObject] {
                    
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let id = result.value(forKey: "id" ) as? UUID {
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
                
            }
            
            
        } catch {
            print("ListViewController Fetch Request Exception")
        }
       
    }
    
    @objc func addButtonClicked(){
        
        performSegue(withIdentifier:  "toViewController", sender: nil)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
}
