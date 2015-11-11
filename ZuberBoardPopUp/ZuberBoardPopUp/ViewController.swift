//
//  ViewController.swift
//  ZuberBoardPopUp
//
//  Created by duzhe on 15/11/10.
//  Copyright © 2015年 duzhe. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController{

    var replayView:ZuberBoardPopUp!
    override func viewDidLoad() {
       super.viewDidLoad()
        if let replayView = NSBundle.mainBundle().loadNibNamed("ZuberBoardPopUp", owner: self, options: nil)[0] as? ZuberBoardPopUp{
        
            self.replayView = replayView
            self.view.addSubview(self.replayView)
            self.replayView!.snp_makeConstraints{ (make) -> Void in
                make.height.equalTo(50)
                make.left.equalTo(self.view.snp_left)
                make.right.equalTo(self.view.snp_right)
                make.bottom.equalTo(self.view.snp_bottom)
            }
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:"handleTouches:")
            tapGestureRecognizer.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func handleTouches(sender:UITapGestureRecognizer){
        if sender.locationInView(self.view).y < self.view.bounds.height - 250{
            self.replayView?.textView.resignFirstResponder()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

