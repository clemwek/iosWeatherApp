//
//  NewLocationViewController.swift
//  weatherApp
//
//  Created by Clement  Wekesa on 31/08/2023.
//

import UIKit
import MapKit

class NewLocationViewController: UIViewController {
    
    var resultSearchController: UISearchController? = nil
    var selectedLocationDelegate: HandleMapSearch? = nil
    var selectedLocation: CLLocationCoordinate2D?
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTappedLocation))
        mapView.addGestureRecognizer(tapGesture)
        
        setLocationSearch()
        centerViewOnUserLocation()
        
    }
    
    func centerViewOnUserLocation() {
        if let location = selectedLocation {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.showsUserLocation = true
            mapView.setRegion(region, animated: true)
        }
    }
    
    func setLocationSearch() {
        let searchStoryboard = UIStoryboard(name: "LocationSearchTable", bundle: nil)
        let locationSearchTable = searchStoryboard.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        navigationItem.searchController = resultSearchController
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    @objc func handleTappedLocation(gestureReconizer: UITapGestureRecognizer) {
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let placemark = MKPlacemark(coordinate: coordinate)
        
        selectedLocationDelegate?.getSelectedLocation(placemark: placemark)
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewLocationViewController: CLLocationManagerDelegate {

    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion (region, animated: true)
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

extension NewLocationViewController: UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension NewLocationViewController: HandleMapSearch {
    
    func getSelectedLocation(placemark: MKPlacemark) {
        selectedLocationDelegate?.getSelectedLocation(placemark: placemark)
        self.navigationController?.popViewController(animated: true)
    }
}
