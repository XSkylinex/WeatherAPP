
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController ,CLLocationManagerDelegate , ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = " "
    
    let locationManger = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1 ]
        if location.horizontalAccuracy > 0 {
            locationManger.startUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude) , latitide = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat": latitude , "lon": longitude,"appid" : APP_ID]
            getWeatherData(url: WEATHER_URL,parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "GPS error"
    }
    
    func getWeatherData(url:String ,parameters: [String:String]){
        Alamofire.request(url,method: .get ,parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Connected")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                
                self.cityLabel.text = "Network Error"
            }
        }
    }
    
    func updateWeatherData(json: JSON){
        if let temp = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(temp - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIwithWeatherData()
        } else {
            cityLabel.text = "Weather Error"
        }
    }
    
    
    
    func updateUIwithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func userEnteredANewCityName(city: String) {
        let params: [String:String] = ["q" : city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
}


