//
//  History.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//

import UIKit
import Foundation
import CoreLocation

class History: UITableViewController {
    
    @IBOutlet var histListTable: UITableView!
    // TODO: Set up 3 different table cells
    // TODO: Have these buttons link to another segue
    // TODO: save the interaction to historylist
    // TODO: retrieve list from historyList
    // TODO: reverse geocoding para safe
    
    // MARK: -  globals
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    var historyList : [HistoryList]?;
    
    // MARK: - Enums
    enum CoreDataError: Error {
        case insertError;
        case fetchError;
        case deleteError;
    }
    
//    enum SourceModules {
//        case main;
//        case history;
//        case news;
//        case weather;
//        case directions;
//    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //
        histListTable.delegate = self;
        histListTable.dataSource = self;
        
        fetchHistoryList() { result in
            switch (result) {
            case .success(true):
                DispatchQueue.main.async {
                    self.histListTable.reloadData();
                };
            default:
                // TODO: put error alert here
                return;
            } // end of switch
            
        }
        
     //   tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell");
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.historyList?.count ?? 0;
    }
    
    
    // MARK: insertToCoredata
    func saveToHistoryList (_ textLoc:String,_ source:String, _ interactionType:String) -> Bool {
        let historyEntry = HistoryList(context: self.content)
        historyEntry.dateEntered = Date()
        historyEntry.destination = textLoc
        historyEntry.sourceModule = source
        historyEntry.interactionType = interactionType
        
        do {
            try content.save();
        } catch {
            return false;
        }
        return true;
  
    }
    
    // MARK: CoreData Functions
    func fetchHistoryList (completion: @escaping(Result<Bool,Error>)->Void) {
        do {
            self.historyList = try content.fetch(HistoryList.fetchRequest());
            completion(.success(true));
        } catch {
            completion(.failure(CoreDataError.fetchError));
        }
    }
    
    // MARK: - tableView functionalities
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = histListTable.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell;

        // Configure the cell...
        let cellItem = self.historyList![indexPath.row];
        cell.interactionTypeButton.setTitle(cellItem.interactionType, for: .normal);
        cell.fromModuleOutlet.text = cellItem.sourceModule?.capitalized;
        
        convertAddress(cellItem.destination ?? "") { (location,error) in
            if (error == nil) {
                self.convertCoordinate(location!.coordinate.latitude,location!.coordinate.longitude) {
                    (coordinateResult) in
                    
                    // TODO: rewrite this to something cleaner
                    switch coordinateResult {
                    case let .success(placemark):
                        if let placem = placemark.first {
                            print(placem)
                            
                            let city = placem.locality ?? ""
                            let country = placem.country ?? ""
                            let language = "en"
                            
                            print ("address retrieved");
                            
                            DispatchQueue.main.async{
                                // MARK: Reload table on the main thread after success.
                                //  https://stackoverflow.com/questions/57438492/tableview-loads-cell-before-api-request-can-update-model
                                cell.cityNameOutlet.text = "\(city), \(country)";
                            }
                            //                            self.requestNewsInfo(city, country, language)
                        }
                        
                    case let .failure(error):
                        return;
                    }
                }
            }
        }



    //    cell.cityNameOutlet.text = cellItem.
        

        return cell
    }
    
    // this will return a SINGLE CLLocation object.
    // MARK: Geocode and Reverse Geocoding
    func convertAddress (_ textLoc: String, completion: @escaping(_ location: CLLocation?,_ error: Error?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textLoc) {
            (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                completion(nil, error)
                return
            }
            print("\(location.coordinate.latitude) \(location.coordinate.longitude)")
            
            completion(location, nil)
            // TODO: I did escape but I'm not sure if this is the best... I do not know closures nor
        }
        
    }

    // thank you to my dear friend for introducing me to escaping closures. I'm still a noob at this...
    // https://stackoverflow.com/questions/46869394/reverse-geocoding-in-swift-4
    func convertCoordinate(_ latitude: Double,_ longitude: Double, completion: @escaping (Result<[CLPlacemark],Error>) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let placemark = placemark, error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(placemark))
        }
    }
    

    
    // MARK: - tableviewTemplates

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
