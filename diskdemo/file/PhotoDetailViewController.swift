//
//  PhotoDetailViewController.swift
//  diskdemo
//
//  Created by macliu on 2021/3/12.
//

import UIKit
import GradientCircularProgress

class PhotoDetailViewController: UIViewController,UIScrollViewDelegate {

    var scrollView: UIScrollView = UIScrollView()
    var imgPhoto: UIImageView = UIImageView()
    
    var thumbnail : UIImage?
    var file: String?
    var fileViewer: FileViewer = FileViewer()
    
    let progress = GradientCircularProgress()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(scrollView)
        self.view.addSubview(imgPhoto)
        scrollView.frame = self.view.frame
        imgPhoto.frame = self.view.frame
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        imgPhoto.contentMode = .scaleAspectFit
        
        
        
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgPhoto
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = (file as! NSString).lastPathComponent as String
        if let image = self.thumbnail {
            self.imgPhoto.image = thumbnail
        }
        
        self.progress.show(message: "Loading...", style: ContactsStyle())
        
        self.imgPhoto.image = UIImage(contentsOfFile: file!)
        self.progress.dismiss()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
