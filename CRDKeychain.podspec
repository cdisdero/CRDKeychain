#
#  Be sure to run `pod spec lint CRDKeychain.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.swift_version = '5.0'
  s.name         = "CRDKeychain"
  s.version      = "1.0.8"
  s.summary      = "Simple straightforward Swift-based keychain access framework for iOS, macOS, watchOS, and tvOS"
  s.description  = <<-DESC
I recently had a need to create a way to access the Apple keychain from within a Swift-based app I was developing.  Although there are several comprehensive libraries out there for this very purpose, I found that they were fairly complex and involved a lot of code.  I needed something that was small and compact and easy to add to any project, just by dropping in a few files.  I decided to create my own as a cocoa framework and cocoapod that will work with a consistent interface across iOS, macOS, watchOS, and tvOS Swift-based projects.
DESC

  s.homepage     = "https://github.com/cdisdero/CRDKeychain"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.license      = "Apache License, Version 2.0"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.author             = { "Christopher Disdero" => "info@code.chrisdisdero.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "3.0"
  s.tvos.deployment_target = "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source       = { :git => "https://github.com/cdisdero/CRDKeychain.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

s.source_files  = "Shared/*.swift"
s.ios.source_files   = 'CRDKeychainMobile/*.h'
s.osx.source_files   = 'CRDKeychainMac/*.h'
s.watchos.source_files = 'CRDKeychainWatch/*.h'
s.tvos.source_files  = 'CRDKeychainTV/*.h'

end
