//
//  History.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit
import os.log

class History: NSObject, NSCoding {
    
    //MARK: Properties
    var name: String
    var id: Int?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("histories")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let id = "id"
    }
    
    //MARK: Initialization
    
    init?(name: String) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.id = nil
    }
    
    init?(name: String, id: Int) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.id = id
    }

    //MARK: NSCoding
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(id, forKey: PropertyKey.id)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
        else {
            os_log("Unable to decode the name for a History object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let id = aDecoder.decodeObject(forKey: PropertyKey.id) as? Int
        else {
            os_log("Unable to decode the id for a History object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, id: id)
        
    }
    
    
}
