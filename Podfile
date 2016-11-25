source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

xcodeproj 'Merchant'
#target "Merchant" do
#	pod 'Pay360Payments',:local => '../mobilesdk-ios'
#end

pay360Version = '2.0.0'

target "Merchant" do
	if ENV['DEVENV'] == 'ci' 
		pod 'Pay360Payments',:git => 'ssh://git@stash.paypoint.net:7999/blu/mobilesdk-ios.git',:branch => 'master'
	elsif  ENV['DEVENV'] == 'ci-release'
        	pod 'Pay360Payments',:git =>'ssh://git@stash.paypoint.net:7999/blu/mobilesdk-ios.git', :tag=>pay360Version 
	elsif ENV['DEVENV'] == 'local'
        	pod 'Pay360Payments', :path => '../mobilesdk-ios'
	else   
        	pod 'Pay360Payments',:git => 'https://github.com/pay360/mobilesdk-ios.git', :tag => pay360Version 
	end  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '7.0'
    end
  end
end
