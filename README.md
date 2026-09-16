pod-template
============

An opinionated template for creating a Pod with the following features:

- Git as the source control management system
- Clean folder structure
- Project generation
- MIT license
- Testing as a standard
- Turnkey access to Travis CI
- Also supports Carthage

## Getting started

There are two reasons for wanting to work on this template, making your own or improving the one for everyone's. In both cases you will want to work with the ruby classes inside the `setup` folder, and the example base template that it works on from inside `template/ios/`. 

## Best practices

The command `pod lib create` aims to be ran along with this guide: https://guides.cocoapods.org/making/using-pod-lib-create.html so any changes of flow should be updated there also.

It is open to communal input, but adding new features, or new ideas are probably better off being discussed in an issue first. In general we try to think if an average Xcode user is going to use this feature or not, if it's unlikely is it a _very strongly_ encouraged best practice ( ala testing / CI. ) If it's something useful for saving a few minutes every deploy, or isn't easily documented in the guide it is likely to be denied in order to keep this project as simple as possible.

## Requirements:

- CocoaPods 1.0.0+
- Generated iOS pods and example apps require iOS 15.0+.

## iOS app lifecycle

Both Objective-C and Swift examples use the [UIKit scene lifecycle](https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle)
required when building with the iOS 27 SDK. `Info.plist` configures a single `UIWindowScene` and
UIKit creates its window from `Main.storyboard`. Add UI lifecycle handling (such
as `sceneDidBecomeActive` and `sceneDidEnterBackground`) to `SceneDelegate`; keep
application-wide initialization in `AppDelegate`.

Run `ruby setup/tests/scene_templates_test.rb` to check scene configuration,
generated file references, and minimum iOS versions for both templates.
