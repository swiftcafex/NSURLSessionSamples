!title: "NSURLSession 网络库 - 原生系统送给我们的礼物"
date: 2015-12-20 20:10:44
tags:
poster: /images/poster/nsurlsession.jpg
---


大家在进行iOS开发的时候一定会用到网络操作。但由于早期原生的 NSURLConnection 操作起来有很多不便，使得大家更愿意使用第三方库的解决方案，比如鼎鼎大名的 AFNetworking。正是因为这点，苹果团队为开发者提供了改进后的原生网络库支持，也就是 NSURLSession。

<!-- more -->


## NSURLSession 简介

NSURLSession 是苹果为我们提供的一套新的网络处理库。它的前身是 NSURLConnection，但由于 NSURLConnection 提供的接口使用起来不够简洁，让很多开发者不愿意使用。按照苹果官方的文档上说的 NSURLSession 的出现就是为了代替 NSURLConnection。NSURLSession 提供了一套更优秀的网络处理解决方案，并且使用的接口更加简单，对开发者更加友好。

那么，使用 NSURLSession 和第三方库相比有什么好处呢，这些优秀的第三方库也提供了相应的网络处理能力。

更新后的 NSURLSession 提供了更加简洁的接口，所以我们不用担心之前 NSURLConnection 使用复杂的问题，从基本的网络请求需求来看，已经和诸如 AFNetworking 这些第三方库没有太多差别了。并且，使用 NSURLSession 的一个最大的好处就是它系统原生提供的，所以我们不需要做任何的额外导入的操作，就可以直接使用。

如果你不需要使用 AFNetworking 这些第三方库所提供的加强功能，比如和 UIKit 的深度集成等，那么使用 NSURLSession 是一个最简单快捷的选择。

使用 NSURLSession 进行基本的网络请求也非常的容易：

```
if let url = NSURL(string: "https://httpbin.org/get") {

    NSURLSession.sharedSession().dataTaskWithURL(url){ data, response, error in
    
        //... 
        
    }.resume()
    
}
```

这里使用 NSURLSession.sharedSession() 来获取 NSURLSession 的实例，然后调用 dataTaskWithURL 方法传入我们要访问的 url，最后在闭包中处理请求的返回结果。

注意，resume() 方法的调用，NSURLSession 默认是不启动的，我们必须手工调用 resume() 方法，才会开始请求。

以上代码是 NSURLSession 进行网络请求最简单的调用形式。


## NSURLSession 详细接口

我们刚刚看到了 NSURLSession 的最简调用形式，当然它还支持很多网络请求特性的处理，我们来进一步了解。

NSURLSession 本身是不会进行请求的，而是通过创建 task 的形式进行网络请求，同一个 NSURLSession 可以创建多个 task，并且这些 task 之间的 cache 和 cookie 是共享的。那么我们就来看看 NSURLSession 都能创建哪些 task 吧。

- NSURLSessionDataTask: 这个就是我们第一个例子中创建的 DataTask,它主要用于读取服务端的简单数据，比如 JSON 数据。
- NSURLSessionDownloadTask: 这个 task 的主要用途是进行文件下载，它针对大文件的网络请求做了更多的处理，比如下载进度，断点续传等等。
- NSURLSessionUploadTask: 和下载任务对应，这个 task 主要是用于对服务端发送文件类型的数据使用的。

好了，所有的 task 类型都在这里了。我们可以看几个例子，比如如何下载文件：

```
let imageURL = NSURL(string: "https://httpbin.org/image/png")!


NSURLSession.sharedSession().downloadTaskWithURL(imageURL) { location, response, error in
    
    guard let url = location else { return }
    guard let imageData = NSData(contentsOfURL: url) else { return }
    guard let image = UIImage(data: imageData) else { return }

    dispatch_async(dispatch_get_main_queue()) {

        //...
        
    }

    
}.resume()

```

下载文件的时候，我们使用 downloadTaskWithURL 方法，这个方法的闭包中会接受一个 location 参数，这个参数表示我们下载好的文件的存放位置。

> 注意，downloadTaskWithURL 会将文件保存在一个临时目录中，location 参数指向这个临时目录的位置，如果我们要将下载好的文件进行持久保存的话，我们还需要将文件从这个临时目录中移动出来。


我们通过 location 参数可以找到文件的位置，然后将文件的内容读取出来，就像我们上面的例子中那样。


我们再来看一下上传操作:

```
let uploadURL = NSURL(string: "https://httpbin.org/image/png")!
let request = NSURLRequest(URL: uploadURL)

let fileURL = NSURL(fileURLWithPath: "pathToUpload")
NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: fileURL) { data, response, error in

}.resume()
```

上传操作使用 uploadTaskWithRequest 方法。

这样，NSURLSession 的三种 task 我们就都了解了，它们的关系大致如下：

![](http://swiftcafe.io/articleimg/nsurlsession/nsurlsession-1.png)

## NSURLSessionConfiguration

刚刚我们一起了解了 NSURLSession 可以创建的三种 task 类型，那么我们在回过头来看看 NSURLSession 本身。我们前面的所有例子中，都是用 NSURLSession.sharedSession() 这样的方式得到的 NSURLSession 的实例，这个实例是全局共享的，并且功能受限。比如，由于全局实例没有代理对象，我们就不能够检测诸如下载进度这类的事件。以及我们无法设置后台下载的机制，等等。

当然 NSURLSession 的空间还是很大的，我们不仅能通过 NSURLSession.sharedSession() 这种方式得到实例，还可以创建我们自己的 NSURLSession 实例。 NSURLSession 定义了两个构造方法：

```
init(configuration:)
init(configuration:delegate:delegateQueue:)
```

这两个方法都会接受一个 NSURLSessionConfiguration 对象，这个对象定义了这个 NSURLSession 实例的各种配置信息。并且， NSURLSessionConfiguration 提供了三个默认的初始化方法：

- **defaultSessionConfiguration** - 这个配置会使用全局的缓存，cookie 等信息，这个相当于 NSURLSessionConfiguration 的默认配置行为。
- **ephemeralSessionConfiguration** - 这个配置不会对缓存或 cookie 以及认证信息进行存储，相当于一个私有的 Session，如果你开发一个浏览器产品，这个配置就相当于浏览器的隐私模式。
- **backgroundSessionConfiguration** - 这个配置可以让你的网络操作在你的应用切换到后台的时候还能继续工作。

现在我们了解了这几个配置模式，就可以根据我们需要的网络操作类型确认相应的配置模式，如果是进行一般的数据读取，那么就可以使用 defaultSessionConfiguration，如果要进行隐私模式浏览等操作，就可以使用 ephemeralSessionConfiguration。最后，如果你需要开发一个下载功能，为了保证下载线程最大的执行空间，那么就可以使用 backgroundSessionConfiguration。

现在我们来使用 backgroundSessionConfiguration 进行下载操作：

``` swift
let imageURL = NSURL(string: "https://httpbin.org/image/png")!
var session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("download"))
session.downloadTaskWithURL(imageURL).resume()
```

我们创建 backgroundSessionConfiguration 的时候，还传入了一个字符串 "download"，这个用作当前下载任务的标识，用于保证下载任务在后台的运行。

除了这三种预设的模式之外 NSURLSessionConfiguration 还可以进行很多的配置。 timeoutIntervalForRequest 和 timeoutIntervalForResource 可以控制网络操作的超时时间。 allowsCellularAccess 属性可以控制是否允许使用无线网络。HTTPAdditionalHeaders 可以指定 HTTP 请求头。

NSURLSessionConfiguration 几乎可以完成网络操作的大多数配置功能，并且这些配置都绑定到当前的 Session 中，我们一旦用配置好的 NSURLSessionConfiguration 初始化 NSURLSession 实例后，就不能修改这个 NSURLSession 相关的配置了。所以，一切的配置操作都放在初始化 NSURLSession 之前。

## 使用代理

我们前面的例子都是通过一个闭包在网络操作完成的时候进行处理。那么有什么方法可以监听网络操作过程中发生的事件呢，比如我们下载一个大文件的时候，如果要等到下载完成可能会需要比较长的事件，这时候更好的体验是能够提供一个下载进度。类似这样的事件我们就需要用到代理。

我们在使用三种 task 的任意一种的时候都可以指定相应的代理。NSURLSession 的代理对象结构如下：

![](http://swiftcafe.io/articleimg/nsurlsession/nsurlsession-2.png)


- NSURLSessionDelegate - 作为所有代理的基类，定义了网络请求最基础的代理方法。

- NSURLSessionTaskDelegate - 定义了网络请求任务相关的代理方法。

- NSURLSessionDownloadDelegate - 用于下载任务相关的代理方法，比如下载进度等等。

- NSURLSessionDataDelegate - 用于普通数据任务和上传任务。


我们可以用代理来检测下载进度：

```
class Downloader:NSObject, NSURLSessionDownloadDelegate {
    
    var session: NSURLSession?
    
    override init() {
        
        super.init()
        
        let imageURL = NSURL(string: "https://httpbin.org/image/png")!
        session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("taask"), delegate: self, delegateQueue: nil)
        session?.downloadTaskWithURL(imageURL).resume()
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("下载完成")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("正在下载 \(totalBytesWritten)/\(totalBytesExpectedToWrite)")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
        print("从 \(fileOffset) 处恢复下载，一共 \(expectedTotalBytes)")
        
    }
    
    
}
```

我们的 Downloader 类实现了 NSURLSessionDownloadDelegate 协议，并实现了这个协议的三个方法，分别用于接收下载完成的通知，下载进度变化的通知，以及下载进度恢复的通知。

> 注意，Downloader 同时也继承自 NSObject，这个是必须的，否则我们在实现 NSURLSessionDownloadDelegate 协议的方法时会报错。这个只有在 Swift 中需要显示的继承，在 Objective-C 中则不需要，因为 Objective-C 中的任何类都是继承自 NSObject 的。


## 结语

NSURLSession 提供了网络请求相关的大部分方法，已经可以满足我们日常的需求，并且提供了很简单的调用接口。它是系统提供的库，所以我们不需要进行任何的库引用，就可以使用 NSURLSession 了。

NSURLSession 除了我们介绍的支持 task 特性，NSURLSessionConfiguration 配置对象，以及代理之外还提供了很多关于网络请求的相关特性，比如缓存控制，Cookie 控制，HTTP 验证操作等等。总之 NSURLSession 简单的接口之外，也提供了强大的体系。

NSURLSession 相比 Alamofire 这些第三方库来说也有一些不足，比如它没有提供很方便的自动数据类型转换。比如，Alamofire 中可以自动将服务端返回的 JSON 数据识别并解析出来，而使用 NSURLSession 则需要自己来完成。

至于使用 NSURLSession 还是 Alamofire 就要看各位自己的权衡了，如果没有特别依赖于第三方库提供的附加功能，我个人更加倾向于使用 NSURLSession。毕竟它不需要导入任何外部资源。

关于 NSURLSession 的基本讨论我们就完成了，大家还可以参考这些相关内容：

- [Alamofire - 优雅的处理 Swift 中的网络操作](http://swiftcafe.io/2015/12/14/alamofire)
- [NSURLSession Tutorial](http://www.raywenderlich.com/51127/nsurlsession-tutorial)
- [Using NSURLSession](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html)


您还可以在 Github 上面下载文章中的示例代码： [https://github.com/swiftcafex/NSURLSessionSamples](https://github.com/swiftcafex/NSURLSessionSamples)







 

