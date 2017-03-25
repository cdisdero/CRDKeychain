//
//  CRDKeychainEntryError.swift
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
 Errors that occur for operations in the *CRDKeychainEntry* class.
 */
enum CRDKeychainEntryError: LocalizedError {
    
    // MARK: - Error cases

    /// The dictionary representing the keychain element is invalid
    case invalidKeychainDictionary
    
    /// The dictionary contained an invalid or missing kSecAttrGeneric attribute.
    case invalidKey
    
    /// The keychain element dictionary is missing the kSecAttrCreationDate attribute.
    case missingCreationDate
    
    /// The keychain element dictionary is missing the kSecAttrModificationDate attribute.
    case missingModificationDate
    
    // MARK: - LocalizedError protocol methods
    
    /// Provides localized descriptions of each error case.
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
