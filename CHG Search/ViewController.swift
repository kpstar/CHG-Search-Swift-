//
//  ViewController.swift
//  CHG Search
//
//  Created by KpStar on 5/2/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var mainBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var tblPhoneList: UITableView!

    let fileUrl343 = "https://www.dropbox.com/s/hk8wgqbrv600xss/343.csv?dl=1"
    let fileUrl613 = "https://www.dropbox.com/s/mck7bina5v2h3lj/613.csv?dl=1"
    let arrayPhone : NSMutableArray = ["613", "343"]
    var findNot = MBProgressHUD()
    var findStr: String = ""

    var actionMethod : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureUI(action: actionMethod)
        tblPhoneList.isHidden = true

        tblPhoneList.delegate = self
        tblPhoneList.dataSource = self
        phoneTxt.delegate = self

    }

    private func setupUI() {
        tblPhoneList.layer.borderColor = UIColor.black.cgColor
        tblPhoneList.layer.borderWidth = 1
        listBtn.layer.borderColor = UIColor.black.cgColor
        listBtn.layer.borderWidth = 1
        mainBtn.backgroundColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        updateBtn.backgroundColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    }

    private func configureUI(action: Bool) {

        if action {
            downloadBtn.isHidden = true
            submitBtn.isHidden = false
            listBtn.isHidden = false
            phoneTxt.isHidden = false
        } else {
            downloadBtn.isHidden = false
            submitBtn.isHidden = true
            listBtn.isHidden = true
            phoneTxt.isHidden = true
        }
    }

    @IBAction func listBtnTapped(_ sender: UIButton) {
        if tblPhoneList.isHidden {
            tblPhoneList.isHidden = false
        } else {
            tblPhoneList.isHidden = true
        }
    }

    @IBAction func submitBtnTapped(_ sender: Any) {
        
        self.findNot = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.findNot.detailsLabel.text = "Searching..."
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.filedownload()
        }
        //filedownload()
    }
    
    func filedownload() {

        findStr = phoneTxt.text!
        phoneTxt.text = ""
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var destinationFileUrl = documentsUrl.appendingPathComponent("343.csv")
        if listBtn.titleLabel?.text != "343" {
            destinationFileUrl = documentsUrl.appendingPathComponent("613.csv")
            listBtn.titleLabel?.text = "613"
        } else {
            listBtn.titleLabel?.text = "343"
        }
        
        if let i = findStr.index(of: "-") {
            findStr.remove(at: i)
        }
        
        var mResult : Bool = false
        let fm = FileManager.default
        let content =  fm.contents(atPath: destinationFileUrl.path)
        if fm.fileExists(atPath: destinationFileUrl.path) {
            let data = String(data: content!, encoding: String.Encoding.utf8)
            let rows = data?.components(separatedBy: "\r\n")
            for row in rows! {
                var columns = row.components(separatedBy: ",")
                if columns.count < 2  {
                    continue
                }
                if columns[1] == self.findStr {
                    mResult = true
                    break
                }
            }
        }
        self.findNot.hide(animated: true)
        if mResult == true {
            self.displayMyAlertMessage(titleMsg: "On DNCL", alertMsg: "")
        } else {
            self.displayMyAlertMessage(titleMsg: "Not Found", alertMsg: "")
        }
    }

    func displayMyAlertMessage( titleMsg: String, alertMsg: String) {
        let alertdialog = UIAlertController(title: titleMsg, message: alertMsg , preferredStyle: UIAlertControllerStyle.alert)
        alertdialog.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){(ACTION) in
        })
        self.present(alertdialog,animated: true)
    }
    
    @IBAction func downloadBtnTapped(_ sender: UIButton) {
        
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.detailsLabel.text = "Downloading 343.csv"
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("343.csv")
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: fileUrl343)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                        try FileManager.default.removeItem(at: destinationFileUrl)
                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Error Occured");
            }

            DispatchQueue.main.async {
                progress.hide(animated: true)
                self.download613CSV()
            }
        }
        task.resume()
        
    }
    
    private func download613CSV() {
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.detailsLabel.text = "Downloading 613.csv"
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("613.csv")
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: fileUrl613)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                        try FileManager.default.removeItem(at: destinationFileUrl)
                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Error Occured");
            }
            
            DispatchQueue.main.async {
                progress.hide(animated: true)
            }
        }
        task.resume()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender == mainBtn {
            actionMethod = true
        } else {
            actionMethod = false
        }

        configureUI(action: actionMethod)
    }
    @IBAction func phoneNumberChanged(_ sender: Any) {
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPhone.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.textLabel?.text = arrayPhone[indexPath.row] as? String
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listBtn.setTitle(arrayPhone[indexPath.row] as? String, for: .normal)
        self.tblPhoneList.isHidden = true
    }
}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.phoneTxt.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.phoneTxt.resignFirstResponder()
        self.tblPhoneList.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength == 4 && range.location == 3{
            textField.text?.append("-")
        }
        return newLength <= 8
    }
}
