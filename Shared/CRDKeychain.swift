//
//  CRDKeychain.swift
//  PassBook
//
//  Created by Christopher Disdero on 11/15/16.
//  Copyright © 2016 Christopher Disdero. All rights reserved.
//

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

enum CRDKeychainError: LocalizedError {
    
    /// An unexpected keychain error occurred.
    case keychainError(status: OSStatus)

    /// Provide localized descriptions of each error case.
    public var errorDescription: String? {
        
        switch self {
            
        case .keychainError(let status):
            #if os(OSX)
                return SecCopyErrorMessageString(status, nil) as String?
            #elseif os(iOS)
                switch status {
                case errSecUnimplemented:
                    return NSLocalizedString("Function of operation not implemented.", comment: "")
                case errSecParam:
                    return NSLocalizedString("One or more parameters passed to the function were not valid.", comment: "")
                case errSecAllocate:
                    return NSLocalizedString("Failed to allocate memory.", comment: "")
                case errSecNotAvailable:
                    return NSLocalizedString("No trust results are available.", comment: "")
                case errSecAuthFailed:
                    return NSLocalizedString("Authorization/Authentication failed.", comment: "")
                case errSecDuplicateItem:
                    return NSLocalizedString("The item already exists.", comment: "")
                case errSecItemNotFound:
                    return NSLocalizedString("The item cannot be found.", comment: "")
                case errSecInteractionNotAllowed:
                    return NSLocalizedString("Interaction with the Security Server is not allowed.", comment: "")
                case errSecDecode:
                    return NSLocalizedString("Unable to decode the provided data.", comment: "")
                case errSecVerifyFailed:
                    return NSLocalizedString("A cryptographic verification failure has occurred.", comment: "")
                default:
                    return NSLocalizedString("Unknown keychain error.", comment: "")
                }
            #endif
        }
    }
}

public class CRDKeychain {

    // MARK: - Private members

    // The keychain access group, if any
    private let accessGroup: String?
    
    // The service which is working with the keychain - in this case the app identifier.
    private let service: String
    
    // The keychain item accessibility level.
    private let accessible: String
    
    // MARK: - Singleton access
    
    static let shared = CRDKeychain(service: Bundle.main.bundleIdentifier!)

    // MARK: - Initialization
    
    private init(service: String, accessGroup: String? = nil, accessible: String = kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String) {
        
        self.accessGroup = accessGroup
        self.service = service
        self.accessible = accessible
    }
    
    // MARK: - Public methods
    
    public func valueFor(key: String, includeData: Bool = false) throws -> CRDKeychainEntry? {
    
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : key as AnyObject,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData  as String : includeData ? kCFBooleanTrue : kCFBooleanFalse,
            kSecMatchLimit  as String : kSecMatchLimitOne ]
        
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
        
        case errSecSuccess:
        
            if let result = result as? NSDictionary {
                
                return try CRDKeychainEntry(keychainEntry: result)
            }
            
            return nil
        
        case errSecItemNotFound:

            return nil

        default:
            
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    public func exists(key: String) throws -> Bool {
        
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : key as AnyObject ]
        
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch status {
        
        case errSecSuccess:
            
            return true
        
        case errSecItemNotFound:

            return false

        default:

            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    public func set(entry: CRDKeychainEntry) throws {
 
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : entry.key as AnyObject ]

        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        var status: OSStatus
        
        if try self.exists(key: entry.key) {

            let updateDictionary: [String: AnyObject] = [
                kSecAttrAccount as String : (entry.account ?? "") as AnyObject,
                kSecAttrDescription as String: (entry.desc ?? "") as AnyObject,
                kSecAttrLabel as String: (entry.label ?? "") as AnyObject,
                kSecAttrComment as String: (entry.notes ?? "") as AnyObject,
                kSecValueData as String: entry.secret as AnyObject,
                kSecAttrSynchronizable as String: entry.synchronizable ? kCFBooleanTrue : kCFBooleanFalse
            ]
            
            status = SecItemUpdate(query as CFDictionary, updateDictionary as CFDictionary)
            
        } else {

            query[kSecAttrAccessible as String] = self.accessible as AnyObject?
            query[kSecAttrAccount as String] = (entry.account ?? "") as AnyObject?
            query[kSecAttrDescription as String] = (entry.desc ?? "") as AnyObject?
            query[kSecAttrLabel as String] = (entry.label ?? "") as AnyObject?
            query[kSecAttrComment as String] = (entry.notes ?? "") as AnyObject?
            query[kSecValueData as String] = entry.secret as AnyObject?
            query[kSecAttrSynchronizable as String] = entry.synchronizable ? kCFBooleanTrue : kCFBooleanFalse

            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        switch status {
            
        case errSecSuccess:
            
            break
            
        default:
            
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    public func getAll(includeData: Bool = false) throws -> [CRDKeychainEntry]? {
        
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnData  as String : includeData ? kCFBooleanTrue : kCFBooleanFalse,
            kSecMatchLimit  as String : kSecMatchLimitAll ]
        
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
            
        case errSecSuccess:
            
            if let result = result as? Array<NSDictionary> {
                
                var entriesFound: [CRDKeychainEntry] = []
                for item in result {
                    
                    entriesFound.append(try CRDKeychainEntry(keychainEntry: item))
                }
                
                return entriesFound
            }
            
            return nil
            
        case errSecItemNotFound:

            return nil

        default:
            
            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    public func remove(key: String) throws {
        
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrGeneric as String : key as AnyObject ]
        
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        
        case errSecSuccess:
            
            break
        
        case errSecItemNotFound:
            
            break

        default:

            throw CRDKeychainError.keychainError(status: status)
        }
    }
    
    public func removeAll() throws {
        
        var query: [String: AnyObject] = [
            kSecAttrService as String : self.service as AnyObject,
            kSecClass       as String : kSecClassGenericPassword ]
        
        if let accessGroup = self.accessGroup {
            
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        
        case errSecSuccess:
            
            break
        
        case errSecItemNotFound:
            
            break

        default:

            throw CRDKeychainError.keychainError(status: status)
        }
    }
}
