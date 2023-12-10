//
//  Weather.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//
import UIKit
import CoreLocation

class Weather: UIViewController, CLLocationManagerDelegate {
    // structs
    // MARK: - Weather
    struct Weather: Codable {
        let coord: Coord
        let weather: [WeatherElement]
        let base: String
        let main: Main
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone, id: Int
        let name: String
        let cod: Int
    }
    
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }
    
    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }
    
    // MARK: - Main
    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double
        let pressure, humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
        }
    }

    // MARK: - Sys
    struct Sys: Codable {
        let type, id: Int
        let country: String
        let sunrise, sunset: Int
    }

    // MARK: - WeatherElement
    struct WeatherElement: Codable {
        let id: Int
        let main, description, icon: String
    }

    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }

    // MARK: - Outlets
    @IBOutlet weak var cityOutlet: UILabel!
    @IBOutlet weak var conditionOutlet: UILabel!
    @IBOutlet weak var iconOutlet: UIImageView!
    @IBOutlet weak var tempOutlet: UILabel!
    @IBOutlet weak var feelsLikeOutlet: UILabel!
    @IBOutlet weak var humidityOutlet: UILabel!
    @IBOutlet weak var windOutlet: UILabel!
    @IBOutlet weak var descriptionOutlet: UILabel!
    
    // MARK: - Globals
    var dest : String?;
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    //MARK: - Enums
    enum CoreDataError: Error {
        case insertError;
    }

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initializeDisplay();
        
        // MARK: - recevies the destination string from MainVc
        if dest != nil {
            self.convertAddress(dest!) { res in
                if case .success(let loc) = res {
                    self.getWeatherInfo(loc.coordinate.latitude,loc.coordinate.longitude)
                }
            }
        }
    }
    
    
    @IBAction func getCityCoord(_ sender: Any) {
        showAlert() { (textLoc,error) in
            if !error {
                self.convertAddress(textLoc) { res in
                    if case .success(let loc) = res {
                        self.getWeatherInfo(loc.coordinate.latitude,loc.coordinate.longitude)
                    }
                }
            }
        }
    }
    
    // MARK: - geocoder
    func convertAddress (_ textLoc: String, completion: @escaping(Result<CLLocation,Error>)->Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textLoc) {
            (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                return;
            }
            completion(.success(location))
        }
    }

    
    
    // placed this here to consolidate URL params
    /* Resources for building the URL:
     https://blog.hubspot.com/marketing/parts-url#:~:text=A%20URL%20consists%20of%20ten,basic%20parts%20of%20a%20URL.
     */
    func buildUrl (_ paramString: String) -> String{
        // URL BUILDER
        let scheme = "https://";
        let domain = "api.openweathermap.org";
        let subdirectory = "/data/2.5/";
        let path = "weather?";
        let params = paramString;
        let apiKey = "1f17f83e2ab177bb8d215bfbb17d7aec";
        
        let urlString = "\(scheme)\(domain)\(subdirectory)\(path)\(params)&appid=\(apiKey)";
        
        return urlString;
    }
    
    // MARK: api request to openweather.org and weather functions
    func getWeatherInfo(_ lat: Double, _ long: Double) {
        /*
          - I specifically placed metric in the url parameters to avoid complicating the calculations.
          - On a side note, need to make this dynamic somehow
         */
        let urlString = buildUrl("lat=\(lat)&lon=\(long)&units=metric");
        
        let urlSession = URLSession(configuration: .default);
        let url = URL(string: urlString);
        
        if let url = url {
            let dataTask = urlSession.dataTask(with: url) {
                (data,response,error) in
                
                // data from urlSession.dataTask
                if let data = data {
                    let jsonDecoder = JSONDecoder();
                    do {
                        let readableData = try jsonDecoder.decode((Weather.self), from: data);
 
                        /*
                         Apparently, URLSession dataTasks are run on a background thread. Based on research, code has to go back to the main thread to do UI work.
                         - in order for me to do that, I have use the following block of code:
                         - sources:
                            1. Got a violet error called "UILabel text must be used from main thread only" https://stackoverflow.com/questions/58639685/how-do-i-solve-this-uilabel-text-must-be-used-from-main-thread-only
                            2. IOS academy video on Concurrency -  https://www.youtube.com/watch?v=hmu0v_25pgc
                         */
                        DispatchQueue.main.async{
                            // STEP 3: Display the data
                            self.displayWeatherInfo(readableData);
                        }
                        
                    } catch {
                        print ("Can't Decode data");
                    }
                }
            }
            dataTask.resume();
            dataTask.response;
        }
    }
    
    func getSingleWeatherElement (_ weatherElemList: [WeatherElement], _ index: Int) -> WeatherElement {
        var weatherElem: WeatherElement?;
        
        for count in 0...weatherElemList.count-1 {
            if count == index {
                weatherElem = weatherElemList[index];
            }
        }
        return weatherElem!;
    }
    
    func displayWeatherInfo (_ weatherInfo: Weather) {
        // I am getting the country name as well because there are some countries that have the same city names. Ex. London, GB and London, CA
        
        // name city name
        let cityName = weatherInfo.name;
        let countryName = weatherInfo.sys.country;
        
        // weather condition info
        // array will have multiple elemens if it is a weather forecast. I do not think this is the case here yet so I'm getting the current one first.
        let weatherElement = getSingleWeatherElement(weatherInfo.weather, 0);
        let weatherName = weatherElement.main;
        let weatherIcon = weatherElement.icon;
        let weatherDesc = weatherElement.description;
        
        let infoMain = weatherInfo.main;
        let tempDeg = infoMain.temp;
        let feelsLike = infoMain.feelsLike;
      
        let humidity = infoMain.humidity;
      
        let windSpeed = weatherInfo.wind.speed;
        let windSpeedKmph = calcKmph(windSpeed);
        
        // setting appearance according to night or day
//        setColorScheme(weatherIcon);
        
        // output
        cityOutlet.text = "\(cityName), \(countryName)";
        conditionOutlet.text = weatherName;
        iconOutlet.image = UIImage(named: weatherIcon);
        tempOutlet.text = "\(formatDouble(number: tempDeg, floatPlaces: 1)) °";
        feelsLikeOutlet.text = "Feels Like: \(formatDouble(number: feelsLike, floatPlaces: 1))°"
        humidityOutlet.text = "\(humidity)%";
        windOutlet.text = "\(formatDouble(number: windSpeedKmph, floatPlaces: 2)) km/hr";
        descriptionOutlet.text = "\(weatherDesc)";
        
    }
    
    // MARK: UI-related Functions
    
    func initializeDisplay () {
        cityOutlet.text = "";
        conditionOutlet.text = "";
        tempOutlet.text = "";
        windOutlet.text = "";
        humidityOutlet.text = "";
        feelsLikeOutlet.text = "";
        descriptionOutlet.text = "";
    }
    
    func setColorScheme (_ icon: String) {
        if let index = icon.firstIndex(of: "n") {
            setColorToNight();
        } else {
            setColorToDay();
        }
        
    }
    func setColorToDay () {
        let blackColor = UIColor.black;
        
        cityOutlet.textColor = blackColor;
        conditionOutlet.textColor = blackColor;
        tempOutlet.textColor = blackColor;
        windOutlet.textColor = blackColor;
        humidityOutlet.textColor = blackColor;
        descriptionOutlet.textColor = blackColor;
        
//        humidityLabel.textColor = blackColor;
//        windLabel.textColor = blackColor;
//        descLabel.textColor = blackColor;
//        
//        UIViewBg.backgroundColor = UIColor(red: 127/255, green: 236/255, blue: 255/255, alpha: 1.0);
                
    }
    
    func setColorToNight () {
        let whiteColor = UIColor.white;
        
        cityOutlet.textColor = whiteColor;
        conditionOutlet.textColor = whiteColor;
        tempOutlet.textColor = whiteColor;
        windOutlet.textColor = whiteColor;
        humidityOutlet.textColor = whiteColor;
        descriptionOutlet.textColor = whiteColor;
        
//        humidityLabel.textColor = whiteColor;
//        windLabel.textColor = whiteColor;
//        descLabel.textColor = whiteColor;
//        
//        UIViewBg.backgroundColor = UIColor(red: 2/255, green: 49/255, blue: 94/255, alpha: 1.0);
        
    }
    
    // MARK: - Helper Functions
    
    func calcKmph (_ rawSpeed: Double) -> Double {
        let kmConv : Double = 1 / 1000;
        let hrConv : Double = 3600;
        
        let mToKm = rawSpeed * kmConv;
        let secToHr = mToKm * hrConv;
        let kmph = secToHr;
        
        return kmph;
    }
    
    func formatDouble (number: Double, floatPlaces places: Int) -> String {
        let formatString = String (format: "%%.%df", places);
        let truncatedString = String (format: formatString, number);
        
        return truncatedString;
    }
    
    // MARK: - Show destination alert prompt
    func showAlert (completion: @escaping(_ textLoc: String,_ error: Bool)->Void) {
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
            
            // MARK: saveToHistoryList usage
            if (!self.saveToHistoryList(textLoc,"weather","weather")) {
                completion("",true);
            }
            
            // so, I need to put the add function here. I still do not understand why this alert will not return anything
      //      self.addItemtoList(item: todoItem)
            completion(textLoc,false);
        }))
                        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


