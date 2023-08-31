//
//  CurrentWeatherViewModel.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 30/08/2023.
//

import Foundation

class CurrentWeatherViewModel {
    
    
    let networkManager = WeatherNetworkManager()
    
    var currentTemperatureLabel = ""
    var currentLocation = ""
    var currentWeatherDescription = ""
    var currentDate = ""
    var minTemp = ""
    var maxTemp = ""
    
    func loadData(city: String) {
        networkManager.fetchCurrentWeather(city: city) { weather in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy" //yyyy
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel = (String(weather.main.temp.kelvinToCelsiusConverter()) + "°C")
                self.currentLocation = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                self.currentWeatherDescription = weather.weather[0].description
                self.currentDate = stringDate
                self.minTemp = ("Min: " + String(weather.main.temp_min.kelvinToCelsiusConverter()) + "°C" )
                self.maxTemp = ("Max: " + String(weather.main.temp_max.kelvinToCelsiusConverter()) + "°C" )
                //                self.tempSymbol.loadImageFromURL(url: "http://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
            }
        }
    }
}
