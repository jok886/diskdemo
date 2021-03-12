//
//  ViewFilesTableViewController.swift
//  diskdemo
//
//  Created by macliu on 2021/3/12.
//

import UIKit
import AVKit
import GradientCircularProgress


private let FolderCellID: String = "FolderCellID"


class ViewFilesTableViewController: UITableViewController {

    var fileViewer: FileViewer = FileViewer()
    var fileInfo: [String] = []
    var Path : String {
        //1.从沙盒归档读取
        //1.1沙盒
        let accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return accountPath
    }
    let progress = GradientCircularProgress()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Files"
        self.getDirectoryList()
        self.tableView.tableFooterView = UIView()
        self.tableView.register(FolderTableViewCell.self, forCellReuseIdentifier: FolderCellID)
        self.tableView.reloadData()
        
    }

    func getDirectoryList() {
        self.fileViewer.getAllFilePath(Path, completion: { (arr, err) in
            fileInfo = arr
            
        })
   
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.fileInfo.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: FolderCellID, for: indexPath) as! FolderTableViewCell


        let name = self.fileInfo[indexPath.row]
        
        let type = fileViewer.determineMediaType(fileInfo: self.fileInfo[indexPath.row])
        switch type {
            case .image:
                cell.iconView.image = UIImage(contentsOfFile: name)
            case .video:
                cell.iconView.image = UIImage(named: "videoIcon")
            case .pdf:
                cell.iconView.image = UIImage(named: "fileIcon")
            default:
                cell.iconView.image = UIImage(named: "fileIcon")
        }
        cell.NameLabel.text = (name as NSString).lastPathComponent as String
        
        

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = self.fileInfo[indexPath.row]
        
        let type = fileViewer.determineMediaType(fileInfo: self.fileInfo[indexPath.row])
        switch type {
            case .image:
                let vc = PhotoDetailViewController()
                vc.file = name
                vc.thumbnail = UIImage(contentsOfFile: name)
                self.navigationController?.pushViewController(vc, animated: true)
            case .video:
                let url = URL(fileURLWithPath: name)
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            case .pdf:
                let vc = PDFDetailViewController()
                vc.file = name
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                print("w00t")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
