//
//  WeekForecastSwiftUIView.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 09/09/2023.
//

import SwiftUI

struct WeekForecastSwiftUIView: View {
    @EnvironmentObject var data: WeatherData
    
    var body: some View {
       
        VStack {
            Text("week forecast")
                .font(.title)
            HStack() {
                ForEach(data.forecast, id: \.weekDay) { weather in
                    VStack( 
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text(weather.weekDay ?? "")
                        Text("\(weather.hourlyForecast?[0].temp ?? 0)")
                    }
                }
            }
        }
    }
}

//#Preview {
//    WeekForecastSwiftUIView(forecast: Binding<[ForecastTemperature]()>)
//}
