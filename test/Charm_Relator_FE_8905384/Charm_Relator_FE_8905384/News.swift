//
//  News.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-02.
//

//TODO: Add some constraints

import UIKit
import CoreLocation
import Foundation

class News: UITableViewController {
// Struct for news
    // MARK: - News
    struct NewsData: Codable {
        let status: String
        let totalResults: Int
        let articles: [Article]
    }

    // MARK: - Article
    struct Article: Codable {
        let source: Source
        let author: String?
        let title, description: String
        let url: String
        let urlToImage: String?
        let publishedAt: Date
        let content: String
    }

    // MARK: - Source
    struct Source: Codable {
        let id: String?
        let name: String
    }
    
    // MARK: External Actions
    @IBAction func enterCity(_ sender: Any) {
        showAlert { (result) in
            
            if case .success(let textLoc) = result {
                self.convertAddress(textLoc) { location,error in
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
                                
                                self.requestNewsInfo(city, country, language)
                            }
               
                            case let .failure(error):
                            return;
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: Globals
    var newsList:[Article] = []
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    // MARK: - viewdidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        navigationItem.hidesBackButton = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! ArticleCell
        
        print(newsList[indexPath.row].description)

        // Configure the cell...
        cell.articleTitle.text = newsList[indexPath.row].title
        cell.articleDescription.text = newsList[indexPath.row].description
        cell.articleSource.text = newsList[indexPath.row].source.name
        cell.articleAuthor.text = newsList[indexPath.row].author ?? "Unknown Author"

        return cell
    }
    
    // MARK: Alert prompt for a destination
    func showAlert (completion: @escaping(Result<String, Error>) -> Void) {
        let alert = UIAlertController(title: "Get Location", message: "Please Enter Your Location", preferredStyle: .alert);
        
        alert.addTextField { field in
            field.placeholder = "Waterloo";
            field.returnKeyType = .continue;
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let field = alert.textFields, field.count == 1 else {
                return;
            }
            
            let txtLocField = field[0]
            guard let textLoc = txtLocField.text, !textLoc.isEmpty else {
                return;
            }
            
            // TODO: place this in a crud function.
            let historyEntry = HistoryList(context: self.content)
            historyEntry.dateEntered = Date()
            historyEntry.destination = textLoc
            historyEntry.sourceModule = "news"
            historyEntry.interactionType = "news"
            
            do {
                try self.content.save()
            } catch {
                completion(.failure(error))
            }
            
            completion(.success(textLoc));
            
            // so, I need to put the add function here. I still do not understand why this alert will not return anything
      //      self.addItemtoList(item: todoItem)
           // self.convertAddress(textLoc)
        }))
                        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    // MARK: API Request function to newsapi.org
    // TODO: refactor to have completion
    func requestNewsInfo(_ city:String, _ country:String,_ language:String) { // MARK: ORIGINAL
        let qString = "q=(\(city) AND \(country))"
        let escapedQString = qString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let paramString = "\(escapedQString)&language=\(language)"
        
        print(paramString);
        
        let urlString = buildUrl(paramString);
        
        
        let urlSession = URLSession(configuration: .default);
        let url = URL(string: urlString);
        
        if let url = url {
            let dataTask = urlSession.dataTask(with: url) {
                (data,response,error) in
                print (data!)
                // data from urlSession.dataTask
                if let data = data {

                    let jsonDecoder = JSONDecoder();
                    
                    // MARK: According to this, date decoding strategy has to be set in the decoder or else props with dates will cause the decoding process to fail.
           //     https://stackoverflow.com/questions/47704954/getting-json-data-with-swift-4-and-xcode-9
                    let dateFormat = DateFormatter();
                    dateFormat.locale = Locale(identifier: "en_CA")
                    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // MARK: UTC is the date format used in NewsAPI.org
                    jsonDecoder.dateDecodingStrategy = .formatted(dateFormat)
                    do {
                        let readableData = try jsonDecoder.decode(NewsData.self, from: data);
                        
                        
                        self.newsList = readableData.articles
                        DispatchQueue.main.async{
                            // MARK: Reload table on the main thread after success.
                      //  https://stackoverflow.com/questions/57438492/tableview-loads-cell-before-api-request-can-update-model
                            self.tableView.reloadData()
                        }
                        
                        
                        
                    } catch {
                        // MARK: Charm, you really forgot to log the error huh?
                        print(error)
                    }
                }
            }
            dataTask.resume();
            dataTask.response;
        }
    }

    func buildUrl (_ paramString: String) -> String {
        // URL BUILDER
        let scheme = "https://";
        let domain = "newsapi.org";
        let subdirectory = "/v2/";
        let path = "everything?";
        let params = paramString;
        let apiKey = "942744213a844387854bb76d14723c5d";
        
        let urlString = "\(scheme)\(domain)\(subdirectory)\(path)\(params)&apiKey=\(apiKey)";
        
        return urlString;
    }

    // MARK: Geocode and Reverse Geocoding
    
    // this will return a SINGLE CLLocation object.
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
