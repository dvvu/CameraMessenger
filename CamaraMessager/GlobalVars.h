//
//  GlobalVars.h
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/16/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GlobalVars : NSObject

+ (GlobalVars *)sharedInstance;

@property(nonatomic) NSIndexPath* selectedIndexpath;
@property(nonatomic) CollectionViewType currentCollectionViewType;

@end
