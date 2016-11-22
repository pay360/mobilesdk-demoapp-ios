source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

xcodeproj 'Merchant'

paypointVersion = '1.0.0'

target "Merchant" do
	if ENV['DEVENV'] == 'ci' 
		pod 'PayPointPayments',:git => 'ssh://git@stash.paypoint.net:7999/blu/mobilesdk-ios.git',:branch => 'master'
	elsif  ENV['DEVENV'] == 'ci-release'
        	pod 'PayPointPayments',:git =>'ssh://git@stash.paypoint.net:7999/blu/mobilesdk-ios.git', :tag=>paypointVersion 
	elsif ENV['DEVENV'] == 'local'
        	pod 'PayPointPayments', :path => '../mobilesdk-ios'
	else   
        	pod 'PayPointPayments',:git => 'https://github.com/paypoint/mobilesdk-ios.git', :tag => paypointVersion 
	end  
end
