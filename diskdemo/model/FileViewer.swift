//
//  FileViewer.swift
//  diskdemo
//
//  Created by macliu on 2021/3/12.
//

import Foundation
import UIKit

class FileViewer {
    let fileManager: FileManager = FileManager.default
    
    
    
    public func determineMediaType(fileInfo: String) -> MediaType {
        
        var fileExtension = ""
        let name: String = (fileInfo as! NSString).lastPathComponent as! String
        if name != nil {
            let lastIndex = name.lastIndex(of: ".")!
            let range = name.index(after: lastIndex)..<name.endIndex
            fileExtension = name.substring(with: range)
            
        }
        fileExtension = fileExtension.lowercased()
        
        switch fileExtension {
            case "mov","mp4":
                return MediaType.video
            case "pdf":
                return MediaType.pdf
            case "jpg", "jpeg", "png", "heic":
                return MediaType.image
            default:
                return MediaType.unknown
        }
        
    }
    
    
    public func getAllFilePath(_ dirPath: String ,completion: ([String], EAError) -> Void) {
        
        //var filePaths = [String]()
        
        
        
        
        var  array = self.getAllFilesAtPath(path: dirPath)
        completion(array as! [String], EAError.none)
    }
    
    func getAllFilesAtPath(path: String) -> NSArray {
        
        var tempPathArray = Array<Any>()
        
      //  NSMutableArray *tempPathArray = [NSMutableArray array];
        
        do {
            let array = try fileManager.contentsOfDirectory(atPath: path)
            
            for file in array {
                let fullPath = "\(path)/\(file)"
                var isDir: ObjCBool = true
                
                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    if !isDir.boolValue {
                        let a = (file as NSString).substring(to: 1) as NSString
                        if !a.isEqual(to: ".") {
                            tempPathArray.append(fullPath)
                        }
                       
                    }else {
                        let subPathArray = self.getAllFilesAtPath(path: fullPath)
                        
                        
                        [tempPathArray .append(contentsOf: subPathArray as! [String])];
                    }
                }
            }
            
            
            
            
        }catch let error as NSError {
            print("get file path error: \(error)")
        }
        
        return tempPathArray as NSArray;
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
    
    
}
