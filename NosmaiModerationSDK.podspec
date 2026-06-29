Pod::Spec.new do |s|
  s.name             = 'NosmaiModerationSDK'
  s.version          = '1.0.0'
  s.summary          = 'On-device content + text moderation for iOS — image, video, text and live camera.'
  s.description      = <<-DESC
    Nosmai Moderation is a closed-source iOS SDK for on-device content moderation:
    object detection (weapon / drug / cigarette / alcohol), NSFW classification, and
    chat text moderation. Runs fully offline — no frame or message leaves the device.

    Register a project in the Nosmai portal to obtain a license key, used to
    initialize the SDK.
  DESC
  s.homepage         = 'https://cocoapods.org/pods/NosmaiModerationSDK'
  s.license          = { :type => 'Proprietary', :text => 'See LICENSE file' }
  s.author           = { 'Nosmai' => 'admin@nosmai.com' }
  s.platform         = :ios, '14.0'

  # The release ZIP contains: NosmaiDetection.xcframework, onnxruntime/<slice>/,
  # Models/, PrivacyInfo.xcprivacy, LICENSE  (see package.sh).
  s.source           = { :http => 'https://github.com/nosmai/moderation-sdk-ios/releases/download/1.0.0/NosmaiModerationSDK.zip' }

  # The prebuilt static-library xcframework + ONNX Runtime static lib ship as
  # preserved paths and are linked manually below (a static-library xcframework
  # can't be a vendored_framework — CocoaPods generates broken -l/search-path
  # flags for it, issues #10165 / #10071).
  s.preserve_paths = 'NosmaiDetection.xcframework/**/*', 'onnxruntime/**/*'

  # Encrypted models the SDK loads at runtime (decrypted in memory) + the Apple
  # privacy manifest (required-reason APIs).
  s.resources        = 'Models/*'
  s.resource_bundles = { 'NosmaiModerationSDK_privacy' => ['PrivacyInfo.xcprivacy'] }

  s.static_framework = true
  s.frameworks = 'CoreML', 'Vision', 'CoreVideo', 'Accelerate',
                 'AVFoundation', 'CoreMedia', 'CoreGraphics'

  fw = '$(PODS_TARGET_SRCROOT)'
  s.pod_target_xcconfig = {
    # The simulator slices are arm64-only (Apple-silicon Macs).
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
    'NOSMAI_SLICE[sdk=iphoneos*]'          => 'ios-arm64',
    'NOSMAI_SLICE[sdk=iphonesimulator*]'   => 'ios-arm64-simulator',
    # The SDK Clang module + headers live in the selected xcframework slice.
    'HEADER_SEARCH_PATHS' => "\"#{fw}/NosmaiDetection.xcframework/$(NOSMAI_SLICE)/Headers\"",
    'SWIFT_INCLUDE_PATHS' => "\"#{fw}/NosmaiDetection.xcframework/$(NOSMAI_SLICE)/Headers\"",
    # Link the merged SDK static lib, then force-load ONNX Runtime (it supplies
    # the single shared XNNPACK/cpuinfo copy, so there are no duplicate symbols).
    'OTHER_LDFLAGS' =>
      "$(inherited) -lc++ " \
      "-L\"#{fw}/NosmaiDetection.xcframework/$(NOSMAI_SLICE)\" -lNosmaiMerged " \
      "-force_load \"#{fw}/onnxruntime/$(NOSMAI_SLICE)/libonnxruntime.a\"",
  }
  s.swift_version = '5.0'
end
