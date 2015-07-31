#
# Be sure to run `pod lib lint URLTransaction.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

# Root specification
  s.name             = "URLTransaction"
  s.version          = "0.1.0"
  s.summary          = "Simple, but powerful iOS networking framework."
  s.homepage         = "https://github.com/DanKalinin/URLTransaction"
  s.license          = 'MIT'
  s.author           = { "DanKalinin" => "daniil5511@gmail.com" }
  s.source           = { :git => "https://github.com/DanKalinin/URLTransaction.git", :tag => s.version.to_s }

# Platform
  s.platform     = :ios, '7.0'

# Build settings
  s.requires_arc = true
  s.framework = 'UIKit'

# File patterns
  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.public_header_files = 'Pod/Classes/**/*.h'

end
