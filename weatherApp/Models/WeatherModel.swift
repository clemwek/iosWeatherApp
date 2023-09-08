//
//  WeatherModel.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 29/08/2023.
//

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Main
    let sys: Sys
    let name: String
    let dt: Int
    let timezone: Int?
    let dt_txt: String?
}
