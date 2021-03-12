//
//  MediaSaver.swift
//  diskdemo
//
//  Created by macliu on 2021/3/11.
//

///Users/macliu/Library/Caches/CocoaPods/Pods/Release

//  pod install --verbose --no-repo-update
///var/folders/yx/sl6w0phn1fz014mk58gy2hwr0000gn/T/d20210311-10664-gu5rme

import Foundation

import UIKit
import DKImagePickerController
import Photos

class MediaSaver {
    var isCanceled = false
    
    let fileManager: FileManager = FileManager.default
    
    //计算属性
    var accountPath : String {
        //1.从沙盒归档读取
        //1.1沙盒
        let accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return accountPath
         //   (accountPath as NSString).appendingPathComponent(DirectoryNames.Media.rawValue)
    }
    
    
    var alreadyBackedUp : [String:Bool] = [:]
    public func saveAllMedia(progressFunc: @escaping (Int, Int) -> Void, completion: @escaping (EAError) -> Void) {
        
        
        //
        DispatchQueue.global(qos: .userInteractive).async {
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue,PHAssetMediaType.video.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            //
            options.fetchLimit = 0
            
            let allAssets = PHAsset.fetchAssets(with: options)
            let taskIdentifier = UIApplication.shared.beginBackgroundTask {
                () in
                //
            }
            self.getAssetsFromHardDriveAndSaveToAccessory(assets: allAssets, progressFunc: progressFunc) {
                (err) in
                
                UIApplication.shared.endBackgroundTask(taskIdentifier)
                
                DispatchQueue.main.async {
                    completion(err)
                }
            }
        }
    }
    
    private func setupConnection() -> EAError {
        let dirErr: EAError = self.createDirectoryIfNotExists(path: "/", directoryName: DirectoryNames.Media.rawValue)
        if dirErr != EAError.none {
          //  self.sessionController.closeSession()
            return dirErr
        }
        
        return EAError.none
        
    }
    private func getAssetsFromHardDriveAndSaveToAccessory(assets: PHFetchResult<PHAsset>, progressFunc: @escaping (Int, Int) -> Void, completion: @escaping (EAError) -> Void) {
        
        let setupError = self.setupConnection()
        if setupError != EAError.none {
            completion(setupError)
            return
        }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        let videoOptions = PHVideoRequestOptions()
        videoOptions.isNetworkAccessAllowed = true
        
        let group = DispatchGroup()
        var asyncError = EAError.none
        
        //Perform an indexing step where we check for photos already backed up
        self.checkForAlreadyUploadedFiles(assets: assets)
        
        //
        assets.enumerateObjects { (object, count, stop) in
            autoreleasepool{
                
                if asyncError != EAError.none {
                    return
                }
                if self.isCanceled {
                    asyncError = EAError.backupCanceled
                    completion(asyncError)
                    self.isCanceled = false
                    return
                }
                //
                let folderName = "Photos0"
                
                if count == 0 {
                    //Make sure that Photos0 actually exists
                    let dirErr = self.createDirectoryIfNotExists(path: "/" + DirectoryNames.Media.rawValue, directoryName: folderName)
                    if dirErr != EAError.none {
                        asyncError = dirErr
                        completion(dirErr)
                        return
                    }
                }
                
                let type = object.mediaType
                if type == .image {
                    let saveError = self.saveImageAsset(manager: manager, object: object, options: options, folderName: folderName)
                    if saveError != EAError.none {
                        DispatchQueue.main.async {
                            completion(saveError)
                        }
                        asyncError = saveError
                       // self.sessionController.closeSession()
                        return
                    }
                }else if type == .video {
                    group.enter()
                    self.saveVideoAsset(manager: manager, object: object, videoOptions: videoOptions, folderName: folderName) {
                        (err) in
                        
                        if err != EAError.none {
                            DispatchQueue.main.async {
                                completion(err)
                            }
                            asyncError = err
                          //  self.sessionController.closeSession()
                            group.leave()
                            return
                        }
                        group.leave()
                    }
                    group.wait()
                }
                
                //
                //Tell the end user how many uploads have been completed
                DispatchQueue.main.async {
                    progressFunc(count + 1, assets.count)
                }
                
            }
        }
        
        //Make sure we call the completion handler once and only once. It is called where errors occur above
        if asyncError == EAError.none {
            DispatchQueue.main.async {
                completion(EAError.none)
            }
        }
        
        
    }
    
    //User update tells the user how many images out of the total have been updated
    func saveListOfAssets(assetList: [DKAsset], userUpdate: @escaping (Int, Int) -> Void, completion: @escaping (EAError) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            //1. Create directory if not exists
            let dirErr = self.createDirectoryIfNotExists(path: "/", directoryName: DirectoryNames.SelectedPhotos.rawValue)
            
            if dirErr != EAError.none {
                completion(dirErr)
                return
            }
            
            
            //2. Save media to media directory. Update user after each media completes
            //Note: Session is closed inside uploadAssetListToDevice. It must be done there
            self.uploadAssetListToDevice(assetList: assetList, userUpdate: userUpdate, completion: completion)
            
        }
        
    }
    
    func uploadAssetListToDevice(assetList: [DKAsset], userUpdate: @escaping (Int, Int) -> Void, completion: @escaping (EAError) -> Void) {
        
        let total = assetList.count
        var stop = false
        let group = DispatchGroup()
        
        for i in 0..<assetList.count {
            group.enter()
            if stop {
                group.leave()
                break
            }
            
            if assetList[i].type == .video {
                //
                guard let asset = assetList[i].originalAsset else {
                    completion(EAError.fetchVideoDataFromSystem)
                    group.leave()
                    return
                }
                //
                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, mix, nil) in
                    
                    let myAsset = asset as? AVURLAsset
                    do {
                        guard let assetURL = myAsset else {
                            completion(EAError.fetchVideoDataFromSystem)
                            stop = true
                            group.leave()
                            return
                        }
                        
                        let videoData = try Data(contentsOf: assetURL.url)
                        let name = assetURL.url.lastPathComponent
                        
                        let uploadError = self.saveDataToMediaDirectory(dataToSave: videoData, name: name, path: "/", folderName: DirectoryNames.SelectedPhotos.rawValue)
                        if uploadError != EAError.none {
                            completion(uploadError)
                            stop = true
                            group.leave()
                            return
                        }
                        
                        
                    }catch  {
                        completion(EAError.fetchVideoDataFromSystem)
                        stop = true
                        group.leave()
                        return
                    }
                    userUpdate(i + 1, total)
                    group.leave()
                }
            }else {
                //Handle images
                assetList[i].fetchImageData { (data, info) in
                    guard let data = data else {
                        completion(EAError.fetchImageDataFromSystem)
                        stop = true
                        group.leave()
                        return
                    }
                    var name = ""
                    if let filName = assetList[i].originalAsset?.value(forKey:  "filename") as? String{
                        name = filName
                    }else {
                        name = "\(Int(Date().timeIntervalSince1970))"
                    }
                    let uploadError = self.saveDataToMediaDirectory(dataToSave: data, name: name, path: "/", folderName: DirectoryNames.SelectedPhotos.rawValue)
                    if uploadError != EAError.none {
                        completion(uploadError)
                        stop = true
                        group.leave()
                        return
                    }
                    userUpdate(i + 1, total)
                    group.leave()
                    
                    
                }
                
            }
            //This for loop must be executed synchronously on a background thread. The PHImageManager asynchronous call makes this a little tricky. Use group.wait() to achieve this
            group.wait()
            
        }
        if !stop {
            completion(EAError.none)
        }
    }
    
    //Pass either the image or the video URL, not both
    func saveCapturedMedia(named name: String, mediaType: MediaType, image: UIImage?, videoURL: URL?, completion: @escaping (EAError) -> Void)  {
        
        DispatchQueue.global(qos: .userInteractive).async {
            //
            var _writeData: Data = Data()
            switch mediaType {
                case .image:
                    if let data = image?.jpegData(compressionQuality: 1.0) {
                        _writeData = data
                    }else {
                        completion(EAError.invalidImageFormat)
                        return
                    }
                case .video:
                    do {
                        if let url = videoURL {
                            let videoData = try Data(contentsOf: url)
                            _writeData = videoData
                        }
                    } catch  {
                        completion(.invalidVideoFormat)
                        return
                    }
                default:
                    completion(.invalidVideoFormat)
                    return
            }
            var modifiedName = name
            switch mediaType {
            case .video:
                modifiedName += ".MOV"
            case .image:
                modifiedName += ".JPG"
            default:
                //Should not be here
                completion(EAError.invalidVideoFormat)
                return
            }
            
            //Create directory if not exists
            let dirErr = self.createDirectoryIfNotExists(path: "/", directoryName: DirectoryNames.BackupGeniusCameraRoll.rawValue)
            if dirErr != EAError.none {
                completion(dirErr)
                return
            }
            
            
            let folderName = DirectoryNames.BackupGeniusCameraRoll.rawValue
            var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
            self.createDirectory(path: accountPath, directoryName: folderName)
            
            let apath   = (accountPath as NSString).appendingPathComponent(folderName)
            
            let filePath = (apath as NSString).appendingPathComponent(modifiedName)
            let url = URL(fileURLWithPath: filePath)
            
            do {
                try _writeData.write(to: url)
            }catch {
                completion(EAError.writeFile)
                return
            }
            completion(EAError.none)
            
            
        }
        
    }
    
    private func saveImageAsset(manager: PHImageManager, object: PHAsset, options: PHImageRequestOptions, folderName: String) -> EAError {
        var imageSaveError = EAError.none
        
        //
        manager.requestImageData(for: object, options: options) { (someData, someString, imageOrientation, someDictionary) in
            //
            let fileURL = someDictionary?["PHImageFileURLKey"] as? URL
            var fileName = "\(Int(Date().timeIntervalSinceNow)).JPG"
            if let name = fileURL?.lastPathComponent {
                fileName = name
            }
            //
            if let isBackup = self.alreadyBackedUp[fileName] {
                if isBackup {
                    //Skip this file backup
                    return
                }
            }
            
            //
            //Save the Data to the hard drive
            guard let imageData = someData else {
                
                //self.sessionController.closeSession()
                //imageSaveError = EAError.fetchImageDataFromSystem
                
                print("Unable to fetch asset: \(object)")
                imageSaveError = EAError.none
                return
            }
            
            //
            let saveOk: EAError = self.saveDataToMediaDirectory(dataToSave: imageData, name: fileName, path: "/" + DirectoryNames.Media.rawValue, folderName: folderName)
            
            if saveOk != EAError.none {
                print("Retrying the image connection")
                let retryError = self.setupConnection()
                if retryError != EAError.none {
                    //Unable to reconnect. Bail out.
                    print("Unable to reconnect image")
                //    self.sessionController.closeSession()
                    imageSaveError = retryError
                    return
                } else {
                    let retrySaveOk: EAError = self.saveDataToMediaDirectory(dataToSave: imageData, name: fileName, path: "/" + DirectoryNames.Media.rawValue, folderName: folderName)
                    if retrySaveOk != EAError.none {
                        print("Unable to save image")
                        //Still can't save for some reason. Bail out
                    //    self.sessionController.closeSession()
                        imageSaveError = retrySaveOk
                        return
                    }
                }
            }
        }
        
        return imageSaveError
    }
    private func saveVideoAsset(manager: PHImageManager, object: PHAsset, videoOptions: PHVideoRequestOptions, folderName: String, completion: @escaping (EAError) -> Void) {
        
        manager.requestAVAsset(forVideo: object, options: videoOptions) { (someAvAsset, someAvAudioMix, someDictionary) in
            guard let videoAsset: AVURLAsset = someAvAsset as? AVURLAsset else {
                print("Unable to fetch asset: \(object)")
                completion(EAError.none)
                
                return
            }
            let fileName = videoAsset.url.lastPathComponent
            
            if let isBackedUp = self.alreadyBackedUp[fileName] {
                if isBackedUp {
                    completion(EAError.none)
                    return
                }
            }
            
            do {
                let videoData = try Data(contentsOf: videoAsset.url)
                
                let saveOk: EAError = self.saveDataToMediaDirectory(dataToSave: videoData, name: fileName, path: "/" + DirectoryNames.Media.rawValue, folderName: folderName)
                //Retry the connection if we get an error
                if saveOk != EAError.none {
                    //Lets try to get the connection again
                    print("Retrying the video connection")
                    let retryError = self.setupConnection()
                    if retryError != EAError.none {
                        //Unable to reconnect. Bail out.
                        print("Unable to connect to video")
                      //  self.sessionController.closeSession()
                        completion(retryError)
                        return
                    } else {
                        let retrySaveOk: EAError = self.saveDataToMediaDirectory(dataToSave: videoData, name: fileName, path: "/" + DirectoryNames.Media.rawValue, folderName: folderName)
                        if retrySaveOk != EAError.none {
                            //Still can't save for some reason. Bail out
                            print("Still can't save video")
                         //   self.sessionController.closeSession()
                            completion(retrySaveOk)
                            return
                        }
                    }
                }
                
                
                
                
                
            }catch {
                //Something went wrong getting the video data. Just skip this file
            }
            completion(EAError.none)
        }
        
    }
    
    func saveDataToMediaDirectory(dataToSave: Data, name: String, path: String, folderName: String) -> EAError {
        var writeData = dataToSave
        
        var rerror = EAError.none
        
        var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        self.createDirectory(path: accountPath, directoryName: folderName)
        
        let apath   = (accountPath as NSString).appendingPathComponent(folderName)
        
        let filePath = (apath as NSString).appendingPathComponent(name)
        let url = URL(fileURLWithPath: filePath)
        
        do {
            try writeData.write(to: url)
        }catch {
            rerror = EAError.writeFile
        }
        
        return rerror
        
    }
    
    func jKShallowSearchAllFiles(folderName: NSString) -> NSArray {
     
        let filePath = "\(folderName)"
        let exist = fileManager.fileExists(atPath: filePath)
          // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
          if (exist) {
             let contentsOfPathArray = fileManager.enumerator(atPath: filePath)
             return contentsOfPathArray!.allObjects as NSArray
          }else{
             return []
          }
        
        
     
     }
    
    
    func checkForAlreadyUploadedFiles(assets: PHFetchResult<PHAsset>) {
        //1. Get DIR listing
        guard let list = self.jKShallowSearchAllFiles(folderName: (self.accountPath as NSString)) as? NSArray else {
            return
        }
        for file in list {
            let name = (file as! NSString).lastPathComponent
            self.alreadyBackedUp[name] = true
        }
        
        
    }
    
    func createDirectoryIfNotExists(path: String, directoryName: String) -> EAError {
        
        
        
        var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
  
        
        return createDirectory(path: accountPath, directoryName: directoryName)
        
        
        //List all directories at the given path. "/" is the root path
    /*    let directoryList: [FileInfo]? = self.sessionController.listDir(path) as? [FileInfo]
        
        guard let list = directoryList else {
            //If there is no directory list, go ahead and create the directory
            return createDirectory(path: path, directoryName: directoryName)
        }
        
        var foundDir = false
        for item in list {
            if item.isFolder {
                if item.name == directoryName {
                    foundDir = true
                    break
                }
            }
        }
        
        if foundDir {
            return EAError.none
        } else {
            return createDirectory(path: path, directoryName: directoryName)
        }*/
    }
    
    func createDirectory(path: String, directoryName: String) -> EAError {
        
        let apath   = (path as NSString).appendingPathComponent(directoryName)
        
        if !FileManager.default.fileExists(atPath: apath) {
            do {
                try FileManager.default.createDirectory(atPath: apath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
                return EAError.createDirectory
            }
        }
        
        
        
       // if !self.sessionController.createDir(path, dir: directoryName) {
      //      return EAError.createDirectory
      //  }
        
        return EAError.none
    }
    
    //4.1沙盒
  //  var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
  //  accountPath = (accountPath as NSString).appendingPathComponent("account.plist")
  //  print(accountPath)
    
    
}
