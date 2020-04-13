# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
source 'https://github.com/CocoaPods/Specs.git'

#plugin 'cocoapods-keys', {
#  :project => "ViruSafe",
#  :keys => [
#  "FlexProdApiKey",
#  "FlexBGDevApiKey",
#  "FlexMKDevApiKey",
#  "ViruSafeApiKey"
#  ]
#}

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

def app_pods
  # Development Pods
  pod 'NetworkKit', :path => 'ModuleFrameworks/NetworkKit'

  # Internal Distribution
  pod 'AppCenter', '~> 3.0.0'

  # Upnetix/Scalefocus Libraries
  pod 'Flexx', '2.7.0'  # Localization
  pod 'PopupUpdate'     # Force Update
  pod 'TwoWayBondage'   # Observers

  # Firebase
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'

  # Text input
  pod 'IQKeyboardManager'
  pod 'SkyFloatingLabelTextField', '~> 3.0'

  # Secure store
  pod 'KeychainSwift'
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
