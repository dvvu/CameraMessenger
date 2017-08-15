//
//  AnimationForCollectionViewDelegate.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/14/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AnimationForCollectionViewDelegate <NSObject>

#pragma mark - showCollectionView
- (void)showCollectionViewDelegate:(UIImage *)image withPosition:(CGPoint)point;

#pragma mark - showButton
- (void)showButton;

@end
