source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

xcodeproj 'Merchant'
#pod 'Pay360Payments',:local => '../mobilesdk-ios'

pay360Version = '1.0.0-rc1'

if ENV['DEVENV'] == 'ci' 
	pod 'Pay360Payments',:git => 'ssh://git@stash.paypoint.net:7999/blu/mobilesdk-ios.git',:branch => 'master'
elsif  ENV['DEVENV'] == 'ci-release'
        pod 'Pay360Payments',:git =>'ssh://git@stash.paypoint.net:7999/blu/mobilesdk-ios.git', :tag=>pay360Version 
elsif ENV['DEVENV'] == 'local'
        pod 'Pay360Payments', :path => '../mobilesdk-ios'
else   
        pod 'Pay360Payments',:git => 'https://github.com/pay360/mobilesdk-ios.git', :tag => pay360Version 
end  

