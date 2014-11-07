platform :ios, '7.0'
workspace 'LayerUIKit.xcworkspace'

# Import CocoaPods sources
source 'git@github.com:layerhq/cocoapods-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

def import_common_pods
  xcodeproj 'LayerUIKit.xcodeproj'
  #pod 'LayerUIKit', path: '.'
  pod 'LayerKit', '~> 0.8.7'
  #pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git'
end

def import_testing_pods
  pod 'KIF'
  pod 'Expecta'
  pod 'OCMock'
end

target 'Unit Tests' do
  import_testing_pods
  import_common_pods
end

target 'Conversation' do
  import_common_pods
end
