//
//  BackupPhotosViewController.swift
//  diskdemo
//
//  Created by macliu on 2021/3/11.
//

import UIKit
import DKImagePickerController
import GradientCircularProgress
import Photos

private let PhotoCellID: String = "PhotoCellID"

class BackupPhotosViewController: UIViewController {

    // MARK:--btn
    private lazy var tableview : UITableView = UITableView()
    
    
    var data: [MoreOptionsCellModel] = []
    var pickerController = DKImagePickerController()
    let mediaSaver = MediaSaver()
    let progress = GradientCircularProgress()
    
    
    var didSelectClosure = {(assets: [DKAsset]) in}
    var userUpdateClosure = {(completed: Int, total: Int) in}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        self.title = "Backup Photos/Videos"
        
        
        let bs = "Tap this option to backup all photos and videos to the external device"
        let b = MoreOptionsCellModel(title: "Backup All Photos/Videos", description: bs, icon: UIImage(named: "photoBackup"), cellTappedMethod: self.backupAllPhotosVideosTapped)
        let ss = "Tap this option to select exactly which photos/videos you want to backup"
        let s = MoreOptionsCellModel(title: "Select Photos/Videos to Backup", description: ss, icon: UIImage(named: "selection"), cellTappedMethod: self.selectPhotosVideosTapped)
        
        data = [b,s]
        tableview.reloadData()
        
        self.userUpdateClosure = {
            (completed: Int, total: Int) in
            DispatchQueue.main.async {
                self.progress.updateMessage(message: "Saving Photos/Videos\n\(completed) out of \(total)")
            }
        }
        self.didSelectClosure = {
            (assets: [DKAsset]) in
            
            if assets.count == 0 {
                return
            }
            //
            self.progress.show(message: "Saving Photos/Videos\nout of \(assets.count)", style: ContactsStyle())
            
           //
            self.mediaSaver.saveListOfAssets(assetList: assets, userUpdate: self.userUpdateClosure) { (err) in
                DispatchQueue.main.async {
                    if err != EAError.none {
                        UIController.showError(vc: self)
                    }else {
                        UIController.showAlert(vc: self, title: "Photos Saved Successfully", message: "Your photos have been saved to the external device")
                    }
                    self.progress.dismiss()
                    self.resetPickerController()
                }
            }
            
            
            
            
            
            
        }
        
        self.pickerController.didSelectAssets = self.didSelectClosure
        self.pickerController.showsCancelButton = true
        
        self.pickerController.didCancel = {
            self.resetPickerController()
        }
    }


}
extension BackupPhotosViewController {
    func backupAllPhotosVideosTapped() {
        
        //Check permissions for photo library
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                self.backupAllPhotosVideosTapped()
            }
            return
        }else if status == PHAuthorizationStatus.denied {
            //
            UIController.showAlert(vc: self, title: "Photo Permission Needed", message: "Photo access is absolutely necessary to backup photos")
            return
        }
        //Update the UI for user feedback
        self.progress.show(message: "Saving Photos/Videos\n  ", style: ContactsStyle())
        self.mediaSaver.saveAllMedia(progressFunc: {
            (count,total) in
            self.progress.updateMessage(message: "Saving Photos/Videos\n\(count) out of \(total)")
        } , completion:{ (err) in
            self.progress.dismiss()
            if err != EAError.none {
                UIController.showError(vc: self)
            } else {
                UIController.showAlert(vc: self, title: "Photos Saved Successfully", message: "Your photos have been saved to the external device")
            }
        })
        
    }
    func selectPhotosVideosTapped() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization() {
                (status ) in
                self.selectPhotosVideosTapped()
            }
            return
        } else if status == PHAuthorizationStatus.denied {
            // Access has been denied.
            UIController.showAlert(vc: self, title: "Photo Permission Needed", message: "Photo access is absolutely necessary to backup photos")
            return
        }
        
        self.present(pickerController, animated: true) {}
        
        
    }
    func resetPickerController() {
        self.pickerController = DKImagePickerController()
        self.pickerController.didSelectAssets = self.didSelectClosure
        self.pickerController.showsCancelButton = true
        
    }
    
}
// MARK:--UI
extension BackupPhotosViewController {
    private func setupUI () {
     
        self.view.addSubview(tableview)
        tableview.frame = self.view.frame
       // tableview.backgroundColor = UIColor.green
    
      //  tableview.register(PhotoCell.self, forCellReuseIdentifier: PhotoCellID)
        // xib创建的cell用这种方式注册
        tableview.register(UINib(nibName: "PhotoCell", bundle: nil), forCellReuseIdentifier:PhotoCellID);

        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView()
        
        
        
    }
}
extension BackupPhotosViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCellID, for: indexPath) as! PhotoCell
        

        let img = self.data[indexPath.row].icon
        cell.icon.image = img
        cell.title.text = self.data[indexPath.row].title
        cell.subtitle.text = self.data[indexPath.row].description
    /*    var cell = tableView.dequeueReusableCell(withIdentifier: PhotoCellID)
        if cell == nil {
            
            cell = UITableViewCell.init(style: .default, reuseIdentifier: cellId)
        }
        */
        
       // cell.title.text = "测试数据 --- \(indexPath.row)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    //MARK:- 代理方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // MGLog("点击了 --- \(indexPath.row)")
        
        self.data[indexPath.row].cellTappedMethod()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
