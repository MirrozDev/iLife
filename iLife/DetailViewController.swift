//
//  DetailViewController.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    //MARK: Variables
    
    var history: History?
    var page: Page?

    //MARK: Properties
    @IBOutlet weak var textTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapMKMapView: MKMapView!
    @IBOutlet weak var placeLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func deletePageBarButtonItem(_ sender: UIBarButtonItem) {
            
        let alert = UIAlertController(title: "Czy na pewno chcesz usunąć tą Stronę?", message: "Tej operacji nie można cofnąć.", preferredStyle: .alert)
        
        let deleteBtn = UIAlertAction(title: "Usuń", style: .destructive, handler: {
            (_) in
            self.performSegue(withIdentifier: "removePageUnwindSegue", sender: self)
        })
        //deleteBtn.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(deleteBtn)
        
        let cancelBtn = UIAlertAction(title: "Anuluj", style: .cancel, handler: nil )
        cancelBtn.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(cancelBtn)
        
        self.present(alert, animated: true, completion: nil)
            
    }
    
    //MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = page?.title
        textTextView.text = page?.text
        //textTextView.textContainer.heightTracksTextView = true
        //textTextView.textContainer.widthTracksTextView = true
        //textTextView.translatesAutoresizingMaskIntoConstraints = true
        textTextView.sizeToFit()
        textTextView.isScrollEnabled = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let data = page?.date ?? Date()
        dateLabel.text = dateFormatter.string(from: data)
        titleLabel.text = page?.title
        imageImageView.image = page?.image
        placeLabel.text = page?.localizationName
        
        
        let lLat = page?.locLat ?? 0.0
        let lLon = page?.locLon ?? 0.0
        
        mapMKMapView.centerToLocationWithPin(lLat, lLon)
        
        if page != nil {
            mapMKMapView.isHidden = false
            self.navigationController?.isToolbarHidden = false
            self.navigationController?.isNavigationBarHidden = false
        } else {
            mapMKMapView.isHidden = true
            self.navigationController?.isToolbarHidden = true
            self.navigationController?.isNavigationBarHidden = true
        }
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "editPage" {
            
            let nav = segue.destination as! UINavigationController
            guard let newPageViewController = nav.topViewController as? NewPageViewController
                else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            newPageViewController.isNewPage = false
            newPageViewController.history = history
            newPageViewController.page = page
            
        }
        
    }
    
}

//MARK: Class extension

private extension MKMapView {
    func centerToLocationWithPin(_ latitude: Double,_ longitide: Double, regionRadius: CLLocationDistance = 4000) {
        let initialLocation = CLLocation(latitude: latitude, longitude: longitide)
        let initialLocation2D = CLLocationCoordinate2DMake(latitude, longitide)
        
        let point = MKPointAnnotation()
        point.coordinate = initialLocation2D
        
        let coordinateRegion = MKCoordinateRegion(
            center: initialLocation.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
        addAnnotation(point)
    }
    
}

