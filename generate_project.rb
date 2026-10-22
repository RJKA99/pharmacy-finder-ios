#!/usr/bin/env ruby
# Generates PharmacyFinder.xcodeproj using the `xcodeproj` gem (the library
# CocoaPods itself is built on) instead of xcodegen/Tuist, because neither of
# those can be installed on this machine (both require a full Xcode.app to
# build from source, which this machine - no Xcode, CLT only, macOS 13 - does
# not have). `xcodeproj` is a pure Ruby library and only needs system Ruby.
#
# Re-run after adding/removing source files or changing build settings:
#   gem install xcodeproj
#   ruby generate_project.rb

require "xcodeproj"

PROJECT_PATH = "PharmacyFinder.xcodeproj"
APP_TARGET_NAME = "PharmacyFinder"
BUNDLE_ID = "com.robinkarlsson.pharmacyfinder"
DEPLOYMENT_TARGET = "17.0"

project = Xcodeproj::Project.new(PROJECT_PATH)

target = project.new_target(:application, APP_TARGET_NAME, :ios, DEPLOYMENT_TARGET, nil, :swift)

# --- Source files -----------------------------------------------------
app_group = project.main_group.new_group(APP_TARGET_NAME, APP_TARGET_NAME)
Dir.glob("#{APP_TARGET_NAME}/*.swift").sort.each do |path|
  file_ref = app_group.new_reference(File.basename(path))
  target.source_build_phase.add_file_reference(file_ref)
end

# --- Local Swift package dependency (PharmacyKit) ----------------------
package_ref = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
package_ref.relative_path = "PharmacyKit"
project.root_object.package_references << package_ref

product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product_dep.package = package_ref
product_dep.product_name = "PharmacyKit"
target.package_product_dependencies << product_dep

build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build_file.product_ref = product_dep
target.frameworks_build_phase.files << build_file

# --- Build settings ------------------------------------------------------
target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = BUNDLE_ID
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = DEPLOYMENT_TARGET
  config.build_settings["SWIFT_VERSION"] = "5.0"
  config.build_settings["TARGETED_DEVICE_FAMILY"] = "1" # iPhone only
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  config.build_settings["INFOPLIST_KEY_UIApplicationSceneManifest_Generation"] = "YES"
  config.build_settings["INFOPLIST_KEY_UILaunchScreen_Generation"] = "YES"
  config.build_settings["INFOPLIST_KEY_NSLocationWhenInUseUsageDescription"] =
    "Pharmacy Finder uses your location to find the pharmacies nearest to you."
  config.build_settings["CODE_SIGN_STYLE"] = "Automatic"
  config.build_settings["ENABLE_PREVIEWS"] = "YES"
  config.build_settings["SWIFT_EMIT_LOC_STRINGS"] = "YES"
end

project.save

# --- Shared scheme (so `xcodebuild -scheme PharmacyFinder` works in CI
# without an interactive Xcode session to auto-generate one) -------------
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.set_launch_target(target)
scheme.save_as(PROJECT_PATH, APP_TARGET_NAME, true)

puts "Generated #{PROJECT_PATH} with target '#{APP_TARGET_NAME}' (iOS #{DEPLOYMENT_TARGET}+), " \
     "linking local package 'PharmacyKit', with a shared scheme."
