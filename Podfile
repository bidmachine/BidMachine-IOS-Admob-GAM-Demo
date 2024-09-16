platform :ios, '12.0'

source 'https://github.com/appodeal/CocoaPods.git'
source 'https://cdn.cocoapods.org/'

install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false

$BDMVersion = '~> 3.0.1'
$GAMVersion = '~> 11.5.0'

def bidmachine
  pod 'BidMachine', $BDMVersion
end

def google
  pod 'Google-Mobile-Ads-SDK', $GAMVersion
end

target 'BidMachineSample' do
  bidmachine
  google
end

# Post install configuration
post_install do |installer|
  project = installer.pods_project
  project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
