//
//  TabBarController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 11. 18..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.selectedIndex = 0
        self.tabBar.items?[0].title = "Sale"
        self.tabBar.items?[1].title = "Buy"
        self.tabBar.items?[0].image = self.resizeImage(image: UIImage(named: "sell_tab.png")!, targetSize: CGSize(width: 30, height: 30))
        self.tabBar.items?[1].image = self.resizeImage(image: UIImage(named: "buy_tab.png")!, targetSize: CGSize(width: 30, height: 30))
        // Do any additional setup after loading the view.
//        self.tabBarController?.viewControllers?.forEach{$0.view}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /**
     Resize a UIImage view
     source: http://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
     - image: Image you wish to resize
     - targetSize: Size of the new image
     */
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
