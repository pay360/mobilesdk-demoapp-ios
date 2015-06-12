source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

xcodeproj 'Merchant'
#pod 'PayPointPayments',:local => '../mobilesdk-ios'

paypointVersion = '1.0.0-rc1'

if ENV['DEVENV'] == 'ci' 
	pod 'PayPointPayments',:git => 'https://stash.paypoint.net/scm/blu/mobilesdk-ios.git',:branch => 'master'
elsif ENV['DEVENV'] == 'local'
        pod 'PayPointPayments', :path => '../mobilesdk-ios'
else   
        pod 'PayPointPayments',:git => 'https://github.com/paypoint/mobilesdk-ios.git', :tag => paypointVersion 
end  

