//: Playground - noun: a place where people can play

import UIKit


//: SwiftCafe 提供教程 [http://swiftcafe.io](http://swiftcafe.io)
//:
//: 微信公众号 swiftcafex
//:
//: ![](http://swiftcafe.io/images/qrcode.jpg)
//:
//: GitHub 地址 [https://github.com/swiftcafex/NSURLSessionSamples](https://github.com/swiftcafex/NSURLSessionSamples)


//: 简单 HTTP 请求
if let url = NSURL(string: "https://httpbin.org/get") {

    NSURLSession.sharedSession().dataTaskWithURL(url){ data, response, error in
    
        //... 
        
    }.resume()
    
}


//: 下载文件
let imageURL = NSURL(string: "https://httpbin.org/image/png")!


NSURLSession.sharedSession().downloadTaskWithURL(imageURL) { location, response, error in
    
    guard let url = location else { return }
    guard let imageData = NSData(contentsOfURL: url) else { return }
    guard let image = UIImage(data: imageData) else { return }

    dispatch_async(dispatch_get_main_queue()) {

        //...
        
    }

    
}.resume()


//: 上传文件
let uploadURL = NSURL(string: "https://httpbin.org/image/png")!
let request = NSURLRequest(URL: uploadURL)

let fileURL = NSURL(fileURLWithPath: "pathToUpload")
NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: fileURL) { data, response, error in

}.resume()



//: 使用 backgroundSessionConfiguration 进行下载操作

var session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("download"))
session.downloadTaskWithURL(imageURL).resume()



//: 使用 NSURLSessionDownloadDelegate 处理下载事件
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