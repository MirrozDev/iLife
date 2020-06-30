//
//  Page.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit
import os.log

class Page: NSObject, NSCoding {
    
    //MARK: Properties
    var title: String
    var historyId: Int
    var date: Date
    var localizationName: String
    var locLon: Double
    var locLat: Double
    var image: UIImage?
    var text: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("pages")
    
    //MARK: Types
    struct PropertyKey {
        static let title = "title"
        static let historyId = "historyId"
        static let date = "date"
        static let localizationName = "localizationName"
        static let locLon = "locLon"
        static let locLat = "locLat"
        static let image = "image"
        static let text = "text"
    }
    
    //MARK: Initialization
    
    init?(title: String, historyId: Int, date: Date, localizationName: String, locLon: Double, locLat: Double, image: UIImage?, text: String) {
        
        self.title = title
        self.historyId = historyId
        self.date = date
        self.localizationName = localizationName
        self.locLon = locLon
        self.locLat = locLat
        self.image = image
        self.text = text
        
    }
    
    //MARK: NSCoding
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: PropertyKey.title)
        coder.encode(historyId, forKey: PropertyKey.historyId)
        coder.encode(date, forKey: PropertyKey.date)
        coder.encode(localizationName, forKey: PropertyKey.localizationName)
        coder.encode(locLon, forKey: PropertyKey.locLon)
        coder.encode(locLat, forKey: PropertyKey.locLat)
        coder.encode(image, forKey: PropertyKey.image)
        coder.encode(text, forKey: PropertyKey.text)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String
            else {
                os_log("Unable to decode the title for a Page object.", log: OSLog.default, type: .debug)
                return nil
        }
        
        let historyId = aDecoder.decodeInteger(forKey: PropertyKey.historyId)
        
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date
        else {
                os_log("Unable to decode the date for a Page object.", log: OSLog.default, type: .debug)
                return nil
        }
        
        guard let localizationName = aDecoder.decodeObject(forKey: PropertyKey.localizationName) as? String
        else {
                os_log("Unable to decode the localization name for a Page object.", log: OSLog.default, type: .debug)
                return nil
        }
        
        let locLon = aDecoder.decodeDouble(forKey: PropertyKey.locLon)
        let locLat = aDecoder.decodeDouble(forKey: PropertyKey.locLat)
        
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        
        guard let text = aDecoder.decodeObject(forKey: PropertyKey.text) as? String
        else {
                os_log("Unable to decode the text for a Page object.", log: OSLog.default, type: .debug)
                return nil
        }
        
        self.init(title: title, historyId: historyId, date: date, localizationName: localizationName, locLon: locLon, locLat: locLat, image: image, text: text)
        
    }
    
}
