//
//  RecordViewController.swift
//  Orelo
//
//  Created by sheshkovsky on 15/08/16.
//  Copyright © 2016 Ali Gholami. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import CoreData
import FirebaseAuth

class RecordViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate
{
    
    // MARK: Properties
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordNavigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
            mapView.mapType = .Standard
            mapView.showsUserLocation = true
            mapView.rotateEnabled = false
            mapView.tintColor = UIColor.redColor()
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel! {
        didSet{
            dateLabel.text = dateFormatter.stringFromDate(date)
        }
    }
    
    var moc: NSManagedObjectContext?
    
    var date = NSDate()
    
    lazy var dateFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var dateTimer = NSTimer()
    var recordTimer = NSTimer()
    var seconds: Int = 0
    var fractions: Int = 0
    let MAX = 60
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    var filePath = NSURL()
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update date label
        dateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(RecordViewController.updateDateLabel), userInfo: nil, repeats: true)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        setupRecorder()
        
        playButton.enabled = false
        saveButton.enabled = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Update Date Label
    func updateDateLabel() {
        date = NSDate()
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
    
    func currentLoggedInUserUsername() -> String {
        let currentUser: String = (FIRAuth.auth()?.currentUser!.displayName)!
        return currentUser
    }
    
    // MARK: Location Delegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        currentLocation = location!
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        print("center: \(center)")
        print("lat:\(location!.coordinate.latitude) long:\(location!.coordinate.longitude)")
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    // Get File Name & Path
    func generateFileName() -> String {
        return NSProcessInfo.processInfo().globallyUniqueString + ".wav"
    }
    
    func getFilePath() -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileName = generateFileName()
        let pathArray = [dirPath, fileName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        return filePath!
    }
    
    // MARK: Record & Play Button Functions
    @IBAction func Record(sender: UIButton) {
        if (sender.currentImage?.isEqual(UIImage(named: "recordButton")))! {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    @IBAction func Play(sender: UIButton) {
        if (sender.currentImage?.isEqual(UIImage(named: "playButton")))! {
            startPlaying()
        } else {
            pausePlaying()
        }
    }
    
    // MARK: Setup Recorder
    func setupRecorder(){
        filePath = getFilePath()
        
        let recordSettings: [String : AnyObject]  = [
            AVFormatIDKey : NSNumber(unsignedInt: kAudioFormatLinearPCM),
            AVSampleRateKey : 44100.0,
            AVNumberOfChannelsKey : 2,
            AVLinearPCMBitDepthKey : 16,
            AVLinearPCMIsBigEndianKey : false,
            AVLinearPCMIsFloatKey : false,
            ]
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            soundRecorder = try AVAudioRecorder(URL: filePath, settings: recordSettings)
        } catch _ {
            print("Error in setup recorder")
        }
        
        soundRecorder.delegate = self
        soundRecorder.prepareToRecord()
    }
    
    func startRecording() {
        recordTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(RecordViewController.updateTimerLabel), userInfo: nil, repeats: true)
        soundRecorder.record()
        recordButton.setImage(UIImage(named: "stopButton"), forState: .Normal)
    }
    
    func stopRecording() {
        recordTimer.invalidate()
        soundRecorder.stop()
        
        playButton.enabled = true
        playButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        recordButton.enabled = false
        recordButton.setImage(UIImage(named: "recordButtonDisabled"), forState: .Normal)
        recordButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        
        saveButton.enabled = true
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    func startPlaying() {
        preparePlayer()
        soundPlayer.play()
        
        playButton.setImage(UIImage(named: "pauseButton"), forState: .Normal)
        
        saveButton.enabled = false
        saveButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    }
    
    func pausePlaying() {
        soundPlayer.pause()
        
        playButton.setImage(UIImage(named: "playButton"), forState: .Normal)
        
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        saveButton.enabled = true
    }
    
    // MARK: Audio Player Delegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.enabled = true
        playButton.setImage(UIImage(named: "playButton"), forState: .Normal)
        
        saveButton.enabled = true
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    func preparePlayer() {
        let filePathToPlay = filePath
        
        print("file path in view: \(filePathToPlay)")
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOfURL: filePathToPlay)
        } catch _ {
            print("Player Error")
        }
        soundPlayer.delegate = self
        soundPlayer.prepareToPlay()
        soundPlayer.volume = 1.0
    }
    
    func updateTimerLabel() {
        fractions += 1
        if fractions == 100 {
            seconds += 1
            fractions = 0
        }
        if seconds == MAX {
            stopRecording()
            fractions = 0
        }
        let fractionString = fractions > 9 ? "\(fractions)" : "0\(fractions)"
        let secondString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        timerLabel.text = "\(secondString).\(fractionString)"
    }
    
    func resetTimerLabel() {
        recordTimer.invalidate()
        fractions = 0
        seconds = 0
        timerLabel.text = "00.00"
    }
    
    // MARK: Save Functionality
    @IBAction func Save(sender: UIButton) {
        moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let ent = NSEntityDescription.entityForName("Voice", inManagedObjectContext: moc!)!
        
        let record = Voice.init(entity: ent, insertIntoManagedObjectContext: moc)
        
        let alertController = UIAlertController(title: "Save Your Voice", message: "Choose a title for your voice", preferredStyle: .Alert) // can be .ActionSheet
        
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: ({
            (_) in
            let field = alertController.textFields![0] as UITextField
            
            if !(field.text?.isEmpty)! {
                record.title = field.text
            } else {
                record.title = self.dateFormatter.stringFromDate(self.date)
            }
            record.fileName = self.filePath.lastPathComponent
            record.createdAt = self.date
            record.createdBy = self.currentLoggedInUserUsername()
            record.duration = self.timerLabel.text
            record.clLatitude = self.currentLocation.coordinate.latitude
            record.clLongtitude = self.currentLocation.coordinate.longitude
            
            do{
                try self.moc!.save()
                print("Your voice \(record.title)has been saved!")
            } catch let error {
                print("Core Data Error: \(error)")
            }
            
            self.resetTimerLabel()
            self.performSegueWithIdentifier("goBackToTableAfterSave", sender: nil)
            
        })
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel , handler: nil)
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            let insertTitleTextField = textField
            insertTitleTextField.placeholder = "Your voice title..."
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}

