//
//  Constants.h
//  NimbusExample
//
//  Created by Doan Van Vu on 6/28/17.
//  Copyright © 2017 Vu Doan. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#endif /* Constants_h */

#pragma mark - contacts Authorizatio Status

#define headerTableViewHeight 25
#define searchBarheight 35
#define collectionViewHeight 130
#define collectionViewWidth 90
#define cameraButtonBottomSpace 15
#define capturnCameraButtonHeight 80
#define headerHeight 118
#define maximumBlurView 0.75
#define cameraTableHeaderHeight 80

typedef enum {
    
    PHAuStatusDenied = 1,
    PHAuStatusRestricted = 2,
} PHAuStatus;

typedef enum {
    
    PhotoLibraryController = 0,
    CameraController = 1,
    TextController = 2,
} ViewControllerType;
