#
# Be sure to run `pod lib lint LayerUIKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                        = "LayerUIKit"
  s.version                     = "0.2.0"
  s.summary                     = "A short description of LayerUIKit."
  s.license                     = 'Apache'
  s.author                      = { 'Blake Watters'   => 'blake@layer.com',
                                    'Ben Blakely'     => 'ben@layer.com',
                                    'Klemen Verdnik'  => 'klemen@layer.com',
                                    'Kevin Coleman'   => 'kevin@layer.com'  }
  s.source                      = { :git => "https://github.com/layerhq/LayerUIKit.git", :tag => s.version.to_s }
  s.platform                    = :ios, '7.0'
  s.requires_arc                = true
  s.source_files                = 'Code/**/*.{h,m}'
  s.ios.resource_bundle         = {'LayerUIKitResource' => 'Resources/*'}
  s.header_mappings_dir         = 'Code'
  s.ios.frameworks              = 'UIKit, CoreLocation, MobileCoreServices, '
  s.ios.deployment_target       = '7.0'
  #s.dependency                    'LayerKit'
end
