import Flutter
import UIKit
import Foundation
import SystemConfiguration

public class SwiftSocialSharePlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "social-share", binaryMessenger: registrar.messenger())
        let instance = SwiftSocialSharePlugin()
        registrar.addApplicationDelegate(instance)
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
                        phoneNumber = postShare.phoneNumber
                    } catch let error {
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
                var phoneNumber : String = ""
                DispatchQueue.background(background: {
                    let urlString = call.arguments as? String ?? ""
                    let data = urlString.data(using: .utf8)!
                    do {
                        let postShare = try JSONDecoder().decode(PostShare.self, from: data)
                        message = postShare.message
                    } catch let error {
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
                              var phoneNumber : String = ""
                              DispatchQueue.background(background: {
                                  let urlString = call.arguments as? String ?? ""
                                  let data = urlString.data(using: .utf8)!
                                  do {
                                      let postShare = try JSONDecoder().decode(PostShare.self, from: data)
                                      message = postShare.message
                                  } catch let error {
                                      message = ""
                                  }
                              }, completion:{
                                 let content:FBSDKShareLinkContent! = FBSDKShareLinkContent()
                                     content.contentURL = URL(message)
                                     FBSDKShareDialog.showFromViewController(self,
                                                                   withContent:content,
                                                                      delegate:nil)
                                     result("Success")
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
