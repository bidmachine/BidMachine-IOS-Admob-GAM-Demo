platform :ios, '10.0'
install! 'cocoapods', :deterministic_uuids => false, :warn_for_multiple_pod_sources => false

$BDMVersion = '~> 1.8.0.0'
$GAMVersion = '~> 8.13.0'

def bidmachine
  pod 'BDMIABAdapter', $BDMVersion
end

def google
  pod 'Google-Mobile-Ads-SDK', $GAMVersion
end

target 'BidMachineSample' do
  bidmachine
  google
end
