# ZuberBoardPopUp

最近项目需要用到回复框，点击随着键盘推上去那种。就研究了下。基本实现了需求，本着回报社会的态度将代码分享出来。

先看效果

![回复框](http://upload-images.jianshu.io/upload_images/954071-919500387ecad2e9.gif?imageMogr2/auto-orient/strip)

####整体组成部分
- 一个UIImage（当前用户头像） 
- UILabel （回复对象）
- 一个UITextView (回复内容) 
- UIButton（回复按钮） 
- UIView （容器）

####实现的功能
- UITextView的placehoder (系统没提供。。)
- 整体View的键盘跟随  
- 随UITextView 内容增减 整体view和UITextView 高度增减 
-  在底部的时候不显示回复对象弹出来的时候显示回复对象 
- 有文字的时候 发送按钮可用 ，无文字的时候发送按钮不可用
- 弹出的时候覆盖一层半透明蒙版，使得背景view不能交互
- 点击背景键盘落下

###实现部分 

##### 界面部分 
界面部分采用AutoLayout 在xib文件中画出来的。整个功能都是基于AutoLayout的。 

![界面](http://upload-images.jianshu.io/upload_images/954071-327583b7f06a17b2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

大家看这个图估计看不出来我的回复 label在哪里，其实这里有个小技巧，就是回复label初始是不显示的，所以 height 设置为0 ，弹起的时候height设置为20 。这样来回切换就可以了，实现方法就不赘述了，看我源码就行了。

#####代码部分
代码部分的约束我用的SnapKit框架 ，系统的代码约束确实繁琐。

说下几个功能点，
######UITextView的placehoder 
实现UITextViewDelegate 的两个方法
```
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
```
最简单的实现方式吧， 这种有时候会有问题，用户自己输入“说点什么?” 键盘落下 再点击弹起的时候清空，这种清空可以忽略 😄

######整体View的键盘跟随 

主要是监听两个通知
```
NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
```
对键盘的状态(弹出、收回)进行监控，当键盘状态发生改变时，在相应的方法中对输入框的位置进行操作

```
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
        let userInfo  = note.userInfo
        let keyBoardBounds = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
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
        let userInfo  = note.userInfo
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
```

就是这两个方法，note.userInfo里面包含很多相关数据 ，代码里面有很多和键盘弹起无关的是做其他功能的，比如
```
CATransaction.begin() 
CATransaction.setDisableActions(true) // 关闭动画 
self.superview!.insertSubview(overView, belowSubview: self) 
overView.frame = self.superview!.bounds 
textView.clearsOnInsertion = true CATransaction.commit()
```
是现实透明蒙版的时候 从别的页面进来 第一次有个很难看的动画，肯定是系统隐式动画搞得鬼，就加了这段代码，把系统的动画禁止了

关于键盘跟随的功能可以去看看这个帖子，将的很详细。 我是参照他得
http://www.jianshu.com/p/4e755fe09df7 

其他功能大家看代码，如果不理解的可以回复我提问 ， 不想看只想用的。直接那去用就行了 ，这里使用也不麻烦，加到要用的view中 设置下约束,加个手势就行了

```
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
```





