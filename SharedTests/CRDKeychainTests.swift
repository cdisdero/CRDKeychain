//
//  CRDKeychainTests.swift
//  PassBook
//
//  Created by Christopher Disdero on 2/12/17.
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

import XCTest

#if os(OSX)
    @testable import CRDKeychainMac
#elseif os(iOS)
    @testable import CRDKeychainMobile
#endif

class CRDKeychainTests: XCTestCase {
    
    // MARK: - Private members
    
    /// The keychain
    private var keychain: CRDKeychain? = nil
    
    // MARK: - Test setup and teardown
    
    override func setUp() {
        
        super.setUp()

        // Setup the keychain
        do {
            
            keychain = try CRDKeychain()
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }

        // Remove all items from the keychain
        do {
            
            try keychain?.removeAll()
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
    
    override func tearDown() {

        // Remove all items from the keychain
        do {
            
            try keychain?.removeAll()
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }

        super.tearDown()
    }
    
    // MARK: - Tests
    
    // MARK: - CRDKeychain.init()
    
    /// Tests the CRDKeychain initializer with an invalid service.
    func testInitCRDKeychainInvalidService() {
        
        var gotError = false
        do {
            
            _ = try CRDKeychain(service: " \t\r\n")
        
        } catch (CRDKeychainError.invalidServiceName) {
            
            gotError = true
        
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests the CRDKeychain initializer with an invalid access group.
    func testInitCRDKeychainInvalidAccessGroup() {
        
        var gotError = false
        do {
            
            _ = try CRDKeychain(accessGroup: " \r\n\t ")
            
        } catch (CRDKeychainError.invalidAccessGroup) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests the CRDKeychain initializer with an invalid accessible constant.
    func testInitCRDKeychainInvalidAccessible() {
        
        var gotError = false
        do {
            
            _ = try CRDKeychain(accessible: " \r\n\t ")
            
        } catch (CRDKeychainError.invalidAccessibleConstantValue) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")

        gotError = false
        do {
            
            _ = try CRDKeychain(accessible: "Blippo")
            
        } catch (CRDKeychainError.invalidAccessibleConstantValue) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    // MARK: - CRDKeychainEntry.init()
    
    /// Tests initializing a new CRDKeychainEntry with an invalid key.
    func testInitCRDKeychainEntryKeyInvalidKey() {
        
        var gotError = false
        do {
            
            _ = try CRDKeychainEntry(key: " \r\n\t  ")
            
        } catch (CRDKeychainEntryError.invalidKey) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }

    /// Tests initializing a new CRDKeychainEntry with an invalid dictionary key.
    func testInitCRDKeychainEntryDictionaryInvalidKey() {
        
        var gotError = false
        do {
            
            let dictionary: [String : AnyObject] = [
                kSecAttrGeneric as String: " \r\n\t  " as AnyObject,
                kSecAttrCreationDate as String: Date() as AnyObject,
                kSecAttrModificationDate as String: Date() as AnyObject
            ]
            _ = try CRDKeychainEntry(keychainEntry: dictionary as NSDictionary)
            
        } catch (CRDKeychainEntryError.invalidKey) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests initializing a new CRDKeychainEntry with an invalid dictionary key as data.
    func testInitCRDKeychainEntryDictionaryInvalidKeyAsData() {
        
        var gotError = false
        do {
            
            let dictionary: [String : AnyObject] = [
                kSecAttrGeneric as String: " \r\n\t  ".data(using: .utf8) as AnyObject,
                kSecAttrCreationDate as String: Date() as AnyObject,
                kSecAttrModificationDate as String: Date() as AnyObject
            ]
            _ = try CRDKeychainEntry(keychainEntry: dictionary as NSDictionary)
            
        } catch (CRDKeychainEntryError.invalidKey) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests initializing a new CRDKeychainEntry with a missing creation date.
    func testInitCRDKeychainEntryDictionaryMissingCreationDate() {
        
        var gotError = false
        do {
            
            let dictionary: [String : AnyObject] = [
                kSecAttrGeneric as String: "Blippo" as AnyObject,
                kSecAttrModificationDate as String: Date() as AnyObject
            ]
            _ = try CRDKeychainEntry(keychainEntry: dictionary as NSDictionary)
            
        } catch (CRDKeychainEntryError.missingCreationDate) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests initializing a new CRDKeychainEntry with a missing modification date.
    func testInitCRDKeychainEntryDictionaryMissingModificationDate() {
        
        var gotError = false
        do {
            
            let dictionary: [String : AnyObject] = [
                kSecAttrGeneric as String: "Blippo" as AnyObject,
                kSecAttrCreationDate as String: Date() as AnyObject
            ]
            _ = try CRDKeychainEntry(keychainEntry: dictionary as NSDictionary)
            
        } catch (CRDKeychainEntryError.missingModificationDate) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests initializing a new CRDKeychainEntry with an missing dictionary key.
    func testInitCRDKeychainEntryDictionaryMissingKey() {
        
        var gotError = false
        do {
            
            let dictionary: [String : AnyObject] = [
                kSecAttrCreationDate as String: Date() as AnyObject,
                kSecAttrModificationDate as String: Date() as AnyObject
            ]
            _ = try CRDKeychainEntry(keychainEntry: dictionary as NSDictionary)
            
        } catch (CRDKeychainEntryError.invalidKey) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    /// Tests initializing a new CRDKeychainEntry with empty dictionary.
    func testInitCRDKeychainEntryDictionaryEmptyDictionary() {
        
        var gotError = false
        do {
            
            let dictionary: [String : AnyObject] = [:]
            _ = try CRDKeychainEntry(keychainEntry: dictionary as NSDictionary)
            
        } catch (CRDKeychainEntryError.invalidKeychainDictionary) {
            
            gotError = true
            
        } catch {
            
            // Do nothing here.
        }
        
        XCTAssertTrue(gotError, "failed to get expected exception")
    }
    
    // MARK: - set() and valueFor()
    
    /// Tests setting a new entry and getting that entry.
    func testSetNewAndGet() {

        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry = try CRDKeychainEntry(key: "key1")
            expectedEntry.account = "account1"
            expectedEntry.label = "label1"
            expectedEntry.desc = "this is the description"
            expectedEntry.notes = "this is the comment"
            expectedEntry.secret = "this is the data".data(using: .utf8)

            // There should be no entry for this key in the keychain.
            let foundEntry = try keychain?.valueFor(key: "key1")
            XCTAssertNil(foundEntry)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry)
            
            // Get the entry just added from the keychain.
            let actualEntry = try keychain?.valueFor(key: "key1", includeData: true)
            XCTAssertNotNil(actualEntry)
            
            // The entry in the keychain should be equal to the expected entry.
            XCTAssertEqual(actualEntry, expectedEntry)
            
            // Check that the secret data is the same
            XCTAssertEqual(actualEntry?.secret, expectedEntry.secret)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }

    /// Tests updating an existing entry and getting it.
    func testSetExistingAndGet() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry = try CRDKeychainEntry(key: "key1")
            expectedEntry.account = "account1"
            expectedEntry.label = "label1"
            expectedEntry.desc = "this is the description"
            expectedEntry.notes = "this is the comment"
            expectedEntry.secret = "this is the data".data(using: .utf8)
            
            // There should be no entry for this key in the keychain.
            let foundEntry = try keychain?.valueFor(key: "key1")
            XCTAssertNil(foundEntry)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry)
            
            // We expect only one entry
            var entries = try keychain?.getAll()
            XCTAssertEqual(entries?.count, 1)

            // Get the entry just added from the keychain.
            var actualEntry = try keychain?.valueFor(key: "key1", includeData: true)
            XCTAssertNotNil(actualEntry)
            
            // The entry in the keychain should be equal to the expected entry.
            XCTAssertEqual(actualEntry, expectedEntry)
            
            // Check that the secret data is the same
            XCTAssertEqual(actualEntry?.secret, expectedEntry.secret)
            
            // Modify original expected entry
            expectedEntry.account = "account2"
            expectedEntry.label = "label2"
            expectedEntry.desc = "this is the modified description"
            expectedEntry.notes = "this is the modified comment"
            expectedEntry.secret = "this is the modified data".data(using: .utf8)
            
            try keychain?.set(entry: expectedEntry)
            
            // We expect only one entry
            entries = try keychain?.getAll()
            XCTAssertEqual(entries?.count, 1)
            
            // Get the entry just modified from the keychain.
            actualEntry = try keychain?.valueFor(key: "key1", includeData: true)
            XCTAssertNotNil(actualEntry)
            
            // The entry in the keychain should be equal to the modified entry.
            XCTAssertEqual(actualEntry, expectedEntry)
            
            // Check that the secret data is the same
            XCTAssertEqual(actualEntry?.secret, expectedEntry.secret)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
    
    /// Tests setting an entry twice and getting it.
    func testSetSaveKeyTwiceAndGet() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry = try CRDKeychainEntry(key: "key1")
            expectedEntry.account = "account1"
            expectedEntry.label = "label1"
            expectedEntry.desc = "this is the description"
            expectedEntry.notes = "this is the comment"
            expectedEntry.secret = "this is the data".data(using: .utf8)
            
            // There should be no entry for this key in the keychain.
            let foundEntry = try keychain?.valueFor(key: "key1")
            XCTAssertNil(foundEntry)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry)
            
            // We expect only one entry
            var entries = try keychain?.getAll()
            XCTAssertEqual(entries?.count, 1)
            
            // Get the entry just added from the keychain.
            var actualEntry = try keychain?.valueFor(key: "key1", includeData: true)
            XCTAssertNotNil(actualEntry)
            
            // The entry in the keychain should be equal to the expected entry.
            XCTAssertEqual(actualEntry, expectedEntry)
            
            // Check that the secret data is the same
            XCTAssertEqual(actualEntry?.secret, expectedEntry.secret)
            
            // Set the same key again
            try keychain?.set(entry: expectedEntry)
            
            // We expect only one entry
            entries = try keychain?.getAll()
            XCTAssertEqual(entries?.count, 1)
            
            // Get the entry just modified from the keychain.
            actualEntry = try keychain?.valueFor(key: "key1", includeData: true)
            XCTAssertNotNil(actualEntry)
            
            // The entry in the keychain should be equal to the original entry.
            XCTAssertEqual(actualEntry, expectedEntry)
            
            // Check that the secret data is the same
            XCTAssertEqual(actualEntry?.secret, expectedEntry.secret)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
    
    // MARK: - exists()
    
    /// Tests whether a newly added entry exists.
    func testExists() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry = try CRDKeychainEntry(key: "key1")
            expectedEntry.account = "account1"
            expectedEntry.label = "label1"
            expectedEntry.desc = "this is the description"
            expectedEntry.notes = "this is the comment"
            expectedEntry.secret = "this is the data".data(using: .utf8)

            // There should be no entry for this key in the keychain.
            var foundEntry = try keychain?.exists(key: "key1")
            XCTAssertFalse(foundEntry!)

            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry)
            
            // The new entry should now exist.
            foundEntry = try keychain?.exists(key: "key1")
            XCTAssertTrue(foundEntry!)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
    
    // MARK: - getAll()
    
    /// Tests getting all entries from an empty keychain.
    func testGetAllEmpty() {
        
        do {
            
            let results = try keychain?.getAll()
            XCTAssertNil(results)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }

    /// Tests getting all entries from a non-empty keychain.
    func testGetAllNotEmpty() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry1 = try CRDKeychainEntry(key: "key1")
            expectedEntry1.account = "account1"
            expectedEntry1.label = "label1"
            expectedEntry1.desc = "this is the description"
            expectedEntry1.notes = "this is the comment"
            expectedEntry1.secret = "this is the data".data(using: .utf8)

            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry1)

            // Create a new keychain entry to add to the keychain.
            let expectedEntry2 = try CRDKeychainEntry(key: "key2")
            expectedEntry2.account = "account2"
            expectedEntry2.label = "label2"
            expectedEntry2.desc = "this is the description2"
            expectedEntry2.notes = "this is the comment2"
            expectedEntry2.secret = "this is the data2".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry2)

            // Get all the items - we should have two
            let results = try keychain?.getAll()
            XCTAssertNotNil(results)
            XCTAssertEqual(results?.count, 2)

            // Check the results
            XCTAssertEqual(results![0], expectedEntry1)
            XCTAssertEqual(results![1], expectedEntry2)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }

    // MARK: - remove()
    
    /// Tests removing an entry that exists in the keychain.
    func testRemoveFound() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry1 = try CRDKeychainEntry(key: "key1")
            expectedEntry1.account = "account1"
            expectedEntry1.label = "label1"
            expectedEntry1.desc = "this is the description"
            expectedEntry1.notes = "this is the comment"
            expectedEntry1.secret = "this is the data".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry1)
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry2 = try CRDKeychainEntry(key: "key2")
            expectedEntry2.account = "account2"
            expectedEntry2.label = "label2"
            expectedEntry2.desc = "this is the description2"
            expectedEntry2.notes = "this is the comment2"
            expectedEntry2.secret = "this is the data2".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry2)
            
            // Remove the second one added
            try keychain?.remove(key: expectedEntry2.key)
            
            // Get all the items - we should have one
            let results = try keychain?.getAll()
            XCTAssertNotNil(results)
            XCTAssertEqual(results?.count, 1)
            
            // Check the results - there should be a match to the first one added only.
            XCTAssertEqual(results![0], expectedEntry1)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }

    /// Tests removing a non-existant entry from a non-empty keychain.
    func testRemoveNotFound() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry1 = try CRDKeychainEntry(key: "key1")
            expectedEntry1.account = "account1"
            expectedEntry1.label = "label1"
            expectedEntry1.desc = "this is the description"
            expectedEntry1.notes = "this is the comment"
            expectedEntry1.secret = "this is the data".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry1)
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry2 = try CRDKeychainEntry(key: "key2")
            expectedEntry2.account = "account2"
            expectedEntry2.label = "label2"
            expectedEntry2.desc = "this is the description2"
            expectedEntry2.notes = "this is the comment2"
            expectedEntry2.secret = "this is the data2".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry2)
            
            // Remove non-existant key
            try keychain?.remove(key: "blippo")
            
            // Get all the items - we should have one
            let results = try keychain?.getAll()
            XCTAssertNotNil(results)
            XCTAssertEqual(results?.count, 2)
            
            // Check the results
            XCTAssertEqual(results![0], expectedEntry1)
            XCTAssertEqual(results![1], expectedEntry2)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }

    /// Tests removing a non-existent entry from an empty keychain.
    func testRemoveNotFoundEmpty() {
        
        do {
            
            // Remove non-existant key from empty keychain
            try keychain?.remove(key: "blippo")
            
            // Get all the items - we should have none
            let results = try keychain?.getAll()
            XCTAssertNil(results)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
    
    // MARK: - removeAll()
    
    func testRemoveAllEmptyKeychain() {
        
        do {
            
            // Remove all from empty keychain
            try keychain?.removeAll()
            
            // Get all the items - we should have none
            let results = try keychain?.getAll()
            XCTAssertNil(results)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
    
    func testRemoveAllNonEmptyKeychain() {
        
        do {
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry1 = try CRDKeychainEntry(key: "key1")
            expectedEntry1.account = "account1"
            expectedEntry1.label = "label1"
            expectedEntry1.desc = "this is the description"
            expectedEntry1.notes = "this is the comment"
            expectedEntry1.secret = "this is the data".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry1)
            
            // Create a new keychain entry to add to the keychain.
            let expectedEntry2 = try CRDKeychainEntry(key: "key2")
            expectedEntry2.account = "account2"
            expectedEntry2.label = "label2"
            expectedEntry2.desc = "this is the description2"
            expectedEntry2.notes = "this is the comment2"
            expectedEntry2.secret = "this is the data2".data(using: .utf8)
            
            // Add our new entry to the keychain.
            try keychain?.set(entry: expectedEntry2)

            // Get all the items - we should have two
            let results = try keychain?.getAll()
            XCTAssertNotNil(results)
            XCTAssertEqual(results?.count, 2)
            
            // Check the results
            XCTAssertEqual(results![0], expectedEntry1)
            XCTAssertEqual(results![1], expectedEntry2)

            // Remove all
            try keychain?.removeAll()

            // Get all the items - we should have none
            let results2 = try keychain?.getAll()
            XCTAssertNil(results2)

        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
}
