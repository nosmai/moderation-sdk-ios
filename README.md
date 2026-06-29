# NosmaiModerationSDK (iOS)

On-device content moderation SDK for iOS — real-time image, video, and text
moderation (weapons, drugs, cigarettes, alcohol, NSFW, and toxic chat) running
fully offline on the Neural Engine. No frame or message leaves the device.

## Requirements

- iOS 15.1+
- A Nosmai license key (register your app's bundle id in the Nosmai portal)

## Installation

Add the pod to your `Podfile`:

```ruby
pod 'NosmaiModerationSDK', '~> 1.0'
```

Then run:

```bash
pod install
```

Open the generated `.xcworkspace` from now on. On Xcode 15 and later, set
**Build Settings → User Script Sandboxing (`ENABLE_USER_SCRIPT_SANDBOXING`) to
`No`** on your app target, so the CocoaPods resource-copy phase can run.

To apply that automatically, add this to your `Podfile`:

```ruby
post_install do |installer|
  installer.aggregate_targets.each do |aggregate|
    aggregate.user_project.native_targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
    aggregate.user_project.save
  end
end
```

### Info.plist

| Key | Value | Needed for |
| --- | --- | --- |
| `NSCameraUsageDescription` | Your usage string | Live camera moderation |
| `ITSAppUsesNonExemptEncryption` | `NO` | App Store submission |

## Quick start

```swift
import NosmaiDetection

// Initialize once at app start, on a background thread (the first call verifies
// the license online). Pass the models you need — a model you do not request is
// never loaded, so it costs no memory or startup time.
try NosmaiSDK.initialize(licenseKey: "NOSMAI-XXXX", models: [.objectDetection, .nsfw])

// Image moderation (call off the main thread)
if let result = NosmaiSDK.analyze(image) {
    // result.detections (objects) + result.nsfw (NSFW verdict)
}

// Real-time camera stream
NosmaiSDK.startStream(listener: self)
// from your AVCaptureVideoDataOutput delegate:
NosmaiSDK.pushFrame(pixelBuffer, rotationDegrees: 90)
```

### Text moderation

Text moderation loads a separate model and is initialized on demand:

```swift
try NosmaiSDK.initializeText()
let verdict = NosmaiSDK.moderateText("message to check")
```

## License

Proprietary. See [LICENSE](LICENSE). For licensing inquiries: support@nosmai.com
