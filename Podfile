# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MatrixClient' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MatrixClient
  pod 'OLMKit'
  pod 'Realm'
#  pod 'MatrixSDK', :path => '../matrix-ios-sdk'
  pod 'MatrixSDK', :git => 'https://github.com/aapierce0/matrix-ios-sdk.git', :commit => '01b7da359f526ffe2a7e5a6a6f0ee99c1cacd94a'

  target 'MatrixClientTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

