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

  s.name         = "CRDKeychain"
  s.version      = "1.0.2"
  s.summary      = "Simple straightforward Swift-based keychain access framework for macOS and iOS"
  s.description  = <<-DESC
I recently had a need to create a way to access the macOS and iOS keychain from within a Swift-based app I was developing.  Although there are several comprehensive libraries out there for this very purpose, I found that they were fairly complex and involved a lot of code.  I needed something that was small and compact and easy to add to any project, just by dropping in a few files.  I decided to create my own as a cocoa framework and cocoapod that will work in both macOS and iOS Swift-based projects.
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
  s.osx.deployment_target = "10.11"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source       = { :git => "https://github.com/cdisdero/CRDKeychain.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.source_files  = "Shared/*.swift"

end
