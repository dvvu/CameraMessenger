//
//  GestureRecognizeDelegate.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/14/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GestureRecognizeDelegate <NSObject>

#pragma mark - hideCollectionView
- (void)gesturn:(BOOL)isGuesture;

@end
