//
//  MemeDetailView.swift
//  MemeMe2.0
//
//  Created by Shubham Jindal on 07/03/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController:UIViewController {
    
    @IBOutlet weak var memeImage: UIImageView!
    var meme: MemeModel!
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        memeImage.image = meme.memedImage
        self.tabBarController?.tabBar.isHidden = true
    
    }
}


