//
//  Main.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//

//TODO: please return a .failure if city cannot be found on the convertAddress.

import UIKit
import MapKit
import CoreLocation

class Main: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mainMapView: MKMapView!;
    
    // MARK: Globals
    var dest : String?;
    let locManager = CLLocationManager ();
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    let delta = 0.03;
    
    // MARK: External Events
    @IBAction func showDestinationPrompt(_ sender: Any) {
        showAlert();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    // MARK: Preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        if segue.identifier == "goToNews" {
            guard let newsVc = segue.destination as? News else { return }
            newsVc.dest = dest;
        } else if segue.identifier == "goToDirections" {
            guard let mapVc = segue.destination as? Map else { return }
            mapVc.dest = dest;
        } else if segue.identifier == "goToWeather" {
            guard let weatherVc = segue.destination as? Weather else { return }
            weatherVc.dest = dest;
        }
    }
    
    // MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locManager.delegate = self;
        locManager.desiredAccuracy = kCLLocationAccuracyBest;
        // greater accuracy, will eat more battery power
        // v means value, that makes sense
        locManager.requestWhenInUseAuthorization();
        locManager.startUpdatingLocation();
        mainMapView.delegate = self;
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.startUpdatingLocation()
            render (location)
        }
    }
    
    func render (_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation()
                                        
        pin.coordinate = coordinate
        mainMapView.addAnnotation(pin)
        mainMapView.setRegion(region, animated: true)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlert () {
        let alert = UIAlertController(title: "Where would you like to go?", message: "Please enter your destination", preferredStyle: .alert);
        alert.addTextField { field in
            field.placeholder = "Waterloo";
            field.returnKeyType = .continue;
        }
        alert.addAction(UIAlertAction(title: "News", style: .default, handler: { _ in
            guard self.segueToOtherView(alert.textFields,"news") else {
                return;
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Directions", style: .default, handler: { _ in
            guard self.segueToOtherView(alert.textFields,"directions") else {
                return;
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Weather", style: .default, handler: { _ in
            guard self.segueToOtherView(alert.textFields,"weather") else {
                return;
            }

        }))

        self.present(alert, animated: true)
    }
    
    func segueToOtherView (_ fields: [UITextField]?, _ ctrlIdentifier: String) -> Bool {
        guard let field = fields, field.count == 1 else {
            return false;
        }
        
        let txtLocField = field[0]
        guard let textLoc = txtLocField.text, !textLoc.isEmpty else {
            return false;
        }
        self.dest = textLoc;
        
        if (!self.saveToHistoryList(textLoc,"home",ctrlIdentifier)) {
            // TODO: proper handling of error
            print("error was encountered when adding to history");
        }
        
        self.performSegue(withIdentifier: "goTo\(ctrlIdentifier.capitalized)", sender: self);
        
        
        
        return true;
    }
    
    
    func saveToHistoryList (_ textLoc:String,_ source:String, _ interactionType:String) -> Bool {
        // MARK: save to historyList
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

}
