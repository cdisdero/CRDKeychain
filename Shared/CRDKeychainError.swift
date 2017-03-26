//
//  CRDKeychainError.swift
//  CRDKeychain
//
//  Created by Christopher Disdero on 3/24/17.
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
 Errors that occur for operations in the *CRDKeychain* class.
 */
public enum CRDKeychainError: LocalizedError {
    
    // MARK: - Error cases
    
    /// The service name (kSecAttrService) specified when initializing the keychain is invalid.
    case invalidServiceName
    
    /// The accessible constant value (kSecAttrAccessible) specified when initializing the keychain is invalid.
    case invalidAccessibleConstantValue
    
    /// The access group name specified (kSecAttrAccessGroup) is invalid.
    case invalidAccessGroup
    
    /// An unexpected keychain error occurred.
    case keychainError(status: OSStatus)
    
    // MARK: - LocalizedError protocol methods
    
    /// Provides localized descriptions of each error case.
    public var errorDescription: String? {
        
        switch self {
            
        case .invalidServiceName:
            return NSLocalizedString("The service name specified is invalid.", comment: "")
            
        case .invalidAccessibleConstantValue:
            return NSLocalizedString("The accessible constant value specified is invalid.", comment: "")
            
        case .invalidAccessGroup:
            return NSLocalizedString("The access group name specified is invalid.", comment: "")
            
        // Lookup the status of the error case and find a suitable localized description.
        case .keychainError(let status):
            
            #if os(OSX)
            
                // On macOS, we can call this method to return the localized description of the status.
                return SecCopyErrorMessageString(status, nil) as String?
            
            #elseif os(iOS)
                
                // On iOS, SecCopyErrorMessageString is not available, so instead return localized descriptions of some of the most common statuses.
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
