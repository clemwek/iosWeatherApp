//
//  NetworkManagerProtocol.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 28/08/2023.
//

protocol NetworkManagerProtocol {
    func fetchCurrentWeather(city: String, completion: @escaping (WeatherModel) -> ())
    func fetchCurrentLocationWeather(lat: String, lon: String, completion: @escaping (WeatherModel) -> ())
//    func fetchNextFiveWeatherForecast(city: String, completion: @escaping ([ForecastTemprature]) -> ())
}
