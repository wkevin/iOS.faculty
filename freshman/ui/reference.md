
# iOS UIKit class hierarchy
![](https://developer.apple.com/library/ios/documentation/uikit/reference/uikit_framework/Art/uikit_classes.jpg)

# ext.UIActionSheet

## AHKActionSheet

<table><tr><td width=50%>
<img src ="https://raw.githubusercontent.com/fastred/AHKActionSheet/master/example.gif"/>
</td><td  width=50%>
<a   href="http://wkevin.qiniudn.com/Blog_ActionSheet-Reveal.png" title="点击放大">
<img src ="http://wkevin.qiniudn.com/Blog_ActionSheet-Reveal.png" alt="ActionSheet Reveal 显示图" align="middle"/></a>
</td></tr></table>


### Feature

*	AHKActionSheet 并没有继承自 UIActionSheet ，而是继承 UIView，完全重写。
*	AHKActionSheet 没有 delegate
	*	UIActionSheet 的 delegate 实现点击item前后的操作
	*	AHKActionSheet 的点击某个 item（button） 的操作通过 block 实现，与delegate相比，简化了很多，actionsheet出现前、隐藏后、点击前的步骤都省去了，只留了一个点击后的。
*	Button（item）：
	*	UIActionSheet 默认两个button：
		*	蓝色的 cancelButton
		*	红色的 destructiveButton
		*	其他的 button 自己实现并添加
	*	AHKActionButton 默认1个Cacelbutton，其他自己添加，使用 `- (void)addButtonWithTitle:(NSString *)title ......` 参见下面的API
*	AHKActionSheet 可以设置的属性也有很多：底色、透明度、button的高度、隔离线的粗细等

### API

AHKActionSheet Class：

```
- (void)addButtonWithTitle:(NSString *)title 
                     image:(UIImage *)image  //添加button的同时设置小图标
                      type:(AHKActionSheetButtonType)type //default-白色，destructive-红色
                   handler:(AHKActionSheetHandler)handler //点击后的动作
- (void)show
```

### Code

**AHKActionSheet.h/.m**

*	AHKActionSheetItem：继承自 NSObject
	*	纯粹可以看做是个数据结构，用于 AHKActionSheet 的 items 数组，进而构造 TableViewCell 时
*	AHKActionSheet：继承自 UIView
	*	`initialize`：
		*	重载 NSObject 的方法，runtime 在 AHKActionSheet 的对象收到第一个消息之前发送此消息，所有 AHKActionSheet 只接收一次。
		*	作者使用 appearance 方法来获取 appearance proxy，从而修改被标记为 UI_APPEARANCE_SELECTOR 的属性 —— 达到的效果就是：设置默认值
	*	`addButtonWithTitle:image:type:handler:` 和 `addButtonWithTitle:image:type:handler:`
		*	方法命名为 addButton，但其实不是button，而是创造一个 AHKActionSheetItem，放入 items 数组
	*	`show`：关键在这里，流程如下：
		*	取当前app的window，制作快照(使用 UIImage 的扩展 `ahk_snapshot`)
		*	新建UIWindow：`setUpNewWindow`
			*	新建 UIWindow
			*	新建 AHKActionSheetViewController，作为新建windows的rootView
			*	显示新建的window（`[self.window makeKeyAndVisible];`）
		*	创建模糊背景：`setUpBlurredBackgroundWithSnapshot:`
			*	作者对 UIImage 扩展了“高斯模糊”的方法： `ahk_applyBlurWithRadius:tintColor:saturationDeltaFactor:maskImage:` —— 将前面制作的背景快照，进行模糊加工
			*	用模糊后的image，创建UIView，并 addSubview
			*	alpha 设为 0（完全透明）
		*	创建CancelButton：是个常规的UIButton，然后`[self addSubview:cancelButton];`
		*	创建TableView：datasource和delegate都是self，datasource的方法中根据items的内容
		*	`[UIView animateKeyframesWithDuration：......` 动画显示
			*	模糊背景的 alpha 设置为1（不透明）
			*	0.3s后显示cancelButton和TableView
	*	`dismissAnimated:duration:completion:`：任何item的点击都会调用此动画，使得ActionSheet 消失，并执行用户 addButton 时的 block

**UIImage+AHKAdditions.h/m**

*	提供对图片进行“高斯模糊”操作的功能 

```
- (UIImage *)ahk_applyBlurWithRadius:(CGFloat)blurRadius 
                           tintColor:(UIColor *)tintColor 
               saturationDeltaFactor:(CGFloat)saturationDeltaFactor 
                           maskImage:(UIImage *)maskImage
```

了解“高斯模糊”  
1.	[www.w3.org：高斯滤镜](http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement)  
2.	[维基：高斯模糊](http://zh.wikipedia.org/wiki/高斯模糊)  
3.	[百度：高斯模糊](http://baike.baidu.com/view/642651.htm)  

**UIWindow+AHKAdditions.h/m**

实现抓取 window 当前快照的功能：  
`- (UIImage *)ahk_snapshot`

## DJWActionSheet

<table><tr><td width=50%>
<img src ="http://wkevin.qiniudn.com/Blog_DJWActionSheet.png-w320"/>
</td><td  width=50%>
<img src ="http://wkevin.qiniudn.com/Blog_DJWActionSheet-reveal.png-w320"/></a>
</td></tr></table>

### Feature
*	DJWActionSheet 也没有继承 UIActionSheet，而是直接继承 UIView。
*	也是没有使用 delegate ，而是使用 Block，但是整个actionSheet一个Block，而不是像AHKActionSheet
*	相比 AHKActionSheet，DJWActionSheet没有对背景做高斯模糊操作

### API
```objective-c
+ (void)showInView:(UIView *)view
         withTitle:(NSString *)title
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSArray *)otherButtonTitles
          tapBlock:(DJWActionSheetTapBlock)tapBlock;
```

### Code

**DJWActionSheet.h/m**

*	使用 UIView 的 `- (UIView *)snapshotViewAfterScreenUpdates:(BOOL)afterUpdates` 方法截取快照view，然后把这个view addSubview 到当前view
*	给这个快照view增加手势：无论什么手势，都是走到 `cancelButtonTapped:` 上去
*	计算 actionSheet 的位置和高度等，addSubview 进来
*	增加button，没有使用tableView，比AHKActionSheet 轻量级了一点
*	动画部分
	*	快照view 做 x、y 轴的缩小
	```objc
    [UIView animateWithDuration:0.3 animations:^{
        self.containerSnapShotView.alpha = (scale < 1) ? 0.6 : 1.0;
        self.containerSnapShotView.layer.transform = CATransform3DMakeScale(scale, scale, 1);
    }];
    ```
    *	actionSheet 的view放在视野外
    *	把 actionSheet view 抬上来
    ```objc
    [UIView animateWithDuration:DJWActionSheetPresentationAnimationSpeed delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.actionSheetBackgroundView.frame = actionSheetBackgroundViewEndFrame;
    } completion:^(BOOL finished) {
    }];
    ```