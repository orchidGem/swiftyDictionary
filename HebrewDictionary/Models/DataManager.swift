//
//  DataManager.swift
//  ToDoApp
//
//  Created by Laura Evans on 1/21/18.
//  Copyright © 2018 Laura Evans. All rights reserved.
//

import Foundation

class DataManager {
    // get Document Directory
    static fileprivate func getDocumentDirectory(identifier: String?) -> URL {
        
        if let identifier = identifier {
            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
                return url
            } else {
                fatalError("unable to access document directory with identifier")
            }
        } else {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                return url
            } else {
                fatalError("Unable to access document directory")
            }
        }
    }
    
    // Save any kind of codable objects
    static func save <T: Encodable> (_ object: T, with fileName: String, identifier: String?) -> Bool {
        let url = getDocumentDirectory(identifier: identifier).appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(object)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("file not found")
            }
            
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
            
            return true
        } catch {
            return false
        }
        
    }
    
    // Load any kind of codable objects
    static func load <T:Decodable> (_ fileName: String, with type: T.Type, identifier: String?) -> T? {
        let url = getDocumentDirectory(identifier: identifier).appendingPathComponent(fileName, isDirectory: false)
        if identifier == nil &&  FileManager.default.fileExists(atPath: url.path) == false {
            fatalError("file not found at path \(url.path)")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                let model = try JSONDecoder().decode(type, from: data)
                return model
            } catch {
                return nil
            }
        } else {
            print("data unanaivable at path", url.path)
            return nil
        }
    }
    
    // load data from a file
    static func loadData (_ fileName: String, identifier: String?) -> Data? {
        let url = getDocumentDirectory(identifier: identifier).appendingPathComponent(fileName, isDirectory: false)
        if identifier == nil && FileManager.default.fileExists(atPath: url.path) == false {
            fatalError("file not found at path \(url.path)")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            return data
        } else {
            fatalError("Data unavailable at path \(url.path)")
        }
    }
    
    // Load all files from a directory
    static func loadAll <T: Decodable> (_ type: T.Type, identifier: String?) -> [T] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory(identifier: identifier).path)
            var modelObjects = [T]()
            
            for fileName in files {
                if let result = load(fileName, with: type, identifier: identifier) {
                    modelObjects.append(result)
                }
            }
            
            return modelObjects
        } catch {
            fatalError("could not load any files")
        }
    }
    
    // Delete a file
    static func delete (_ fileName: String, identifier: String?) {
        let url = getDocumentDirectory(identifier: identifier).appendingPathComponent(fileName, isDirectory: false)
        
        if identifier == nil && FileManager.default.fileExists(atPath: fileName) == false {
            print("file does not exist")
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            fatalError(error.localizedDescription)
        }

    }
}

