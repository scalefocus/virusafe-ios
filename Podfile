# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.upnetix.com/scm/il/podspecrepo.git'

target 'COVID-19' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'NetworkKit'                     , :path => 'ModuleFrameworks/NetworkKit'
  pod 'TwoWayBondage', '~> 1.0.2'
  pod 'AppCenter', '~> 3.0.0'

  pod 'PopupUpdate'
  pod 'Firebase/Analytics'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'

  pod 'Pulsator'

  pod 'IQKeyboardManager'
  pod 'SkyFloatingLabelTextField', '~> 3.0'

  pod 'KeychainSwift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      if ['Alamofire', 'CryptoSwift', 'NetworkKit'].include? target.name
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.2'
          end
      end
  end
end
