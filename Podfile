platform :ios, '7.0'

source 'git@github.com:layerhq/cocoapods-specs.git'

# Import CocoaPods sources
source 'https://github.com/CocoaPods/Specs.git'

target 'Programmatic' do
  pod 'Atlas', path: '.'
  pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git', branch: 'feature/APPS-1025-conversation-uniquing'
end

target 'Storyboard' do
  pod 'Atlas', path: '.'
  pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git', branch: 'feature/APPS-1025-conversation-uniquing'
end

target 'ProgrammaticTests' do
  pod 'KIFViewControllerActions', git: 'https://github.com/blakewatters/KIFViewControllerActions.git'
  pod 'LYRCountDownLatch', git: 'https://github.com/layerhq/LYRCountDownLatch.git'
  pod 'KIF'
  pod 'Expecta'
  pod 'OCMock'
end

target 'StoryboardTests' do
  pod 'KIFViewControllerActions', git: 'https://github.com/blakewatters/KIFViewControllerActions.git'
  pod 'LYRCountDownLatch', git: 'https://github.com/layerhq/LYRCountDownLatch.git'
  pod 'KIF'
  pod 'Expecta'
  pod 'OCMock'
end

target 'UnitTests' do
  pod 'Expecta'
  pod 'OCMock'
end
