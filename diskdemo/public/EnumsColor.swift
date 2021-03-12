//
//  EnumsColor.swift
//  diskdemo
//
//  Created by macliu on 2021/3/11.
//

import Foundation
import UIKit

extension UIColor {
    static var datalogixxBlue: UIColor = UIColor(red: 47.0/255, green: 150.0/255, blue: 247.0/255, alpha: 1.0)
    static var datalogixxRed: UIColor = UIColor(red: 172.0/255, green: 56.0/255, blue: 97.0/255, alpha: 1.0)
    static var datalogixxGrey: UIColor = UIColor(red: 186.0/255, green: 178.0/255, blue: 181.0/255, alpha: 1.0)
    static var datalogixxCream: UIColor = UIColor(red: 238.0/255, green: 226.0/255, blue: 220.0/255, alpha: 1.0)
    static var datalogixxPeach: UIColor = UIColor(red: 237.0/255, green: 199.0/255, blue: 183.0/255, alpha: 1.0)
    static var datalogixxGreen: UIColor = UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000)
    static var datalogixxYellow: UIColor = UIColor(red: 255.0/255, green: 204.0/255, blue: 0.0, alpha: 1.0)
    
    
    
}

enum EAError: Error {
    case openSession
    case invalidImageFormat
    case invalidVideoFormat
    case fileSystemInit
    case openFile
    case writeFile
    case readFile
    case createDirectory
    case openDirectory
    case fetchImageDataFromSystem
    case fetchVideoDataFromSystem
    case reformat
    case backupCanceled
    case none
}

enum MediaType {
    case video
    case image
    case pdf
    case unknown
}
enum DirectoryNames: String {
    case Media = "Photo_And_Video_Backups"
    case Contacts = "Contacts"
    case BackupGeniusCameraRoll = "Backup_Genius_Camera_Roll"
    case SelectedPhotos = "Selected_Photo_And_Video"
}

enum CellHeight: CGFloat {
    case Default = 125
}

enum BackupGeniusDefaults: String {
    case NumberOfLaunches = "com.backupGenius.numberOfLaunches"
    case AskedForRating = "com.backupGenius.askedForRating"
}

