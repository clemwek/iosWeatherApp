//
//  ForecastTemprature.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 09/09/2023.
//

struct WeatherInfo {
    let temp: Float
    let min_temp: Float
    let max_temp: Float
    let description: String
    let icon: String
    let time: String
}

struct ForecastTemperature {
    let weekDay: String?
    let hourlyForecast: [WeatherInfo]?
}
