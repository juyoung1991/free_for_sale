//
//  mapController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 11. 8..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GooglePlaces
import GoogleMaps

class mapViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap{
    var searchitemsController: searchResultController!
    var resultsArray = [String]()
    var mapView: GMSMapView!
    var addr:String = ""
    @IBOutlet weak var myMapContainer: UIView!

    /**
     Click of Search button to open the search bar
     */
    @IBAction func open_searchBar(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: searchitemsController)
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true;
        self.present(searchController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.mapView = GMSMapView(frame: self.myMapContainer.frame)
        self.view.addSubview(self.mapView)
        searchitemsController = searchResultController()
        searchitemsController.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Add marker of the searched position with appropriate camera zoom
     - parameter lon: Longitude of address
     - parameter lat: Latitude of address
     - parameter title: The address
     */
    func locateWithLongitude(lon: Double, lat: Double, title: String) {
        self.addr = title
        DispatchQueue.main.async { 
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 17)
            self.mapView.camera = camera
            
            marker.title = title
            marker.map = self.mapView
        }
    }
    
    /**
     Adding auto complete in search bar
     - parameter searchBar: The search bar created
     - parameter searchText: Text in the search bar
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placeClient = GMSPlacesClient()
        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil, callback: {(results, error) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            
            for result in results! {
                self.resultsArray.append(result.attributedFullText.string)
            }
            self.searchitemsController.reloadDataWithArray(array: self.resultsArray)
            
        })
    }

}
