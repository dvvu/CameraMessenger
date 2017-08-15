//
//  CamaraViewController.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CheckCameraPermissionDelegate.h"
#import <UIKit/UIKit.h>

@interface CamaraViewController : UIViewController

@property (nonatomic) id<CheckCameraPermissionDelegate> cameraDelegate;

#pragma mark - captureAction
- (void)captureAction;

#pragma mark - changeCameraDirection
- (void)changeCameraDirection;

@end
