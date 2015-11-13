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
  s.name                = "URLTransaction"
  s.version             = "1.0"
  s.author              = { "DanKalinin" => "daniil5511@gmail.com" }
  s.license             = 'MIT'
  s.homepage            = "https://github.com/DanKalinin/URLTransaction"
  s.source              = { :git => "https://github.com/DanKalinin/URLTransaction.git", :tag => s.version.to_s }
  s.summary             = "Simple, but powerful iOS networking framework."
  s.description         = <<-DESC
                          URLTransaction library provides a convenient API to send single HTTP requests, group them into transactions and send them asynchronously. If one request in transaction fails - entire transaction fails.
                          Features:
                          * Convenient pattern to construct request using factory methods which allows to hold initialization and response mapping code in single class.
                          * Requests can be sent immediately after creation or added into transaction for sending them asynchronously.
                          * Request and transaction objects have three completion blocks which allows to handle responses in try-catch-finally manner:
                          * * success - called when response HTTP status code is 200.
                          * * failure - called either when HTTP status code of response is other than 200, network problems occured or request timeout expired.
                          * * completion - called anyway to notify that request is completed. Can be used to hide activity indicator or clean some allocated resources.
                          * Every completion block receives the current request object itself as parameter, thus source request can be processed within block without capturing and creating an external weak request pointer.
                          * URLRequest has an error property which can be accessed in failure block to determine the failure reason.
                          * Possibility of specifying a dispatch queue where completion blocks should be executed. This is usefull when comletion blocks are used for mapping response to Core Data entities or for any other expensive operation.
                          * After completion of asynchronous transaction, request completion blocks will be called in same order they were added into transaction. Finally, transaction completion blocks will be called. Request completion blocks can be used to map response body to Core Data entity. Transaction completion blocks can be used to establish relationships between mapped entities and save the context.
                          DESC

# Platform
  s.platform            = :ios, '7.0'

# Build settings
  s.requires_arc        = true
  s.framework           = 'UIKit'

# File patterns
  s.source_files        = 'Pod/Classes/**/*.{h,m}'
  s.public_header_files = 'Pod/Classes/**/*.h'

end
