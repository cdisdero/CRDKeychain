//
//  CRDKeychainEntry.swift
//  PassBook
//
//  Created by Christopher Disdero on 11/16/16.
//  Copyright © 2016 Christopher Disdero. All rights reserved.
//

import Foundation

enum CRDKeychainEntryError: LocalizedError {
    
    // The dictionary representing the keychain element is invalid
    case invalidKeychainDictionary
    
    // The dictionary contained an invalid or missing kSecAttrGeneric attribute.
    case invalidKey
    
    // The keychain element dictionary is missing the kSecAttrCreationDate attribute.
    case missingCreationDate

    // The keychain element dictionary is missing the kSecAttrModificationDate attribute.
    case missingModificationDate
    
    // Provide localized descriptions of each error case.
    public var errorDescription: String? {
        
        switch self {

        case .invalidKeychainDictionary:
            return NSLocalizedString("The keychain dictionary is invalid.", comment: "")
        
        case .invalidKey:
            return NSLocalizedString("The key is invalid.", comment: "")
            
        case .missingCreationDate:
            return NSLocalizedString("Creation date is missing.", comment: "")
            
        case .missingModificationDate:
            return NSLocalizedString("Modification date is missing.", comment: "")
        }
    }
}

public class CRDKeychainEntry: NSObject {

    // MARK: - Public read-only properties
    
    // The read-only identifier for this entry (kSecAttrGeneric) [non-nil, indexed], created when the instance is initialized.
    public let key: String
    
    // The creation date for this entry from the keychain (kSecAttrCreationDate).
    public let creationDate: Date
    
    // The modification date for this entry from the keychain (kSecAttrModificationDate).
    public let modificationDate: Date
    
    // MARK: - Public read-write properties
    
    // The name for this entry (kSecAttrAccount) [indexed].
    public var account: String? = nil
    
    // The type description for this entry, if any (kSecAttrDescription).
    public var desc: String? = nil

    // The label, if any, that the password is associated with (kSecAttrLabel).
    public var label: String? = nil

    // Notes associated with this entry, if any (kSecAttrComment).
    public var notes: String? = nil

    // The secret data, if any, associated with this entry.
    public var secret: Data? = nil

    // A flag to indicate whether this keychain item should be synchronizable via iCloud Keychain
    public var synchronizable: Bool = false
    
    // MARK: - Initialization
    
    public init(key: String) {
        
        // Store the key
        self.key = key
        
        // Set default dates - will change once this entry is added to the keychain.
        self.creationDate = Date()
        self.modificationDate = Date()
    }
    
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
