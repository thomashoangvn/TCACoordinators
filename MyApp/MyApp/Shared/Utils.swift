//
//  Utils.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

final class Utils: NSObject {
    
    // MARK: UIDevice current phone
    class var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // MARK: UIDevice current pad
    class var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    class var availableiOS18: Bool {
        return versioniOS >= 18
    }
    class var availableiOS17: Bool {
        return versioniOS >= 17
    }
    class var availableiOS16: Bool {
        return versioniOS >= 16
    }
    class var versioniOS: Int {
        if #available(iOS 18.0, *) {
            return 18
        } else if #available(iOS 17.0, *) {
            return 17
        } else if #available(iOS 16.0, *) {
            return 16
        } else {
            return 15
        }
    }
    // MARK: simulator
    class var isSimulator: Bool {
#if targetEnvironment(simulator)
        print("Running on a Simulator")
        return true
#else
        print("Running on a physical device")
        return false
#endif
    }
    class var isPhysicalDevice: Bool {
        return !isSimulator
    }
    
    // MARK: Screen size
    class var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    class var windowSize: CGSize {
        let size = window?.frame.size ?? screenSize
        let isLandscape = UIDevice.current.orientation.isLandscape
        let landscapeSize = CGSize(width: max(size.width, size.height), height: min(size.width, size.height))
        let isPortrait = UIDevice.current.orientation.isPortrait
        let portraitSize = CGSize(width: min(size.width, size.height), height: max(size.width, size.height))
        var windowSize = size
        
        if isPortrait {
            windowSize = portraitSize
        }
        if isLandscape {
            windowSize = landscapeSize
        }
        
        print("orientation: ", UIDevice.current.orientation.rawValue, "size: ", size , "windowSize: ", windowSize )
        return  windowSize
    }
    
    // MARK: window
    class var window: UIWindow? {
        var currentWindow: UIWindow?
        /*if let keyWindow = UIApplication.shared.keyWindow {
         currentWindow =  keyWindow
         }*/
        if let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
            currentWindow =  keyWindow
        }
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow })  {
            currentWindow =  window
        }
        return currentWindow
    }
    
    // MARK: window safeAreaInsets
    class var safeAreaInsets: UIEdgeInsets {
        return window?.safeAreaInsets ?? .zero
    }
    
    // MARK: window safeAreaFrame
    class var safeAreaFrame: CGRect {
        return window?.safeAreaLayoutGuide.layoutFrame ?? .zero
    }
    
    // MARK: Open Setting App
    class func openSettingApp() {
        if let url = URL(string: UIApplication.openSettingsURLString) as URL? {
            UIApplication.shared.open(url, options: [:]) { (status) in
            }
        }
    }
    
    // MARK: Open Url Out App
    class func openUrlCloseApp(_ urlString: String ) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:]) { (success) in
            exit(0)
        }
    }
    
    class func openUrlBrower(_ urlString: String ) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: App version
    class func getAppVersion() -> String? {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return nil
        }
        return currentVersion
    }
    
    // MARK: App Build
    class func getAppBuild() -> String? {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
            return nil
        }
        return currentVersion
    }
    
    // MARK: Device details
    internal class func getDeviceDetails() -> (uuid: String, name: String, model: String, localizedModel: String, systemName: String, systemVersion: String) {
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""//“E621E1F8-C36C-495A-93FC-0C247A3E6E5F”
        let name = UIDevice.current.name // e.g. "My iPhone"
        let model = UIDevice.current.model // e.g. @"iPhone", @"iPod touch"
        let localizedModel = UIDevice.current.localizedModel // localized version of model
        let systemName = UIDevice.current.systemName // e.g. @"iOS"
        let systemVersion = UIDevice.current.systemVersion // e.g. @"4.0"
        return (uuid, name, model, localizedModel, systemName, systemVersion)
    }
    /**
     Method returns an instance of a view defined by the nib name String parameter
     - Parameter nibName: String
     - Returns: UIView?
     */
    internal class func viewFrom(nibName: String) -> UIView? {
        if let objects = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil), objects.count > 0 {
            return objects[0] as? UIView
        }
        return nil
    }
    
    internal class func confirmVersion(version: String, currentVersion: String) -> Bool {
        if let versionArr = version.components(separatedBy: ".") as [String]?,
           let curSubArr = currentVersion.components(separatedBy: ".") as [String]? {
            debugPrint("------version \(version) <=> ------currentVersion \(currentVersion)")
            guard versionArr.count == curSubArr.count else { return true }
            let versionArrInt: [Int] = versionArr.map({Int($0) ?? 0})
            let currentArrInt: [Int] = curSubArr.map({Int($0) ?? 0})
            for (index,_) in versionArrInt .enumerated() {
                if currentArrInt[index] < versionArrInt[index] ||
                    (currentArrInt[index] == versionArrInt[index] && index == currentArrInt.count - 1) {
                    debugPrint("confirmVersion stop version false")
                    return false
                }
            }
            return true
        }
        return false
    }
    
    class func checkNotificationStatus(_ completion: @escaping(_ status: UNAuthorizationStatus)->Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            completion(setting.authorizationStatus)
        }
    }
    
    class func checkUserCamerasStatus( completion: @escaping (_ status: AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            completion(.authorized)
            break
        case .notDetermined: // The user has not yet been asked for camera access.
            completion(.notDetermined)
            break
        case .denied: // The user has previously denied access.
            completion(.denied)
            break
        case .restricted: // The user can't grant access due to restrictions.
            completion(.restricted)
            break
        @unknown default:
            completion(.denied)
            fatalError()
        }
    }
    
    class func requestAccessUserCamerasStatus() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("requestAccess")
            }
            else {
                print("requestAccess false")
            }
        }
    }
    
    class func checkFonts () {
        UIFont.familyNames.forEach {
            print(UIFont.fontNames(forFamilyName: $0))
        }
    }
}

