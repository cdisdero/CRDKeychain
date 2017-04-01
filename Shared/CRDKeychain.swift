//
//  CRDKeychain.swift
//  PassBook
//
//  Created by Christopher Disdero on 11/15/16.
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
 Class that represents the device keychain.
 */
public class CRDKeychain {

    // MARK: - Private members

    /// The keychain access group (kSecAttrAccessGroup), if any
    private let accessGroup: String?
    
    /// The service which is working with the keychain (kSecAttrService), by default this app's bundle identifier.
    private let service: String
    
    // The keychain item accessibility level (kSecAttrAccessible).
    private let accessible: String
    
    // MARK: - Initialization
    
    /**
     Instantiates a new *CRDKeychain* object with the given service name, access group, and accessibility constant provided.
     
     - parameter service: The *kSecAttrService* value used for every *CRDKeychainEntry* in the keychain. Default is the main application bundle identifier.
     
     - parameter accessGroup: The *kSecAttrAccessGroup* value used for every *CRDKeychainEntry* in the keychain.  The default is nil, or no access group.  Access groups are used for keychain item sharing between apps.
     
     - parameter accessible: The value of *kSecAttrAccessible* used for writing *CRDKeychainEntry*s to the keychain.  The default is *kSecAttrAccessibleWhenUnlockedThisDeviceOnly* which means that the keychain entry is only accessible when the device is unlocked.
     */
    public init(service: String = Bundle.main.bundleIdentifier!, accessGroup: String? = nil, accessible: String = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String) throws {
        
        // Ensure the service name specified is not empty.
        guard !service.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        
            throw CRDKeychainError.invalidServiceName
        }
        
        // Ensure the accessible attribute is valid.
        guard !accessible.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (
            accessible.compare(kSecAttrAccessibleAfterFirstUnlock as String) == .orderedSame ||
            accessible.compare(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String) == .orderedSame ||
            accessible.compare(kSecAttrAccessibleAlways as String) == .orderedSame ||
            accessible.compare(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String) == .orderedSame ||
            accessible.compare(kSecAttrAccessibleAlwaysThisDeviceOnly as String) == .orderedSame ||
            accessible.compare(kSecAttrAccessibleWhenUnlocked as String) == .orderedSame ||
            accessible.compare(kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String) == .orderedSame
            ) else {
            
                throw CRDKeychainError.invalidAccessibleConstantValue
        }
        
        // Ensure the access group, if specified, is not empty.
        if accessGroup != nil {
            
            guard let accessGroup = accessGroup, !accessGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                
                throw CRDKeychainError.invalidAccessGroup
            }
        }
        
        // Set the access group (the shared keychain group name kSecAttrAccessGroup), if any.
        self.accessGroup = accessGroup
        
        // Set the service (kSecAttrService) used to stamp all the entries made as belonging to this app.
        self.service = service
        
        // Set the accessibility constant (kSecAttrAccessible) for entries written.
        self.accessible = accessible
    }
    
    // MARK: - Public methods
    
    /**
     Returns the *CRDKeychainEntry* found for the given *key*.
     
     - parameter key: The string value for the key used to lookup the entry.
     
     - parameter includeData: A flag (*kSecReturnData*) indicating whether to return the data associated with the entry (*kSecValueData*) or not.  The default is false to not return the data.  This makes retrieval faster.
     
     - returns: A *CRDKeychainEntry* object representing the keychain entry found, or nil if no entry was found for the specified key.
     
     - throws: Throws a *CRDKeychainError* with the error status.
     */
    public func valueFor(key: String, includeData: Bool = false) throws -> CRDKeychainEntry? {
    
        // Form the query to search for the entry by the key specified.
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : key as AnyObject,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData  as String : includeData ? kCFBooleanTrue : kCFBooleanFalse,
            kSecMatchLimit  as String : kSecMatchLimitOne ]
        
        // If a non-nil access group was specified, put it in the query.
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        // Get the results of the query, if any.
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
        
        case errSecSuccess:
        
            // We found an entry, so create and return a new CRDKeychainEntry based on the dictionary of attributes found.
            if let result = result as? NSDictionary {
                
                return try CRDKeychainEntry(keychainEntry: result)
            }
            
            // If the result is not a dictionary, something must have gone wrong, so return nil.
            return nil
        
        case errSecItemNotFound:

            // Couldn't find any entry for the specified key, so return nil.
            return nil

        default:
            
            // An error status was returned, so throw an exception back to the caller with this status.
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    /**
     Returns true if an entry in the keychain can be found for the specified key.
     
     - parameter key: The string value for the key used to lookup the entry.
     
     - returns: True if an entry can be found for the key, or false otherwise.
     
     - throws: Throws a *CRDKeychainError* with the error status.
     */
    public func exists(key: String) throws -> Bool {
        
        // Form the query based on the key.
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : key as AnyObject ]
        
        // If a non-nil access group was specified, put it in the query.
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        // Try to find an entry matching the key.
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch status {
        
        case errSecSuccess:
            
            // An entry was found.
            return true
        
        case errSecItemNotFound:

            // No matching entry was found.
            return false

        default:

            // An error status was returned, so throw an exception back to the caller with this status.
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    /**
     Sets an entry into the keychain.
     
     - parameter entry: The *CRDKeychainEntry* representing the keychain entry to add or update.
     
     - remark: If the specified entry key matches one in the keychain, the attributes of this entry will update the existing entry found.
     
     - throws: Throws a *CRDKeychainError* with the error status.
     */
    public func set(entry: CRDKeychainEntry) throws {
 
        // Form a query based on the specified entry key.
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : entry.key as AnyObject ]

        // If a non-nil access group was specified, put it in the query.
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        var status: OSStatus
        
        // Try to find the entry key
        if try self.exists(key: entry.key) {

            // kSecAttrSynchronizable is not available on watchOS
            #if os(watchOS)

                // If found, form an update dictionary of attribute values from the specified entry.
                let updateDictionary: [String: AnyObject] = [
                    kSecAttrAccount as String : (entry.account ?? "") as AnyObject,
                    kSecAttrDescription as String: (entry.desc ?? "") as AnyObject,
                    kSecAttrLabel as String: (entry.label ?? "") as AnyObject,
                    kSecAttrComment as String: (entry.notes ?? "") as AnyObject,
                    kSecValueData as String: entry.secret as AnyObject
                ]

            #else

                // If found, form an update dictionary of attribute values from the specified entry.
                let updateDictionary: [String: AnyObject] = [
                    kSecAttrAccount as String : (entry.account ?? "") as AnyObject,
                    kSecAttrDescription as String: (entry.desc ?? "") as AnyObject,
                    kSecAttrLabel as String: (entry.label ?? "") as AnyObject,
                    kSecAttrComment as String: (entry.notes ?? "") as AnyObject,
                    kSecValueData as String: entry.secret as AnyObject,
                    kSecAttrSynchronizable as String: entry.synchronizable ? kCFBooleanTrue : kCFBooleanFalse
                ]

            #endif
            
            // Update the existing keychain item with these new attribute values.
            status = SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary)
            
        } else {

            // Add the specified entry attribute values to the original query.
            query[kSecAttrAccessible as String] = self.accessible as AnyObject?
            query[kSecAttrAccount as String] = (entry.account ?? "") as AnyObject?
            query[kSecAttrDescription as String] = (entry.desc ?? "") as AnyObject?
            query[kSecAttrLabel as String] = (entry.label ?? "") as AnyObject?
            query[kSecAttrComment as String] = (entry.notes ?? "") as AnyObject?
            query[kSecValueData as String] = entry.secret as AnyObject?
            
            // kSecAttrSynchronizable is not available on watchOS
            #if os(iOS) || os(macOS) || os(tvOS)
            query[kSecAttrSynchronizable as String] = entry.synchronizable ? kCFBooleanTrue : kCFBooleanFalse
            #endif
                
            // Add the entry specified to the keychain.
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        switch status {
            
        case errSecSuccess:
            
            // The entry was successfully added/updated.
            break
            
        default:
            
            // An error status was returned, so throw an exception back to the caller with this status.
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    /**
     Gets all the entries in the keychain.
     
     - parameter includeData: A flag (*kSecReturnData*) indicating whether to return the data associated with each entry (*kSecValueData*) or not.  The default is false to not return the data.  This makes retrieval faster.
     
     - returns: An array of *CRDKeychainEntry* objects representing the keychain entries found, or nil if no entries were found.
     
     - throws: Throws a *CRDKeychainError* with the error status.
     */
    public func getAll(includeData: Bool = false) throws -> [CRDKeychainEntry]? {
        
        // Form the query for all items in the keychain.
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData  as String : includeData ? kCFBooleanTrue : kCFBooleanFalse,
            kSecMatchLimit  as String : kSecMatchLimitAll ]
        
        // If a non-nil access group was specified, put it in the query.
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        // Try to get all the entries.
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
            
        case errSecSuccess:
            
            // We successfully got all the entries, so convert each entry to a CRDKeychainEntry object and put in the return array.
            if let result = result as? Array<NSDictionary> {
                
                var entriesFound: [CRDKeychainEntry] = []
                for item in result {
                    
                    entriesFound.append(try CRDKeychainEntry(keychainEntry: item))
                }
                
                return entriesFound
            }
            
            // If the result is not an array of dictionaries (representing the entries), then something went wrong and so just return nil.
            return nil
            
        case errSecItemNotFound:

            // No items were found (keychain empty) so return nil.
            return nil

        default:
            
            // An error status was returned, so throw an exception back to the caller with this status.
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    /**
     Removes the keychain entry matching the specified key.

     - parameter key: The string value for the key used to lookup the entry to remove.
     
     - throws: Throws a *CRDKeychainError* with the error status.
     */
    public func remove(key: String) throws {
        
        // Form the query for the item to remove.
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : key as AnyObject ]
        
        // If a non-nil access group was specified, put it in the query.
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        // Try to delete the entry matching the key.
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        
        case errSecSuccess:
            
            // We successfully deleted the entry.
            break
        
        case errSecItemNotFound:
            
            // No entry was found matching the key.
            break

        default:

            // An error status was returned, so throw an exception back to the caller with this status.
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    /**
     Removes all entries found in the keychain.
     
     - throws: Throws a *CRDKeychainError* with the error status.
     */
    public func removeAll() throws {
        
        // Form the query for all keychain items.
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword]
        
        // On macOS it seems like passing the kSecMatchLimit is necessary to get all of the entries that match - not just the first one.  However, passing this attribute on iOS will cause errors, so we won't do that.
        #if os(OSX)
            query[kSecMatchLimit as String] = kSecMatchLimitAll
        #endif // OSX
        
        // If a non-nil access group was specified, put it in the query.
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        // Try to remove all the keychain items matching the query.
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        
        case errSecSuccess:
            
            // Successfully removed all the items.
            break
        
        case errSecItemNotFound:
            
            // The keychain was empty so no items were removed.
            break

        default:

            // An error status was returned, so throw an exception back to the caller with this status.
            throw CRDKeychainError.keychainError(status: status)
        }
    }
}
