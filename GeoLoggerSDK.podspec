#
# Be sure to run `pod lib lint GeoLogger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GeoLoggerSDK'
  s.version          = '1.0.0'
  s.summary          = 'A package to log location events.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A package to log location events.
  DESC

  s.homepage         = 'https://github.com/nishiths23/GeoLogger'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nishiths23' => 'nishithsingh23@ymail.com' }
  s.source           = { :git => 'https://github.com/nishiths23/GeoLogger.git', :tag => '1.0.0' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.4'
  s.osx.deployment_target = '11.0'

  s.source_files = 'GeoLogger/Classes/Sources/**/*'
  
  # s.resource_bundles = {
  #   'GeoLogger' => ['GeoLogger/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'XCTest'
  s.dependency 'Hippolyte'
  s.dependency "Realm"
  s.dependency 'RealmSwift'
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'GeoLogger/Classes/Tests/**/*'
      test_spec.frameworks = 'XCTest'
      test_spec.dependency 'RealmSwift'
  end
end
