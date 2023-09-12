//
//  ForecastModel.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 09/09/2023.
//

struct ForecastModel: Codable {
    var list: [WeatherModel]
    let city: City
}

struct City: Codable {
    let name: String?
    let country: String?
}
