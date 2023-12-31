//
//  ViewController.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 26/08/2023.
//

import UIKit
import SwiftUI
import MapKit

class CurrentWeatherViewController: UIViewController {
    
    // MARK: Var properties
    var viewModel: CurrentWeatherViewModel?
    var selectedLocation: CLLocationCoordinate2D?
    
    var forecastData = WeatherData()
    
    // MARK: Constants
    let networkManager = WeatherNetworkManager()
    let locationManager = CLLocationManager()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CurrentWeatherViewModel()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAddPlaceButton))
        
        setup()
        addWeekForecast()
        layout()
        checkLocationServices()
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuth()
        } else {
            // Show error
        }
    }
    
    let containerView: UIView = {
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.backgroundColor = .systemBackground
        return containerView
    }()
    
    let currentStack: UIStackView = {
        let currentStack = UIStackView()
        currentStack.translatesAutoresizingMaskIntoConstraints = false
        currentStack.axis = .vertical
        currentStack.alignment = .center
        currentStack.distribution = .fillEqually
        currentStack.spacing = 10
        return currentStack
    }()
    
    let locationDateContainer: UIView = {
        let locationDateContainer = UIView()
        return locationDateContainer
    }()
    
    let currentLocation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...Location"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 38, weight: .heavy)
        return label
    }()
    
    let currentDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...Date"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    let imageContainer: UIView = {
        let imageContainer = UIView()
        return imageContainer
    }()
    
    let currentWeatherImage: UIImageView = {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold, scale: .large)
        let image = UIImage(systemName: "cloud.sun.circle.fill", withConfiguration: largeConfig)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let tempDescriptionContainer: UIView = {
        let tempDescriptionContainer = UIView()
        return tempDescriptionContainer
    }()
    
    let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...temp"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 45, weight: .heavy)
        return label
    }()
    
    let currentWeatherDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...Desc"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        return label
    }()
    
    let minMaxTempContainer: UIView = {
        let minMaxTempContainer = UIView()
        return minMaxTempContainer
    }()
    
    let minTemp: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...minTemp"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    let maxTemp: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "...maxTemp"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    let weekForecastContainer: UIView = {
        let weekForecastContainer = UIView()
        weekForecastContainer.backgroundColor = .lightGray
        return weekForecastContainer
    }()
    
    func addWeekForecast() {
        guard let hostView = UIHostingController(rootView: WeekForecastSwiftUIView().environmentObject(forecastData)).view else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false
        
        weekForecastContainer.addSubview(hostView)
        
        let constraints = [
            hostView.topAnchor.constraint(equalTo: weekForecastContainer.topAnchor),
            hostView.leadingAnchor.constraint(equalTo: weekForecastContainer.leadingAnchor),
            hostView.bottomAnchor.constraint(equalTo: weekForecastContainer.bottomAnchor),
            hostView.trailingAnchor.constraint(equalTo: weekForecastContainer.trailingAnchor),
        ]
        
        weekForecastContainer.addConstraints(constraints)
    }
    
    // MARK: Location setup
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getLocationWeather() {
        if let location = locationManager.location {
            selectedLocation = location.coordinate
            loadData(coordinates: location.coordinate)
            loadForecastData(coordinates: location.coordinate)
        }
    }
    
    func getSelectedLocationWeather(location: CLLocationCoordinate2D) {
        loadData(coordinates: location)
    }
    
    func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            getLocationWeather()
            break
        case .denied:
            //Show an alert to allow
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Show alert
            break
        case .authorizedAlways:
            break
        }
    }
    
    @objc func handleAddPlaceButton() {
        let storyboard = UIStoryboard(name: "NewLocationViewStoryBoard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewLocationStoryboard") as! NewLocationViewController
        vc.selectedLocationDelegate = self
        vc.selectedLocation = selectedLocation
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Fetch data
    func loadData(city: String) {
        networkManager.fetchCurrentWeather(city: city) { (weather) in
             let formatter = DateFormatter()
             formatter.dateFormat = "dd MMM yyyy" //yyyy
             let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))

             DispatchQueue.main.async {
                 self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCelsiusConverter()) + "°C")
                 self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                 self.currentWeatherDescription.text = weather.weather[0].description
                 self.currentDate.text = stringDate
                 self.minTemp.text = ("Min: " + String(weather.main.temp_min.kelvinToCelsiusConverter()) + "°C" )
                 self.maxTemp.text = ("Max: " + String(weather.main.temp_max.kelvinToCelsiusConverter()) + "°C" )
                 self.currentWeatherImage.loadImageFromURL(url: "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
             }
        }
    }
    
    func loadData(coordinates: CLLocationCoordinate2D) {
        networkManager.fetchCurrentLocationWeather(lat: "\(coordinates.latitude)", lon: "\(coordinates.longitude)") { (weather) in
             let formatter = DateFormatter()
             formatter.dateFormat = "dd MMM yyyy" //yyyy
             let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))

             DispatchQueue.main.async {
                 self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCelsiusConverter()) + "°C")
                 self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                 self.currentWeatherDescription.text = weather.weather[0].description
                 self.currentDate.text = stringDate
                 self.minTemp.text = ("Min: " + String(weather.main.temp_min.kelvinToCelsiusConverter()) + "°C" )
                 self.maxTemp.text = ("Max: " + String(weather.main.temp_max.kelvinToCelsiusConverter()) + "°C" )
                 self.currentWeatherImage.loadImageFromURL(url: "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
             }
        }
    }
    
    func loadForecastData(coordinates: CLLocationCoordinate2D) {
        networkManager.fetchNextFiveWeatherForecast(lat: "\(coordinates.latitude)", lon: "\(coordinates.longitude)") { forecast in
            self.forecastData.forecast = forecast
        }
    }
    
    func setup() {
        view.addSubview(containerView)
        containerView.addSubview(currentStack)
        currentStack.addArrangedSubview(locationDateContainer)
        locationDateContainer.addSubview(currentLocation)
        locationDateContainer.addSubview(currentDate)
        
        currentStack.addArrangedSubview(imageContainer)
        imageContainer.addSubview(currentWeatherImage)
        
        currentStack.addArrangedSubview(tempDescriptionContainer)
        tempDescriptionContainer.addSubview(currentTemperatureLabel)
        tempDescriptionContainer.addSubview(currentWeatherDescription)
        
        currentStack.addArrangedSubview(minMaxTempContainer)
        minMaxTempContainer.addSubview(maxTemp)
        minMaxTempContainer.addSubview(minTemp)
        
        currentStack.addArrangedSubview(weekForecastContainer)
        
    }
    
    func layout() {
        currentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        currentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        currentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        currentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
//        weekForecastContainer.topAnchor.constraint(equalTo: currentStack.bottomAnchor).isActive = true
//        weekForecastContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
//        weekForecastContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
//        weekForecastContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
//        weekForecastContainer.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        locationDateContainer.leadingAnchor.constraint(equalTo: currentStack.leadingAnchor).isActive = true
        locationDateContainer.trailingAnchor.constraint(equalTo: currentStack.trailingAnchor).isActive = true
        
        currentLocation.topAnchor.constraint(equalTo: locationDateContainer.topAnchor).isActive = true
        currentLocation.leadingAnchor.constraint(equalTo: locationDateContainer.leadingAnchor, constant: 20).isActive = true
        currentLocation.trailingAnchor.constraint(equalTo: locationDateContainer.trailingAnchor, constant: -18).isActive = true
        
        currentDate.topAnchor.constraint(equalTo: currentLocation.bottomAnchor).isActive = true
        currentDate.leadingAnchor.constraint(equalTo: locationDateContainer.leadingAnchor, constant: 20).isActive = true
        currentDate.trailingAnchor.constraint(equalTo: locationDateContainer.trailingAnchor, constant: -18).isActive = true
        
        imageContainer.leadingAnchor.constraint(equalTo: currentStack.leadingAnchor).isActive = true
        imageContainer.trailingAnchor.constraint(equalTo: currentStack.trailingAnchor).isActive = true
        
        tempDescriptionContainer.leadingAnchor.constraint(equalTo: currentStack.leadingAnchor).isActive = true
        tempDescriptionContainer.trailingAnchor.constraint(equalTo: currentStack.trailingAnchor).isActive = true
        
        currentTemperatureLabel.topAnchor.constraint(equalTo: tempDescriptionContainer.topAnchor).isActive = true
        currentTemperatureLabel.leadingAnchor.constraint(equalTo: currentWeatherImage.leadingAnchor, constant: 20).isActive = true
        currentTemperatureLabel.trailingAnchor.constraint(equalTo: tempDescriptionContainer.trailingAnchor, constant: -18).isActive = true
        
        currentWeatherDescription.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor).isActive = true
        currentWeatherDescription.leadingAnchor.constraint(equalTo: tempDescriptionContainer.leadingAnchor, constant: 20).isActive = true
        currentWeatherDescription.trailingAnchor.constraint(equalTo: tempDescriptionContainer.trailingAnchor, constant: -18).isActive = true
        
        minMaxTempContainer.leadingAnchor.constraint(equalTo: currentStack.leadingAnchor).isActive = true
        minMaxTempContainer.trailingAnchor.constraint(equalTo: currentStack.trailingAnchor).isActive = true
        
        maxTemp.topAnchor.constraint(equalTo: minMaxTempContainer.topAnchor).isActive = true
        maxTemp.leadingAnchor.constraint(equalTo: minMaxTempContainer.leadingAnchor, constant: 20).isActive = true
        maxTemp.trailingAnchor.constraint(equalTo: minMaxTempContainer.trailingAnchor, constant: -18).isActive = true
        
        minTemp.topAnchor.constraint(equalTo: maxTemp.bottomAnchor).isActive = true
        minTemp.leadingAnchor.constraint(equalTo: minMaxTempContainer.leadingAnchor, constant: 20).isActive = true
        minTemp.trailingAnchor.constraint(equalTo: minMaxTempContainer.trailingAnchor, constant: -18).isActive = true

    }  
}

extension CurrentWeatherViewController: HandleMapSearch {
    
    func getSelectedLocation(placemark: MKPlacemark) {
        selectedLocation = placemark.coordinate
        getSelectedLocationWeather(location: placemark.coordinate)
    }
}

extension CurrentWeatherViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        loadData(coordinates: location.coordinate )
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        checkLocationAuth()
    }
}

class WeatherData: ObservableObject {
    @Published var forecast: [ForecastTemperature] = []
}

