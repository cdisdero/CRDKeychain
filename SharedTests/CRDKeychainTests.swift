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
    
    var keychain: CRDKeychain? = nil
    
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
    
    func testGetAllEmpty() {
        
        do {
            
            let results = try keychain?.getAll()
            XCTAssertNil(results)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }

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

    func testRemoveNotFoundEmpty() {
        
        do {
            
            // Remove non-existant key from empty keychain
            try keychain?.remove(key: "blippo")
            
            // Get all the items - we should have one
            let results = try keychain?.getAll()
            XCTAssertNil(results)
            
        } catch let error as NSError {
            
            XCTFail("\(error)")
        }
    }
}
