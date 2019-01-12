//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by Jayesh Thanki on 26/12/18.
//  Copyright © 2018 Logistic Infotech Pvt. Ltd. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        let defaults = UserDefaults(suiteName: "group.logistic.test")
        defaults?.set(nil, forKey: "images")
        defaults?.synchronize()
        
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        guard let apnsData = content.userInfo["data"] as? [String: Any] else {
            contentHandler(request.content)
            return
        }
        
        guard let attachmentURL = apnsData["attachment-url"] as? String else {
            contentHandler(request.content)
            return
        }
        
        do {
            let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.jpg", data: imageData, options: nil) else {
                contentHandler(request.content)
                return
            }
            content.attachments = [attachment]
            contentHandler(content.copy() as! UNNotificationContent)
            
        } catch {
            contentHandler(request.content)
            print("Unable to load data: \(error)")
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
extension UNNotificationAttachment {
    static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?)
        -> UNNotificationAttachment? {
            let fileManager = FileManager.default
            if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.logistic.test") {
                do {
                    let newDirectory = directory.appendingPathComponent("Images")
                    if (!fileManager.fileExists(atPath: newDirectory.path)) {
                        try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
                    }
                    let fileURL = newDirectory.appendingPathComponent(imageFileIdentifier)
                    do {
                        try data.write(to: fileURL, options: [])
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                    
                    let defaults = UserDefaults(suiteName: "group.logistic.test")
                    defaults?.set(data, forKey: "images")
                    defaults?.synchronize()
                    let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier,
                                                                            url: fileURL,
                                                                            options: options)
                    return imageAttachment
                } catch let error {
                    print("error \(error)")
                }
            }
            return nil
    }
}

