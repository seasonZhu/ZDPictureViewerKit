# ZDPictureViewerKit

#### 项目介绍
这个是一款Swift编写的图片展示组件  

主要是用于网络图片的显示与浏览,当然加载本地图片也是可以

其实这个组件应该放入到ZDPhotoKit中,不过比较遗憾的是由于是加载网络图片为主,所以我不得不使用了Kingfisher,以至于造成了第三方库的依赖

按照功能上来说,其实我使用ZDLaunchKit中的图片下载也可以满足其要求,就是性能不是很好



#### 目前已知的一些Bug
1. Gif预览使用了Kingfisher中的AnimatedImageView,但是从大图预览回到列表展示的时候,Gif图不动
2. 图片缩放的动画细节还有问题
3. 后续会放入cocoapods中,也算是对其的一种练习



  

