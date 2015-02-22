platform :ios, '7.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'Programmatic' do
  pod 'Atlas', path: '.'
end

target 'Storyboard' do
  pod 'Atlas', path: '.'
end

def import_ui_testing_pods
  pod 'KIFViewControllerActions', git: 'git@github.com:blakewatters/KIFViewControllerActions.git'
  pod 'LYRCountDownLatch', git: 'git@github.com:layerhq/LYRCountDownLatch.git'
  pod 'KIF'
  pod 'Expecta'
  pod 'OCMock'
end

target 'ProgrammaticTests' do
  import_ui_testing_pods
end

target 'StoryboardTests' do
  import_ui_testing_pods
end

target 'UnitTests' do
  pod 'Expecta'
  pod 'OCMock'
end
