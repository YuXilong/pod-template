//
//  CPDSceneDelegate.h
//  PROJECT
//
//  Created by yuxilong on 2026/09/16.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/// Owns the example UI; add foreground/background handling to this scene delegate.
@interface CPDSceneDelegate : UIResponder <UIWindowSceneDelegate>

/// UIKit creates this window from the scene's Main storyboard in Info.plist.
@property(nonatomic, strong, nullable) UIWindow *window;

@end

NS_ASSUME_NONNULL_END
