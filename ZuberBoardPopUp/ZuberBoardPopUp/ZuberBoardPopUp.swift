//
//  ZuberBoardPopUp.swift
//  zuber
//
//  Created by duzhe on 15/11/10.
//  Copyright © 2015年 duzhe. All rights reserved.
//

import UIKit
import SnapKit

let MAIN_COLOR = UIColor(red: 52/255.0, green: 197/255.0, blue:
    170/255.0, alpha: 1.0)
class ZuberBoardPopUp: UIView {
    
    @IBOutlet weak var textView: UITextView!
    var overView:UIView!
    @IBOutlet weak var replayPerson: UILabel!
    @IBOutlet weak var headView: UIImageView!
    
    @IBOutlet weak var replayBtn: UIButton!
    @IBOutlet weak var replayHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    var isSHow = false
    var selfHeight:CGFloat = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
        textView.text = "说点什么?"
        textView.textColor = UIColor.grayColor()
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = MAIN_COLOR.CGColor
        
        selfHeight = 50

        headView.layer.cornerRadius = headView.bounds.width/2
        
        replayBtn.enabled = false
        overView = UIView()
        overView.backgroundColor = UIColor.blackColor()
        overView.alpha = 0.3
        //对键盘的状态(弹出、收回)进行监控，当键盘状态发生改变时，在相应的方法中对输入框的位置进行操作
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
    
    //回复
    @IBAction func replay(sender: UIButton) {
        
    }
    
}


//MARK: - 键盘跟随相关
extension ZuberBoardPopUp{
    
    func keyBoardWillShow(note:NSNotification)
    {
        isSHow = true
        CATransaction.begin()
        CATransaction.setDisableActions(true) // 关闭动画
        self.superview!.insertSubview(overView, belowSubview: self)
        overView.frame = self.superview!.bounds
        textView.clearsOnInsertion = true
        CATransaction.commit()
        
        //将通知的用户信息取出,转化为字典类型，里面所存的就是我们所需的信息:键盘动画的时长、时间曲线;键盘的位置、高度信息。
        let userInfo  = note.userInfo
        let keyBoardBounds = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        //转换成当前view的位置
        //        let keyBoardBoundsRect = self.convertRect(keyBoardBounds, toView:nil)
        //        let keyBaoardViewFrame = self.frame
        let deltaY = keyBoardBounds.size.height
        selfHeight = selfHeight+20
        self.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(selfHeight)
        }
        replayHeight.constant = 20
        let animations:(() -> Void) = {
            self.transform = CGAffineTransformMakeTranslation(0,-deltaY)
            self.layoutIfNeeded()
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    func keyBoardWillHide(note:NSNotification)
    {
        isSHow = false
        overView.removeFromSuperview()
        let userInfo  = note.userInfo
        let duration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        replayHeight.constant = 0
        selfHeight = selfHeight-20
        self.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(selfHeight)
        }
        let animations:(() -> Void) = {
            self.transform = CGAffineTransformIdentity
            
            self.layoutIfNeeded()
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

//MARK: - 手动模仿实现 placehoder
extension ZuberBoardPopUp:UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "说点什么?"{
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == ""{
            textView.text = "说点什么?"
            textView.textColor = UIColor.grayColor()
        }
        textView.resignFirstResponder()
    }
    
    
    func textViewDidChange(textView: UITextView) {
        textView.frame.size.height = textView.contentSize.height
        if textView.text == "" {
            replayBtn.enabled = false
        }else{
            replayBtn.enabled = true
        }
        
        if isSHow {
            selfHeight = textView.contentSize.height+40
            self.snp_updateConstraints { (make) -> Void in
                make.height.equalTo(textView.contentSize.height+40)
            }
        }else{
            selfHeight = textView.contentSize.height+20
            self.snp_updateConstraints { (make) -> Void in
                make.height.equalTo(textView.contentSize.height+20)
            }
        }
        self.setNeedsLayout()
    }
    
}