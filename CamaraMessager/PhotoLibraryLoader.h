//
//  PhotoLibraryLoader.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/7/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoLibraryLoader : NSObject

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - get permission
- (void)checkPermission:(void(^)(NSError* error))completion;

#pragma mark - get media
- (void)getImages:(void (^)(NSMutableArray* mediaItems,NSError* error))completion;

@end
