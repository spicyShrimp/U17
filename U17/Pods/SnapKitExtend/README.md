# SnapKitExtend
SnapKit的扩展,SnapKit类似于Masonry,但是其没有对Arry的设置和对等间距排列的布局等,此扩展是类似Masonry的写法对SnapKit的补充,同时补充九宫格布局方式

```
pod 'SnapKitExtend', '~> 1.0.7'
```


![数组布局](https://github.com/spicyShrimp/SnapKitExtension/blob/master/images/1.png)
```
let arr = [view1, view2, view3, view4]
        
arr.snp.makeConstraints{
    $0.width.height.equalTo(100)
    $0.center.equalTo(CGPoint(x: CGFloat(arc4random_uniform(300)) + 50,
                              y: CGFloat(arc4random_uniform(300)) + 50))
}
```
![数组布局2](https://github.com/spicyShrimp/SnapKitExtension/blob/master/images/2.png)
```
let arr = [view1, view2, view3, view4]
         
arr.snp.makeConstraints{
    $0.width.height.equalTo(100)
}

view1.snp.makeConstraints{ $0.top.equalTo(0) }
view2.snp.makeConstraints{ $0.top.equalTo(100) }
view3.snp.makeConstraints{ $0.top.equalTo(200) }
view4.snp.makeConstraints{ $0.top.equalTo(300) } 
```
![等间距布局](https://github.com/spicyShrimp/SnapKitExtension/blob/master/images/3.png)
```
let arr = [view1, view2, view3, view4]

//        axisType:方向
//        fixedSpacing:中间间距
//        leadSpacing:左边距(上边距)
//        tailSpacing:右边距(下边距)
arr.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 10, leadSpacing: 10, tailSpacing: 10)
//        上面的可以约束x+w,还需要另外约束y+h
//        约束y和height()如果方向是纵向,那么则另外需要设置x+w
arr.snp.makeConstraints{
    $0.top.equalTo(100)
    $0.height.equalTo(CGFloat(arc4random_uniform(100) + 50))
}
```
![等大小布局](https://github.com/spicyShrimp/SnapKitExtension/blob/master/images/4.png)
```
let arr = [view1, view2, view3, view4]
        
//        axisType:方向
//        fixedItemLength:item对应方向的宽或者高
//        leadSpacing:左边距(上边距)
//        tailSpacing:右边距(下边距)
arr.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 100, leadSpacing: 30, tailSpacing: 30)
//        上面的可以约束y+h,还需要另外约束x+w
//        约束y和height()如果方向是纵向,那么则另外需要设置y+h
arr.snp.makeConstraints{
    $0.width.left.equalTo(100)
}
```
![九宫格布局](https://github.com/spicyShrimp/SnapKitExtension/blob/master/images/5.png)
```
var arr: Array<ConstraintView> = [];
for _ in 0..<9 {
    let subview = UIView()
    subview.backgroundColor = UIColor.random
    view.addSubview(subview)
    arr.append(subview)
}

//        固定大小,可变中间间距,上下左右间距默认为0,可以设置
arr.snp.distributeSudokuViews(fixedItemWidth: 100, fixedItemHeight: 100, warpCount: 3)
```
![九宫格布局2](https://github.com/spicyShrimp/SnapKitExtension/blob/master/images/6.png)
```
var arr: Array<ConstraintView> = [];
for _ in 0..<9 {
    let subview = UIView()
    subview.backgroundColor = UIColor.random
    view.addSubview(subview)
    arr.append(subview)
}

//        固定间距,可变大小,上下左右间距默认为0,可以设置
arr.snp.distributeSudokuViews(fixedLineSpacing: 10, fixedInteritemSpacing: 10, warpCount: 3)
```
