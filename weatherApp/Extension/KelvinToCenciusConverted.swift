//
//  KelvinToCenciusConverted.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 29/08/2023.
//

import Foundation

extension Float {
    func truncate(places : Int)-> Float {
            return Float(floor(pow(10.0, Float(places)) * self)/pow(10.0, Float(places)))
        }
        
        func kelvinToCelsiusConverter() -> Float {
            let constantVal : Float = 273.15
            let kelValue = self
            let celValue = kelValue - constantVal
            return celValue.truncate(places: 1)
        }
}
