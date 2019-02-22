# CRDKeychain
[![Build Status](https://travis-ci.org/cdisdero/CRDKeychain.svg?branch=master)](https://travis-ci.org/cdisdero/CRDKeychain)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/CRDKeychain.svg)](https://img.shields.io/cocoapods/v/CRDKeychain.svg)
[![Platform](https://img.shields.io/cocoapods/p/CRDKeychain.svg?style=flat)](http://cocoadocs.org/docsets/CRDKeychain)

Simple straightforward Swift-based keychain access framework for iOS, macOS, watchOS, and tvOS

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Conclusion](#conclusion)
- [License](#license)

## Overview
I recently had a need to create a way to access the Apple keychain from within a Swift-based app I was developing.  Although there are several comprehensive libraries out there for this very purpose, I found that they were fairly complex and involved a lot of code.  I needed something that was small and compact and easy to add to any project, just by dropping in a few files.  I decided to create my own as a cocoa framework and cocoapod that will work with a consistent interface across iOS, macOS, watchOS, and tvOS Swift-based projects.

## Requirements
- iOS 9.0+ / macOS 10.12+ / watchOS 3.0+ / tvOS 9.0+
- Xcode 10.1+
- Swift 4.0+

## Installation
You can use this code library in your project by simply adding these files from the **Shared** folder to your Swift project:

- CRDKeychain.swift
  * This file defines the CRDKeychain object and the methods for getting, setting, and removing entries from the keychain.

- CRDKeychainEntry.swift
  * This file defines the CRDKeychainEntry object which represents a keychain entry and it's various attributes. Methods in CRDKeychain use this object as the input or output.

- CRDKeychainError.swift
  * This file defines the errors that can be thrown from the `init()` and other methods in CRDKeychain.

- CRDKeychainEntryError.swift
  * This file defines the errors that can be thrown from the `init()` for CRDKeychainEntry.

### CocoaPods
Alternatively, you can install it as a Cocoapod

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build CRDKeychain.

To integrate CRDKeychain into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
pod 'CRDKeychain'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage
To start using the keychain, you can create a new instance of the `CRDKeychain` object which represents the app's keychain:

```
let keychain: CRDKeychain
do {

  keychain = try CRDKeychain()

} catch let error as NSError {

  print("\(error)")
}
```

The default initializer is automatically setup with your app's bundle identifier as the service name (`kSecAttrService`) for all the app keychain entries, nil keychain sharing access group name (`kSecAttrAccessGroup`), and a security setting for entries (`kSecAttrAccessible`) of `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.

You can pass in one or more of these values to the initializer to override the defaults.

### Methods
The following methods are available to interact with the keychain:

- `valueFor(key: String, includeData: Bool = false) throws -> CRDKeychainEntry?`
  * Gets the value for a given key and returns the data depending on the `includeData` flag.

- `public func exists(key: String) throws -> Bool`
  * Returns true if a keychain entry exists for the given key.

- `public func set(entry: CRDKeychainEntry) throws`
  * Adds or updates a keychain entry using the specified value.

- `public func getAll(includeData: Bool = false) throws -> [CRDKeychainEntry]?`
  * Gets all the keychain entries (with data if the flag is set) as an array.

- `public func remove(key: String) throws`
  * Removes the keychain entry specified by the key.

- `public func removeAll() throws`
  * Removes all the keychain entries.

### CRDKeychainEntry
The methods of CRDKeychain take in and return objects called CRDKeychainEntry objects which are basically just an object representing the properties of a keychain record - things like the account name, description, label, and of course the secret data part of the entry.  See `CRDKeychainEntry.swift` for the available properties and the corresponding keychain attributes they represent.

### Basic operations
To add a new keychain entry:

```
do {

  // Create a new keychain entry to add to the keychain.
  let expectedEntry = CRDKeychainEntry(key: "key1")
  expectedEntry.account = "account1"
  expectedEntry.label = "label1"
  expectedEntry.desc = "this is the description"
  expectedEntry.notes = "this is the comment"
  expectedEntry.secret = "this is the data".data(using: .utf8)

  // Add our new entry to the keychain.
  try keychain?.set(entry: expectedEntry)            

} catch let error as NSError {

  print("\(error)")
}
```

To get an existing entry from the keychain:

```
do {

  // Get the entry just added, including the data.
  var entryFound = try keychain?.valueFor(key: "key1", includeData: true)

} catch let error as NSError {

  print("\(error)")
}
```

To update an entry, just modify the attributes of an entry obtained by `valueFor` and call the `set` method passing the modified `CRDKeychainEntry`:

```
do {

  // Get the entry just added, including the data.
  var entryFound = try keychain?.valueFor(key: "key1", includeData: true)

  // Modify the entry
  entryFound.account = "account2"
  entryFound.label = "label2"
  entryFound.desc = "this is the modified description"
  entryFound.notes = "this is the modified comment"
  entryFound.secret = "this is the modified data".data(using: .utf8)

  // Save the modified entry, replacing the original in the keychain.
  try keychain?.set(entry: entryFound)

} catch let error as NSError {

  print("\(error)")
}
```

To remove an entry, just call the `remove` method with the key of the entry you wish to remove:

```
do {

  // Remove the entry previously modified.
  try keychain?.remove(key: "key1")

} catch let error as NSError {

  print("\(error)")
}
```

You can also use the `getAll(includeData: Bool = false)` method to retrieve all the entries in the keychain, if any, optionally including the data for each entry; the `removeAll()` method to remove all the entries; and `exists(key: String)` to test whether a key has an entry in the keychain.

The reason why `includeData` parameter is an option and defaults to false when getting entries from the keychain is that retrieving the data along with the attributes of an entry is a little slower than just retrieving the attributes. Typically you just want to get the attributes of entries only, such as when displaying some of the attributes in a table view or collection view. Retrieve the data only when you want to work with it directly.

Note that because `kSecAttrSynchronizable` is not available on watchOS, setting the `synchronizable` property of a CRDKeychainEntry object will have no effect on this platform.

## Conclusion
I hope this small library/framework is helpful to you in your next Swift project.  I'll be updating as time and inclination permits and of course I welcome all your feedback.

## License
CRDKeychain is released under an Apache 2.0 license. See LICENSE for details.
