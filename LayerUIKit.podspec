#
# Be sure to run `pod lib lint LayerUIKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LayerUIKit"
  s.version          = "0.2.0"
  s.summary          = "A short description of LayerUIKit."
  s.license          = 'Apche'
  s.author           = { "Kevin Coleman" => "kevin@layer.com" }
  s.source           = { :git => "https://github.com/layerhq/LayerUIKit.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Code'
  s.ios.resource_bundle = {'LayerUIKitResource' => 'Resources/*'}

  s.ios.frameworks = 'UIKit'
  s.ios.deployment_target = '7.0'

  #s.dependency 'LayerKit', '~> 0.9.0'
end
