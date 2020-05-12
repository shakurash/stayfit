//
//  BodyEditViewController.swift
//  stayfit
//
//  Created by Robert on 07/05/2020.
//  Copyright © 2020 Robert. All rights reserved.
//

import UIKit
import RealmSwift

class BodyEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var profileNameTextLabel: UITextField!
    @IBOutlet weak var profileMassTextLabel: UITextField!
    @IBOutlet weak var profileHeightTextLabel: UITextField!
    @IBOutlet weak var profileTargetTextLabel: UITextField!
    @IBOutlet weak var profileDatePickerTextLabel: UITextField!
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var dayIntenseSelectorDisplay: UISegmentedControl!
    @IBOutlet weak var genderSelectorDisplay: UISegmentedControl!
    @IBOutlet weak var tempoSelectorDisplay: UISegmentedControl!
    
    private var datePicker = UIDatePicker()
    private var numberPicker = UIPickerView()
    
    private var toolBar = UIToolbar()
    private var toolButtonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
    private var toolConstrains = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    let dataSource = DataSource()
    let realm = try! Realm()
    var myProfile: ProfileModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileModel = realm.objects(ProfileModel.self).first
        myProfile = profileModel
        
        lightModeSwitch.addTarget(self, action: #selector(BodyEditViewController.switchChanged), for: UIControl.Event.valueChanged)
        
        datePicker.datePickerMode = .date
        profileDatePickerTextLabel.inputView = datePicker
        
        profileMassTextLabel.inputView = numberPicker
        profileHeightTextLabel.inputView = numberPicker
        profileTargetTextLabel.inputView = numberPicker
        
        numberPicker.delegate = self
        profileNameTextLabel.delegate = self
        
        toolBar.sizeToFit()
        toolBar.setItems([toolConstrains, toolButtonDone], animated: true)
        
        profileDatePickerTextLabel.inputAccessoryView = toolBar
        profileMassTextLabel.inputAccessoryView = toolBar
        profileTargetTextLabel.inputAccessoryView = toolBar
        profileHeightTextLabel.inputAccessoryView = toolBar
        
        navigationItem.hidesBackButton = true
    }

    //MARK: - saving method and update profile with PPM CPM
    
    @IBAction func saveProfilePressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "FromEditProfileToMainMenu", sender: self)
    }
    
    
    
    //MARK: - loading values to fetch data from profile
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadProfileData = realm.objects(ProfileModel.self).first {
            profileNameTextLabel.text = loadProfileData.name
            profileMassTextLabel.text = String(loadProfileData.mass)
            profileTargetTextLabel.text = String(loadProfileData.target)
            profileHeightTextLabel.text = String(loadProfileData.height)
            lightModeSwitch.isOn = loadProfileData.lightMode
            profileDatePickerTextLabel.text = loadProfileData.date
            dayIntenseSelectorDisplay.selectedSegmentIndex = setProperIndex(data: loadProfileData.dayIntense)
            genderSelectorDisplay.selectedSegmentIndex = setProperIndex(gender: loadProfileData.gender)
            tempoSelectorDisplay.selectedSegmentIndex = setProperIndex(tempo: loadProfileData.tempo)
        }
    }
    
    func setProperIndex(data: Double? = nil, gender: String? = nil, tempo: String? = nil) -> Int {
        var index: Int?
        if data != nil {
            switch data {
            case 1.2: index = 0
            case 1.4: index = 1
            case 1.7: index = 2
            case 2.0: index = 3
            case 2.4: index = 4
            default:
                index = 0
            }
        }
        if gender != nil {
            switch gender {
            case "MALE": index = 0
            case "FEMALE": index = 1
            default:
                index = 0
            }
        }
        if tempo != nil {
            switch tempo {
            case "slow": index = 0
            case "medium": index = 1
            case "fast": index = 2
            default:
                index = 0
            }
        }
        return index ?? 0
    }
    
    
    //MARK: - textfield delegate methods for profileNameTextLabel
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let securedName = profileNameTextLabel.text {
            try! realm.write {
                myProfile?.name = securedName
            }
            profileNameTextLabel.endEditing(true)
        }
        return true
    }
    
    //MARK: - datepicker format preparation
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        profileDatePickerTextLabel.text = formatter.string(from: datePicker.date)
        if let securedData = profileDatePickerTextLabel.text {
            try! realm.write {
                myProfile?.date = securedData
            }
        }
    }
    
    @objc func endEditing() {
        if profileDatePickerTextLabel.isFirstResponder {
            dateChanged()
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
    }
    
    //MARK: - mass, target and height pickers setup
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.numberPicker.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if profileMassTextLabel.isFirstResponder || profileTargetTextLabel.isFirstResponder {
            return dataSource.profileMass.count
        } else {
            return dataSource.profileHeight.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if profileMassTextLabel.isFirstResponder || profileTargetTextLabel.isFirstResponder {
            return String(dataSource.profileMass[row])
        } else {
            return String(dataSource.profileHeight[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if profileMassTextLabel.isFirstResponder {
            profileMassTextLabel.text = String(dataSource.profileMass[row]) + " KG"
            try! realm.write {
                myProfile?.mass = dataSource.profileMass[row]
            }
        } else if profileTargetTextLabel.isFirstResponder {
            profileTargetTextLabel.text = String(dataSource.profileMass[row]) + " KG"
            try! realm.write {
                myProfile?.target = dataSource.profileMass[row]
            }
        } else if profileHeightTextLabel.isFirstResponder {
            profileHeightTextLabel.text = String(dataSource.profileHeight[row]) + " CM"
            try! realm.write {
                myProfile?.height = dataSource.profileHeight[row]
            }
        } else {
            fatalError("brak lejbelu dla pickerview - cos poszlo nie tak (BodyEditViewController)")
        }
    }
    
    //MARK: - segmented controllers setup
    
    @IBAction func dayIntensePressed(_ sender: UISegmentedControl) {
        let intensity: Double?
        switch sender.selectedSegmentIndex {
        case 0: intensity = 1.2
        case 1: intensity = 1.4
        case 2: intensity = 1.7
        case 3: intensity = 2.0
        case 4: intensity = 2.4
        default:
            fatalError("wybrano opcje za skalą (BodyEditViewController)")
        }
        if let securedIntense = intensity {
            try! realm.write {
                myProfile?.dayIntense = securedIntense
            }
        }
    }
    
    @IBAction func tempoPressed(_ sender: UISegmentedControl) {
        let tempo: String?
        switch sender.selectedSegmentIndex {
        case 0: tempo = "slow"
        case 1: tempo = "medium"
        case 2: tempo = "fast"
        default:
            fatalError("no valid tempo")
        }
        if let securedTempo = tempo {
            try! realm.write {
                myProfile?.tempo = securedTempo
            }
        }
    }
    
    @IBAction func genderPressed(_ sender: UISegmentedControl) {
        var gender: String?
        switch sender.selectedSegmentIndex {
        case 0: gender = "MALE"
        case 1: gender = "FEMALE"
        default:
            fatalError("no gender")
        }
        if let securedGender = gender {
            try! realm.write {
                myProfile?.gender = securedGender
            }
        }
    }
    
    @objc func switchChanged() {
        let status: Bool?
        if lightModeSwitch.isOn {
            status = true
        } else {
            status = false
        }
        if let securedStatus = status {
            try! realm.write {
                myProfile?.lightMode = securedStatus
            }
        }
    }
}