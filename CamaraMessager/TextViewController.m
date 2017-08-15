//
//  TextViewController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "TextViewController.h"
#import "Constants.h"
#import "Masonry.h"

@interface TextViewController ()

@property (nonatomic) UITextField* textField;

@end

@implementation TextViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:84/255.f green:162/255.f blue:214/255.f alpha:1.0f]];
   
    _textField = [[UITextField alloc]initWithFrame:self.view.frame];
    _textField.textAlignment = NSTextAlignmentCenter;
    [_textField setBackgroundColor:[UIColor clearColor]];
    [_textField setFont:[UIFont fontWithName:@"Helvetica Neue" size:27]];
    
    _textField.placeholder = @"Hãy viết gì đó";
    [self.view addSubview:_textField];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.center.equalTo(self.view);
        make.edges.equalTo(self.view);
    }];
}

@end
