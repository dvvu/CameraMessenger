//
//  CameraBackgroundController.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/8/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "AnimationForCollectionViewDelegate.h"
#import <Foundation/Foundation.h>
#import "Constants.h"

@interface CameraBackgroundController : NSObject

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView andParentViewController:(UIViewController *)parentViewController;

@property (nonatomic) id<AnimationForCollectionViewDelegate> animationDelegate;
@property (nonatomic) CollectionViewType type;
@property (nonatomic) NSArray* imageNames;

@end
