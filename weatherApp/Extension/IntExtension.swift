//
//  IntExtension.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 09/09/2023.
//
import Foundation

extension Int {
    func incrementWeekDays(by num: Int) -> Int {
            let incrementedVal = self + num
            let mod = incrementedVal % 7
            
            return mod
        }
}
