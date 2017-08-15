//
//  CheckCameraPermissionDelegate.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/15/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

@protocol CheckCameraPermissionDelegate <NSObject>

#pragma mark - cameraPermission
- (void)cameraPermission:(BOOL)isAllow;

@end
