//
//  VoiceDetialViewController.swift
//  Orelo
//
//  Created by sheshkovsky on 29/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation


class VoiceDetialViewController: UIViewController, AVAudioPlayerDelegate, MKMapViewDelegate {
    
    // Mark: Properties
    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            mapView.delegate = self
            mapView.mapType = .Standard
            mapView.showsUserLocation = false
            mapView.rotateEnabled = false
            mapView.tintColor = UIColor.redColor()
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet{
            date = (voice?.createdAt)!
            dateLabel.text = self.dateFormatter.stringFromDate(date)
        }
    }
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    var voice: Voice?
    
    var activityController: UIActivityViewController!
    
    var voiceLocation = CLLocation()
    var voiceLocationName : String = ""

    var soundPlayer : AVAudioPlayer!
    var filePath = NSURL()
    
    var date = NSDate()

    var playerTimer = NSTimer()
    var seconds: Int = 0
    var fractions: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = voice!.title
        
        voiceLocation = CLLocation(latitude: Double((self.voice?.clLatitude)!), longitude: Double((self.voice?.clLongtitude)!))
        getLocationName(voiceLocation)
        
        showVoiceWithPin()
        
        preparePlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func showVoiceWithPin() {
        let pinLocation = self.voiceLocation
        let center = CLLocationCoordinate2D(latitude: pinLocation.coordinate.latitude, longitude:pinLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)

        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(center.latitude, center.longitude);
        myAnnotation.title = voice?.title
        mapView.addAnnotation(myAnnotation)
    }
    
    var locationHumanReadable = ""
    
    func getLocationName(passedLocation: CLLocation) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: passedLocation.coordinate.latitude, longitude: passedLocation.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.locationHumanReadable += "\(locationName), "
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                 self.locationHumanReadable += "\(street), "
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                 self.locationHumanReadable += "\(city), "
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                self.locationHumanReadable += "\(zip), "
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                self.locationHumanReadable += "\(country)"
            }
            
        })
    }

    // Called when the annotation was added
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.image = UIImage(named: "pin")
        }
        else {
            pinView!.annotation = annotation
        }
        
        pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        return pinView
    }
    
    // to call a function when pin is clicked
    // func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){}

    
    @IBAction func Play(sender: UIButton) {
        
        if (sender.currentImage?.isEqual(UIImage(named: "playButton")))! {
            startPlaying()
        } else {
            pausePlaying()
        }
        
//        switch sender.titleLabel!.text! {
////        case "Play":
////            startPlaying()
//        case "Pause":
//            pausePlaying()
//        default:
//            print("Error in player")
    }
    
    func startPlaying() {
        startTimer()
        soundPlayer.play()
        playButton.setImage(UIImage(named: "pauseButton"), forState: .Normal)
    }
    
    func pausePlaying() {
        soundPlayer.pause()
        playerTimer.invalidate()
        playButton.setImage(UIImage(named: "playButton"), forState: .Normal)
    }
    
    func preparePlayer() {
        filePath = getFilePath()
        let filePathToPlay = filePath
        do {
            soundPlayer = try AVAudioPlayer(contentsOfURL: filePathToPlay)
        } catch _ {
            print("Player Error")
        }
        soundPlayer.delegate = self
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 1.0
    }
    
    func getFilePath() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileName = voice?.fileName
        let pathArray = [dirPath, fileName!]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        return filePath!
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "playButton"), forState: .Normal)
        resetTimerLabel()
    }

    func updateTimerLabel() {
        fractions += 1
        if fractions == 100 {
            seconds += 1
            fractions = 0
        }
//        if seconds == 10 {
//            stopPlaying()
//            fractions = 0
//        }

        let fractionString = fractions > 9 ? "\(fractions)" : "0\(fractions)"
        let secondString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        timerLabel.text = "\(secondString).\(fractionString)"
//        
//        if timerLabel.text == voice?.duration {
//            resetTimerLabel()
//        }
    }
    
    func startTimer() {
        playerTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(VoiceDetialViewController.updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    func resetTimerLabel() {
        playerTimer.invalidate()
        fractions = 0
        seconds = 0
        timerLabel.text = "00.00"
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    @IBAction func Share(sender: UIButton) {
        // create an instance of UIActivityVC
        // Should pass two things: an array of activity items, an application activity
        let message = "Check out my new record \(voice!.title!) at \(locationHumanReadable) ! #Orelo #👂#💛"
        activityController = UIActivityViewController(activityItems: [message as NSString], applicationActivities: nil)
        activityController.excludedActivityTypes = [UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact]
        presentViewController(activityController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
