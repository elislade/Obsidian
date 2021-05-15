# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Obsidian' do
  use_frameworks!

  # Pods for Obsidian
    pod 'Locksmith'
    # pod 'Firebase/Core'
    # pod 'Fabric', '~> 1.7.6'
    # pod 'Crashlytics', '~> 3.10.1'
    pod 'QuestAPI', :git => 'https://github.com/elislade/questapi.git'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
