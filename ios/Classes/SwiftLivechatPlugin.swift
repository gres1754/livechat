import Flutter
import UIKit
import LiveChat

public class SwiftLivechatPlugin: NSObject, FlutterPlugin {
  private var isInitialized = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "livechatt", binaryMessenger: registrar.messenger())
    let instance = SwiftLivechatPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let factory = EmbeddedChatViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "embedded_chat_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "beginChat":
            handleBeginChat(call: call, result: result)

        case "initializeChat":
            handleInitializeChat(call: call, result: result)

        case "showPreloadedChat":
            handleShowPreloadedChat(result: result)

        case "hideChat":
            handleHideChat(result: result)

        case "isInitialized":
            result(isInitialized)

        case "clearSession":
            LiveChat.clearSession()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
    }
  }

  private func handleBeginChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as! [String:Any]

    let licenseNo = arguments["licenseNo"] as? String
    let groupId = arguments["groupId"] as? String
    let visitorName = arguments["visitorName"] as? String
    let visitorEmail = arguments["visitorEmail"] as? String
    let customParams = arguments["customParams"] as? [String:String] ?? [:]

    guard let licenseNo = licenseNo, !licenseNo.isEmpty else {
      result(FlutterError(code: "LICENSE_ERROR", message: "License number cannot be empty", details: nil))
      return
    }

    configureLiveChat(licenseNo: licenseNo, groupId: groupId, visitorName: visitorName, visitorEmail: visitorEmail, customParams: customParams)
    LiveChat.presentChat()
    result(nil)
  }

  private func handleInitializeChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as! [String:Any]

    let licenseNo = arguments["licenseNo"] as? String
    let groupId = arguments["groupId"] as? String
    let visitorName = arguments["visitorName"] as? String
    let visitorEmail = arguments["visitorEmail"] as? String
    let customParams = arguments["customParams"] as? [String:String] ?? [:]

    guard let licenseNo = licenseNo, !licenseNo.isEmpty else {
      result(FlutterError(code: "LICENSE_ERROR", message: "License number cannot be empty", details: nil))
      return
    }

    configureLiveChat(licenseNo: licenseNo, groupId: groupId, visitorName: visitorName, visitorEmail: visitorEmail, customParams: customParams)
    isInitialized = true
    result(nil)
  }

  private func handleShowPreloadedChat(result: @escaping FlutterResult) {
    if isInitialized {
      LiveChat.presentChat()
      result(nil)
    } else {
      result(FlutterError(code: "NOT_INITIALIZED", message: "Chat is not initialized. Call initializeChat first.", details: nil))
    }
  }

  private func handleHideChat(result: @escaping FlutterResult) {
    LiveChat.dismissChat()
    result(nil)
  }

  private func configureLiveChat(licenseNo: String, groupId: String?, visitorName: String?, visitorEmail: String?, customParams: [String:String]) {
    LiveChat.licenseId = licenseNo

    if let groupId = groupId {
      LiveChat.groupId = groupId
    }

    if let visitorName = visitorName {
      LiveChat.name = visitorName
    }

    if let visitorEmail = visitorEmail {
      LiveChat.email = visitorEmail
    }

    for (key, value) in customParams {
      LiveChat.setVariable(withKey: key, value: value)
    }
  }
}
