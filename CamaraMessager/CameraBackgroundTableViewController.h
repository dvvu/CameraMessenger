//
//  CameraBackgroundTableViewController.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/14/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "AnimationForCollectionViewDelegate.h"
#import "GestureRecognizeDelegate.h"
#import <Foundation/Foundation.h>

@interface CameraBackgroundTableViewController : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView withDelegate:(id)animationDelegate;

@property (nonatomic) id<AnimationForCollectionViewDelegate> animationDelegate;
@property (nonatomic) id<GestureRecognizeDelegate> guestureDelegate;

@end
