//
//  ContactsSaver.swift
//  diskdemo
//
//  Created by macliu on 2021/3/12.
//

import Foundation
import Contacts

class ContactsSaver {
    var contacts: [CNContact] = []
    
    
    let fileManager: FileManager = FileManager.default
    
    public func saveAllContacts(completion: @escaping (EAError)->Void){
        self.saveAll { (err) in
            DispatchQueue.main.async {
                completion(err)
            }
        }
    }
    private func saveAll(completion: @escaping (EAError) -> Void) {
        //
        DispatchQueue.global(qos: .userInteractive).async {
            //
            let dirErr = self.createContactsDirectoryIfNotExists()
            if dirErr != EAError.none {
                completion(dirErr)
                return
            }
            self.fetchAllContacts()
            //3. Save data to device
            let writeData = self.createContactDataFromContacts()
            let fileName = "All_Contacts_\(Int(Date().timeIntervalSince1970)).vcf"
            let err = self.saveDataToContactsDirectory(writeData: writeData, name: fileName)
            if err != EAError.none {
                completion(err)
                self.contacts = []
                return
            }
            self.contacts = []
            
            completion(EAError.none)
            
            
        }
    }
    private func saveDataToContactsDirectory(writeData: Data, name: String) -> EAError {
        
        var dataCopy = writeData
        
        var writeError = EAError.none
        
        var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
       // self.createDirectory(path: accountPath, directoryName: folderName)
        
  
        
        let filePath = (accountPath as NSString).appendingPathComponent(name)
        let url = URL(fileURLWithPath: filePath)
        
        do {
            try dataCopy.write(to: url)
        }catch {
            writeError = EAError.writeFile
        }
        
        return writeError
        
        
    }
    private func fetchAllContacts() {
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, pointer) in
                self.contacts.append(contact)
            })
        } catch  {
            print(error)
        }
    }
    
    private func createContactDataFromContacts() -> Data {
        var data: Data = Data()
        do {
            data = try CNContactVCardSerialization.data(with: self.contacts)
            return data
        } catch  {
            print("error \(error)")
            return data
        }
    }
    
    private func createContactsDirectoryIfNotExists() -> EAError {
        
        var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        guard let list = self.jKShallowSearchAllFiles(folderName: (accountPath as NSString)) as? NSArray else {
            return EAError.createDirectory
        }
        var foundContactsDir = false
        for file in list {
            let name = (file as! NSString).lastPathComponent
            
            if name == DirectoryNames.Contacts.rawValue  {
                foundContactsDir = true
                break
            }
          
        }
        
        if foundContactsDir {
            return EAError.none
        } else {
            return createContactsDirectory()
        }
        
    }
    private func createContactsDirectory() -> EAError {
        
        var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let directoryName = DirectoryNames.Contacts.rawValue
        let apath   = (accountPath as NSString).appendingPathComponent(directoryName)
        
        if !FileManager.default.fileExists(atPath: apath) {
            do {
                try FileManager.default.createDirectory(atPath: apath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
                return EAError.createDirectory
            }
        }
        return EAError.none
        
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
