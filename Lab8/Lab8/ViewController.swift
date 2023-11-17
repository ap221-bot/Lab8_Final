//
//  ViewController.swift
//  Lab8
//
//  Created by user232103 on 11/16/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Outlets for label and image
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var weatherDescLbl: UILabel!
    @IBOutlet weak var weatherIconImg: UIImageView!
    @IBOutlet weak var tempratureLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windLbl: UILabel!

    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    //MARK: Location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            fetchWeatherData(latitude: latitude, longitude: longitude)
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }

    //MARK: Weather API
    func fetchWeatherData(latitude: Double, longitude: Double) {
        let apiKey = "7a1bd19ac9634b2d15a98a7281b9e925"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"

        print("API URL: \(urlString)")

        if let url = URL(string: urlString) {
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let data = data {
                            do {
                                let weatherData = try JSONDecoder().decode(Weather.self, from: data)
                                DispatchQueue.main.async {
                                    self.updateUI(with: weatherData)
                                }
                            } catch {
                                print("Error decoding weather data: \(error)")
                            }
                        } else if let error = error {
                            print("Error fetching weather data: \(error)")
                        }
                    }
                    task.resume()
                }
    }

    // MARK: UI Updating region
    func updateUI(with weather: Weather) {
        cityNameLbl.text = weather.cityName

        if let firstWeatherCondition = weather.weather.first {
            weatherDescLbl.text = firstWeatherCondition.description
            
            if !firstWeatherCondition.icon.isEmpty {
                let iconURL = URL(string: "https://openweathermap.org/img/w/\(firstWeatherCondition.icon).png")
                if let data = try? Data(contentsOf: iconURL!), let image = UIImage(data: data) {
                    weatherIconImg.image = image
                } else {
                    
                    // Handling the case where image loading fails
                    print("Error Encountered during loading the icon")
                }
            } else {
                
                // Handling the case where "icon" is empty
                print("there no icon of this case")
            }
        } else {
            print("Error: Weather conditions array is empty")
        }

        tempratureLbl.text = String(format: "%.0f°C", weather.main.temperature - 273.15)
        humidityLbl.text = "Humidity : " + String(format: "%.0f", weather.main.humidity) + "%"
        windLbl.text = "Wind : " + String(format: "%.0f", weather.wind.speed * 3.6) + " km/h"
    }


    // MARK: Weather Data Structures
    
    struct Weather: Codable {
        let cityName: String
        let weather: [WeatherCondition]
        let main: Main
        let wind: Wind

        enum CodingKeys: String, CodingKey {
            case cityName = "name"
            case weather
            case main
            case wind
        }
    }

    struct WeatherCondition: Codable {
        let description: String
        let icon: String
    }

    struct Main: Codable {
        let temperature: Double
        let humidity: Double

        enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case humidity
        }
    }

    struct Wind: Codable {
        let speed: Double
    }


}

