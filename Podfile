platform :ios, '7.0'

# Import CocoaPods sources
source 'https://github.com/CocoaPods/Specs.git'

def import_common_pods
  pod 'LayerUIKit', path: '.'
  #pod 'LayerKit'
  pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git', branch: 'feature/APPS-774-External-Content'
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
