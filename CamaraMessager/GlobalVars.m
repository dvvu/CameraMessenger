//
//  GlobalVars.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/16/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars

+ (GlobalVars *)sharedInstance {
    
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
   
    dispatch_once(&onceToken, ^{
    
        instance = [[GlobalVars alloc] init];
    });
    
    return instance;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
       
        _selectedIndexpath = nil;
    }
    
    return self;
}

@end
