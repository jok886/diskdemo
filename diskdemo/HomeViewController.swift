//
//  HomeViewController.swift
//  diskdemo
//
//  Created by macliu on 2021/3/11.
//

import UIKit
import SnapKit


class HomeViewController: UIViewController {

    // MARK:--btn
    private lazy var testButton : UIButton = UIButton()
    
    let contactsSaver = ContactsSaver()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.title = "home"
        UIController.configureNavBar(navigationController: self.navigationController)
        
        setupUI()
        
    }


}
// MARK:--UI
extension HomeViewController {
    private func setupUI () {
     
        self.view.addSubview(testButton)
        testButton.snp_makeConstraints { (make) in
            make.top.equalTo(100)
            make.left.equalTo(30)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        testButton.backgroundColor = UIColor.green
        testButton.setTitle("test", for: .normal)
        testButton.setTitleColor(UIColor.black, for: .normal)
        testButton.addTarget(self, action: #selector(self.BtnClick), for: .touchUpInside)
        
        
        
        var savecontact: UIButton = UIButton()
        self.view.addSubview(savecontact)
        savecontact.snp_makeConstraints { (make) in
            make.top.equalTo(100)
            make.left.equalTo(150)
            make.height.equalTo(30)
            make.width.equalTo(160)
        }
        savecontact.backgroundColor = UIColor.green
        savecontact.setTitle("backupcontacts", for: .normal)
        savecontact.setTitleColor(UIColor.black, for: .normal)
        savecontact.addTarget(self, action: #selector(self.ContactClick), for: .touchUpInside)
        
        var fileBtn: UIButton = UIButton()
        self.view.addSubview(fileBtn)
        fileBtn.snp_makeConstraints { (make) in
            make.top.equalTo(150)
            make.left.equalTo(30)
            make.height.equalTo(30)
            make.width.equalTo(60)
        }
        fileBtn.backgroundColor = UIColor.green
        fileBtn.setTitle("file", for: .normal)
        fileBtn.setTitleColor(UIColor.black, for: .normal)
        fileBtn.addTarget(self, action: #selector(self.FileClick), for: .touchUpInside)
        
        
    }
}
// MARK:--事件
extension HomeViewController {
    @objc func BtnClick(){
        NSLog("123")
        self.navigationController?.pushViewController(BackupPhotosViewController(), animated: true)
    }
    @objc func ContactClick(){
        NSLog("123")
        self.contactsSaver.saveAllContacts { (err) in
            if err != EAError.none {
                UIController.showError(vc: self)
            }else{
                UIController.showAlert(vc: self, title: "info", message: "ok")
            }
        }
    }
    
    @objc func FileClick(){
        self.navigationController?.pushViewController(ViewFilesTableViewController(), animated: true)
    }
    
}
