//
//  Map.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//

import UIKit
import MapKit
import CoreLocation

// TODO: Integrate this.

class Map: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!;
    let locManager = CLLocationManager ();
    
    // globals
    var delta : Double = 0.5;
    var sourceLocation : CLLocation?;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locManager.delegate = self;
        locManager.desiredAccuracy = kCLLocationAccuracyBest;
        // greater accuracy, will eat more battery power
        // v means value, that makes sense
        locManager.requestWhenInUseAuthorization();
        locManager.startUpdatingLocation();
        mapView.delegate = self;
        
    }
    

    @IBAction func tempGetDirections(_ sender: Any) {
        showAlert()
    }

    // TODO: refine this slider some more.
    @IBAction func setRegionValue(_ sender: UISlider) {
        delta = Double(sender.value);
//        print(sender.value);
//        print(type(of: sender.value))
        let coordinate = CLLocationCoordinate2D(latitude: sourceLocation!.coordinate.latitude, longitude: sourceLocation!.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // TODO: Write how to alternate between car, bike and walk
    @IBAction func setToCarRoute(_ sender: Any) {
    }
    // TODO: Apple Documentation only has three routes: transit, car, and waling. There is no route for bikes.
    // https://developer.apple.com/documentation/mapkit/mkdirectionstransporttype/1451972-any
    @IBAction func setToBikeRoute(_ sender: Any) {
    }
    @IBAction func setToWalkRoute(_ sender: Any) {
    }
    
   // TODO: Make this passable. Will need to ask help from this on how to make this alert customizable
    // will open an aler function
    func showAlert () {
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
            
            // so, I need to put the add function here. I still do not understand why this alert will not return anything
      //      self.addItemtoList(item: todoItem)
            self.convertAddress(textLoc)
        }))
                        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.startUpdatingLocation()
            sourceLocation = location;
            render (location)
        }
    }
    
    func mapView (_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeline = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        routeline.strokeColor = .green
        return routeline
    }
    
    func render (_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation()
                                        
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }
    
    func convertAddress (_ textLoc: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textLoc) {
            (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                print ("no location found")
                return
            }
            
            print(location)
            self.mapThis(desitiationCor: location.coordinate)
        }
    }
    
    func mapThis (desitiationCor : CLLocationCoordinate2D) {
        
        // a. setting the table
        // get source coordinate
        let sourceCoordinate = (locManager.location?.coordinate)!
        
        // get the placemarks source and dest
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: desitiationCor)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        // send destination request. depends on a variety of parameters like traffic, mode of transpo and all
        let destinationRequest = MKDirections.Request()
        
        // start and end
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
    
                    // how travel, can add a toggle or a value
        destinationRequest.requestsAlternateRoutes = true
        destinationRequest.transportType = .walking

        // one route = false multi = true -> this will generate multi routes
        // b. submit request to calculate directions
            let directions = MKDirections(request: destinationRequest)
        directions.calculate {
            (response, error) in
            // guard to get atleast one response back
            guard let response = response else {
                if let error = error {
                    print ("something went wrong")
                }
                return
            }
            
            // output to the submit request is an array of routes.
            let route = response.routes[0]
            
            print(route);
            
            // in this case only the first route is fetched
            
            // add ze overlay to route
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            // setting the endpoint pin
            let pin = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: desitiationCor.latitude, longitude: desitiationCor.longitude)
            
            pin.coordinate = coordinate
            pin.title = "Endpoint"
            self.mapView.addAnnotation(pin)
        }
    }
    

    
    /*
    
     
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
