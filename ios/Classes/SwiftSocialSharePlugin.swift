import Flutter
import FBSDKCoreKit
import FBSDKShareKit
import UIKit
import Foundation
import SystemConfiguration

public class SwiftSocialSharePlugin: NSObject, FlutterPlugin {
    
    var controller: UIViewController!
    var messenger: FlutterBinaryMessenger
    
    init(cont: UIViewController, messenger: FlutterBinaryMessenger) {
        self.controller = cont
        self.messenger = messenger
        super.init();
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "social_share", binaryMessenger: registrar.messenger())
        let app =  UIApplication.shared
        let rootController = app.delegate!.window!!.rootViewController
        var flutterController: FlutterViewController? = nil
        if rootController is FlutterViewController {
            flutterController = rootController as! FlutterViewController
        } else if app.delegate is FlutterAppDelegate {
            if (app.delegate?.responds(to: Selector("flutterEngine")))! {
                let engine: FlutterEngine? = app.delegate?.perform(Selector("flutterEngine"))?.takeRetainedValue() as! FlutterEngine
                flutterController = engine?.viewController
            }
        }
        let controller : UIViewController = flutterController ?? rootController!;
        let instance = SwiftSocialSharePlugin.init(cont: controller, messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(!isConnectedToNetwork()){
            result("You are not connected to the Internet")
        } else {
            if(call.method == "shareWhatsApp"){
                var message : String = ""
                var phoneNumber : String = ""
                DispatchQueue.background(background: {
                    let urlString = call.arguments as? String ?? ""
                    let data = urlString.data(using: .utf8)!
                    do {
                        let postShare = try JSONDecoder().decode(PostShare.self, from: data)
                        message = postShare.message
                        phoneNumber = postShare.phoneNumber ?? ""
                        print(message)
                    } catch let _ {
                        message = ""
                        phoneNumber = ""
                    }
                }, completion:{
                    if(message != "" || phoneNumber !=  ""){
                        let urlScheme = URL(string: "whatsapp://send?text=" + message + "&phone=" + phoneNumber)
                        if let urlScheme = urlScheme {
                            if UIApplication.shared.canOpenURL(urlScheme) {
                                UIApplication.shared.openURL(urlScheme)
                                result("Success")
                            } else {
                                result("App not installed")
                            }
                        } else {
                            result("Something went wrong, Please try again")
                        }
                    } else {
                        let urlScheme = URL(string: "whatsapp://send?text=" + message)
                        if let urlScheme = urlScheme {
                            if UIApplication.shared.canOpenURL(urlScheme) {
                                UIApplication.shared.openURL(urlScheme)
                                result("Success")
                            } else {
                                result("App not installed")
                            }
                        } else {
                            result("Something went wrong, Please try again")
                        }
                    }
                })
            } else if(call.method == "shareTwitter"){
                var message : String = ""
                DispatchQueue.background(background: {
                    let urlString = call.arguments as? String ?? ""
                    let data = urlString.data(using: .utf8)!
                    do {
                        let postShare = try JSONDecoder().decode(PostShare.self, from: data)
                        message = postShare.message
                        print(message)
                    } catch let _ {
                        message = ""
                    }
                }, completion:{
                    let urlScheme = URL(string: "twitter://post?message=" + message)
                    if let urlScheme = urlScheme {
                        if UIApplication.shared.canOpenURL(urlScheme) {
                            UIApplication.shared.openURL(urlScheme)
                            result("Success")
                        } else {
                            result("App not installed")
                        }
                    } else {
                        result("Something went wrong, Please try again")
                    }
                })
            } else if(call.method == "shareFacebook"){
                var message : String = ""
                DispatchQueue.background(background: {
                    let urlString = call.arguments as? String ?? ""
                    let data = urlString.data(using: .utf8)!
                    do {
                        let postShare = try JSONDecoder().decode(PostShare.self, from: data)
                        message = postShare.message
                        print(message)
                    } catch let _ {
                        message = ""
                    }
                }, completion:{
                    let urlScheme = URL(string: "fbauth2://")
                    if let urlScheme = urlScheme {
                        if UIApplication.shared.canOpenURL(urlScheme) {
                            UIApplication.shared.openURL(urlScheme)
                            let content:ShareLinkContent! = ShareLinkContent()
                            content.contentURL = URL(string : message)!
                            ShareDialog.init(fromViewController: self.controller, content:content, delegate:nil).show()
                        } else {
                            result("App not installed")
                        }
                    } else {
                        result("Something went wrong, Please try again")
                    }
                })
            }
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
