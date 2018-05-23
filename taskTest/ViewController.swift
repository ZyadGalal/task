//
//  ViewController.swift
//  taskTest
//
//  Created by Zyad Galal on 5/22/18.
//  Copyright © 2018 Zyad Galal. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ViewController: UIViewController ,UIPickerViewDelegate,UIPickerViewDataSource,CLLocationManagerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    // arrays for picker view
    var depID = [Int]()
    var dep = [String]()
    let state = ["سيفتح قريباً" , "الان"]
    
    var picker = UIPickerView()
    var Clicked : Int = 0
    //text fileds
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var salary: UITextField!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var department: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var describ: UITextField!
    @IBOutlet weak var openingSoon: UITextField!
    
    @IBOutlet weak var openingSoonView: UIView!
    func createLayer ()->CALayer
    {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: name.frame.height-1, width: name.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        return bottomLine
    }
    //func to create down arrow to left side
    func createDownArrow ()-> UIImageView
    {
        let imageView = UIImageView()
        
        let image = UIImage(named: "sort-down")
        
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: 10 , height: 10)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    var catID :Int = 0
    @IBAction func departmentClicked(_ sender: Any) {
        Clicked = 3
        print("3")
        if department.text == ""
        {
        department.text = dep[0]
            catID = depID[0]
        }
        picker.reloadComponent(0)
    }
    var statusID :Int = 2
    @IBAction func statusClicked(_ sender: Any) {
        Clicked = 2
        print("2")
        if status.text == ""
        {
        status.text = state[0]
        openingSoonView.isHidden = false
        }
        picker.reloadComponent(0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //design of text fileds border
        //remove border to all text fileds
        name.borderStyle = UITextBorderStyle.none
        salary.borderStyle = UITextBorderStyle.none
        duration.borderStyle = UITextBorderStyle.none
        department.borderStyle = UITextBorderStyle.none
        address.borderStyle = UITextBorderStyle.none
        email.borderStyle = UITextBorderStyle.none
        phone.borderStyle = UITextBorderStyle.none
        status.borderStyle = UITextBorderStyle.none
        describ.borderStyle = UITextBorderStyle.none
        openingSoon.borderStyle = UITextBorderStyle.none
        //adding th border to text fileds
        name.layer.addSublayer(createLayer())
        salary.layer.addSublayer(createLayer())
        duration.layer.addSublayer(createLayer())
        department.layer.addSublayer(createLayer())
        address.layer.addSublayer(createLayer())
        email.layer.addSublayer(createLayer())
        phone.layer.addSublayer(createLayer())
        status.layer.addSublayer(createLayer())
        describ.layer.addSublayer(createLayer())
        openingSoon.layer.addSublayer(createLayer())
        //---------------------------------------
        // draw down array to left side
        department.leftViewMode = UITextFieldViewMode.always
        department.leftView = createDownArrow()
        
        status.leftViewMode = UITextFieldViewMode.always
        status.leftView = createDownArrow()
        //---------------------------------------
        //picker view
        picker.dataSource = self
        picker.delegate = self
        
        //picker = UIPickerView(frame: CGRect(0, 200, view.frame.width, 300))
        
        picker.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: Selector(("donePicker")))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        department.inputView = picker
        department.inputAccessoryView = toolBar
        
        status.inputView = picker
        status.inputAccessoryView = toolBar
        //----------------- url of cate
        let catURL = "http://discounts-today-sa.com/api/add-ad"
        getcategories(url: catURL)
    }
    @objc func donePicker()
    {
        self.view.endEditing(true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if Clicked == 3
        {
            return dep.count
        }
        else if Clicked == 2
        {
            return state.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if Clicked == 3
        {
            return dep[row]
        }
        else if Clicked == 2
        {
            return state[row]
        }
        return dep[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if Clicked == 3
        {
            department.text = dep[row]
            catID = depID[row]
        }
        else if Clicked == 2
        {
            if state[row] == "سيفتح قريباً"
            {
                openingSoonView.isHidden = false
                statusID = 2
            }
            else
            {
                openingSoonView.isHidden = true
                statusID = 1
            }
            status.text = state[row]
        }
    }
//map
    var lat : Double = 0.0
    var lng : Double = 0.0
    var cityName: String = ""
    @IBOutlet var ViewOfMap: UIView!
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func addressCliked(_ sender: Any) {
        self.view.endEditing(true)
        self.view.addSubview(ViewOfMap)
        ViewOfMap.frame = CGRect(x: 15, y: 100, width: self.view.frame.width - 30, height: self.view.frame.height-120)
        //---------map view
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //---------------------disable user interaction
       // self.view.isUserInteractionEnabled = false
        
    }
    @IBAction func DoneClicked(_ sender: Any) {
        if lat != 0
        {
            ViewOfMap.removeFromSuperview()
            address.text = "\(cityName)"
           // self.view.isUserInteractionEnabled = true
        }
        
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locationcoor = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationcoor
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        lat = annotation.coordinate.latitude
        lng = annotation.coordinate.longitude
        let geoCoder = CLGeocoder()
        let loc = CLLocation(latitude: lat, longitude: lng)
        geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print(locationName)
                self.cityName = locationName as String
            }
        })
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        let userLocation :CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region :MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
        
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
    }
    //--------------image picker-----------
    var imageInString = ""
    var ImageVideo :Int = 0
    @IBOutlet weak var selectedImage: UIImageView!
    @IBAction func addImage(_ sender: Any) {
        ImageVideo = 1
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if ImageVideo == 1
        {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            selectedImage.image = image
            let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
            imageInString = imageData.base64EncodedString(options: .lineLength64Characters)
            
        }
        }
        else if ImageVideo == 2
        {
            let videoDataURL = info[UIImagePickerControllerMediaURL] as? NSURL
            var videoFileURL = videoDataURL?.filePathURL
            var video = NSData.dataWithContentsOfMappedFile("\(videoDataURL)")
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //------------- video
    @IBAction func selectVideo(_ sender: Any) {
        ImageVideo = 2
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.mediaTypes = ["public.movie"]
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
    }
    
    //-------------------------------Networking
    //get link to get cate.
    func getcategories(url : String ){
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess
            {
                print(response)
                let JSONResult : JSON = JSON(response.result.value!)
                let status = JSONResult["status"].int
                if status == 1
                {
                    self.parseJSON(json:JSONResult)
                }
                else
                {
                    print("error")
                }
            }
            else
            {
                print("errorrrr \(response.result.error)")
            }
        }
    }
    //parsing JSON of cate.
    func parseJSON(json:JSON)
    {
        if let cates = json["categories"].array {
            for cate in cates
            {
                let id = cate["id"].int
                let title = cate["name"].stringValue
                dep.append(title)
                depID.append(id!)
            }
        }
        picker.reloadAllComponents()
        SVProgressHUD.dismiss()
    }
    //create connection to send ads informations
    let postURL = "http://discounts-today-sa.com/api/​add-ad-post"
    
    func prepareParameters()
    {
        let username = name.text
        let des = describ.text
       
        let mobile = phone.text
        let mail = self.email.text
        
        if username != "" && des != "" && salary.text != "" && duration.text != "" && mobile != "" && mail != "" && imageInString != "" && status.text != "" && department.text != nil && lat != 0
        {
            let price = Int(salary.text!)
            let dur = Int(duration.text!)
            let soon = Int(openingSoon.text!)
            if statusID == 2 && openingSoon.text != ""
            {
        //without video or status id =2
                let params : [String : Any] = ["image" : imageInString,"title": username,"description": des , "price":price,"duration":dur,"status":statusID,"opening_soon_max_days":soon,"phone":mobile,"email":mail,"category_id":catID,"user_id":1,"lat":String(lat),"lng":String(lng),"city_name":cityName]
                postads(url: postURL, params: params)
            }
            else if statusID == 1
            {
                let params : [String : Any] = ["image" : imageInString,"title": username,"description": des , "price":price,"duration":dur,"status":statusID,"phone":mobile,"email":mail,"category_id":catID,"user_id":1,"lat":String(lat),"lng":String(lng),"city_name":cityName]
                postads(url: postURL, params: params)
            }
        }
    }
    func postads(url : String , params : [String:Any]){
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess
            {
                print(response)
                let JSONResult : JSON = JSON(response.result.value!)
                //let status = JSONResult["status"].int
               /* if status == 1
                {
                   // self.parseJSON(json:JSONResult)
                }
                else
                {
                    print("error")
                }*/
            }
            else
            {
                print("errorrrr \(response.result.error)")
            }
        }
    }
    @IBAction func Done(_ sender: Any) {
        prepareParameters()
    }
}

