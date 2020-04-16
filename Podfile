# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
source 'https://github.com/CocoaPods/Specs.git'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

# Disable warnings for all pods
inhibit_all_warnings!

def app_pods
  # Development Pods
  pod 'NetworkKit', :path => 'ModuleFrameworks/NetworkKit'

  # Internal Distribution
  pod 'AppCenter', '~> 3.0.0'

  # Upnetix/Scalefocus Libraries
  pod 'Flexx', '2.7.0'  # Localization
  pod 'PopupUpdate', '~> 1.0.2'     # Force Update
  pod 'TwoWayBondage', '~> 2.0.0'   # Observers

  # Firebase
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'

  # Text input
  pod 'IQKeyboardManager', '~> 6.5.5'
  pod 'SkyFloatingLabelTextField', '~> 3.0'

  # Secure store
  pod 'KeychainSwift'
  
  # Swiftlint
  pod 'SwiftLint', '~> 0.27.0'

  # Better quality icons
  pod 'FontAwesome.swift'
end

target 'Development' do
  app_pods
end

target 'Production' do
  app_pods
end

target 'NorthMacedonia' do
  app_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      if ['Alamofire', 'NetworkKit'].include? target.name
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.2'
          end
      end
  end
end
