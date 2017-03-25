//
//  CRDKeychainEntry.swift
//  PassBook
//
//  Created by Christopher Disdero on 11/16/16.
//
/*
 Copyright © 2017 Christopher Disdero.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

/**
 Class that represents an entry in the device keychain.
 */
public class CRDKeychainEntry: NSObject {

    // MARK: - Public read-only properties
    
    /// The read-only identifier or key for this entry (kSecAttrGeneric) [non-nil, indexed], created when the instance is initialized. This key is used to find keychain entries.
    public let key: String
    
    /// The creation date for this entry from the keychain (kSecAttrCreationDate) set when the entry is added to the keychain.
    public let creationDate: Date
    
    /// The modification date for this entry from the keychain (kSecAttrModificationDate) updated when the entry is modified in the keychain.
    public let modificationDate: Date
    
    // MARK: - Public read-write properties
    
    /// The account name for this entry (kSecAttrAccount) if any. [indexed]
    public var account: String? = nil
    
    /// The description for this entry, if any (kSecAttrDescription).
    public var desc: String? = nil

    /// The label for this entry, if any (kSecAttrLabel).
    public var label: String? = nil

    /// Notes associated with this entry, if any (kSecAttrComment).
    public var notes: String? = nil

    /// The secret data, if any, associated with this entry (kSecValueData).
    public var secret: Data? = nil

    /// A flag to indicate whether this keychain item should be synchronizable via iCloud Keychain (kSecAttrSynchronizable). Set to false by default.
    public var synchronizable: Bool = false
    
    // MARK: - Initialization
    
    /**
     Instantiates a new CRDKeychainEntry object that represents a keychain entry with the key specified.
     
     - parameter key: The string value for the key used to lookup the entry.
     */
    public init(key: String) {
        
        // Store the key
        self.key = key
        
        // Set default dates - will change once this entry is added to the keychain.
        self.creationDate = Date()
        self.modificationDate = Date()
    }
    
    /**
     Instantiates a new CRDKeychainEntry object that represents a keychain entry using the attributes and key value from a dictionary.
     
     - parameter keychainEntry: A dictionary containing at least a key (kSecAttrGeneric), creation date (kSecAttrCreationDate) and modification date (kSecAttrModificationDate).  If data is present (kSecValueData), it is set into the CRDKeychainEntry object.
     
     - throws: CRDKeychainEntryError with a case value indicating the type of failure.
     */
    public init(keychainEntry: NSDictionary) throws {
        
        // Guard against invalid keychain dictionary passed in.
        guard keychainEntry.count > 0 else {
            
            throw CRDKeychainEntryError.invalidKeychainDictionary
        }
        
        // Get the key.
        var key: String? = nil
        if let keyData = keychainEntry[kSecAttrGeneric] as? Data {
            
            // On macOS the kSecAttrGeneric seems to be returned as Data, not as a String like on iOS, so decode it here if necessary.
            key = String(data: keyData, encoding: .utf8)
        
        } else {
            
            key = keychainEntry[kSecAttrGeneric] as? String
        }
        
        // Guard against invalid information in the dictionary passed in.
        guard let useKey = key else {
            
            throw CRDKeychainEntryError.invalidKey
        }
        guard let creationDate = keychainEntry[kSecAttrCreationDate] as? Date else {
            
            throw CRDKeychainEntryError.missingCreationDate
        }
        guard let modificationDate = keychainEntry[kSecAttrModificationDate] as? Date else {
        
            throw CRDKeychainEntryError.missingModificationDate
        }
        
        // Store the key
        self.key = useKey
        
        // Store creation and modification dates.
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        
        // Store the account from the keychain for this entry, if available.
        if let account = keychainEntry[kSecAttrAccount] as? String  {
            
            self.account = account
        }
        
        // Store the category from the keychain for this entry, if available.
        if let desc = keychainEntry[kSecAttrDescription] as? String {
        
            self.desc = desc
        }

        // Store the label if available.
        if let label = keychainEntry[kSecAttrLabel] as? String {
            
            self.label = label
        }
        
        // Store the notes if available.
        if let notes = keychainEntry[kSecAttrComment] as? String {
            
            self.notes = notes
        }
        
        // Set keychainObject from the entry's secret 'data' bytes if available.
        self.secret = keychainEntry[kSecValueData] as? Data
    }

    // MARK: - Equatable protocol
    
    public override func isEqual(_ object: Any?) -> Bool {
        
        if object is CRDKeychainEntry {
         
            let compareTo = object as! CRDKeychainEntry
            
            let keys = self.key.compare(compareTo.key) == .orderedSame
            let accounts = self.account == compareTo.account || self.account?.compare(compareTo.account!) == .orderedSame
            let descs = self.desc == compareTo.desc || self.desc?.compare(compareTo.desc!) == .orderedSame
            let labels = self.label == compareTo.label || self.label?.compare(compareTo.label!) == .orderedSame
            
            return keys && accounts && descs && labels
        }
        
        return false
    }
}
