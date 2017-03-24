# CRDKeychain [https://travis-ci.org/cdisdero/CRDKeychain.svg?branch=master]
Simple straightforward Swift-based keychain access framework for macOS and iOS
## Overview
I recently had a need to create a way to access the macOS and iOS keychain from within a Swift-based app I was developing.  Although there are several extensive libraries out there for this very purpose, I found that they were pretty complex and involved a lot of code.  I needed something that was small and compact and easy to add to any project.  I decided to create my own as a framework that will work in both macOS and iOS projects.
## Usage
You can use this library in your project by simply adding these files from the **Shared** folder to your macOS or iOS Swift project:

- CRDKeychain.swift
- CRDKeychainEntry.swift

To start using the keychain, you can access methods on the singleton:

`CRDKeychain.shared`

The shared singleton is automatically setup with your app's bundle identifier as the service name (`kSecAttrService`) for keychain entries and a security setting for entries (`kSecAttrAccessible`) of `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.

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

## Conclusion
I hope this small library/framework is helpful to you in your next Swift project.  I'll be updating as time and inclination permits and of course I welcome all your feedback.
