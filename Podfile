# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'NearbyInteraction-Sandbox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['LD_NO_PIE'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      
      # exclude x86 on m1
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end

pod 'Alamofire'

end
