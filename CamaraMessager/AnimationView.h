//
//  AnimationView.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/10/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "AnimationForCollectionViewDelegate.h"
#import <UIKit/UIKit.h>

@interface AnimationView : UIView

@property (nonatomic) id<AnimationForCollectionViewDelegate> animationDelegate;

@property (nonatomic) UIView* contentView;

#pragma mark - setup Layout
- (void)setupLayout;

#pragma mark - remove Layout
- (void)hideLayoutFromSupview;

@end
