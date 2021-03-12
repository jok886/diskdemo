//
//  PDFDetailViewController.swift
//  diskdemo
//
//  Created by macliu on 2021/3/12.
//

import UIKit
import WebKit
import GradientCircularProgress

class PDFDetailViewController: UIViewController {
    
    let webview: WKWebView = WKWebView()
    var file: String?
    var fileViewer: FileViewer = FileViewer()
    
    let progress = GradientCircularProgress()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addSubview(webview)
        let height = self.navigationController?.navigationBar.frame.height
        let frame = CGRect(x: 0, y: height!, width: self.view.frame.width, height: self.view.frame.height - height!)
        webview.frame = frame
        
        self.progress.show(message: "Loading...", style: ContactsStyle())
        
        let url = URL(fileURLWithPath: file!)
        
        webview.load(URLRequest(url: url))
        
        self.progress.dismiss()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = (file as! NSString).lastPathComponent as String
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
