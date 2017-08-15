//
//  CameraBackgroundController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/8/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CameraBackgroundController.h"
#import "Constants.h"

@interface CameraBackgroundController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) UIViewController* parentController;

@end

@implementation CameraBackgroundController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView andParentViewController:(UIViewController *)parentViewController {
   
    if (self = [super init]) {
        
        [self initCollectionView:collectionView];
        _parentController = parentViewController;
    }
    return self;
}

#pragma mark - init with

- (void)initCollectionView:(UICollectionView *)collectionView {
    
    _collectionView = collectionView;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

#pragma mark - collectionView dataSurce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 9;
}

#pragma mark - collectionView dataSurce

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString* imageName = [@"background_" stringByAppendingFormat:@"%d",(indexPath.row + 1)];
    UIImage* image = [UIImage imageNamed:imageName];
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    CGPoint point = [cell convertPoint:cell.center toView:nil];
    
    [_animationDelegate showCollectionViewDelegate:image withPosition:point];
}

#pragma mark - collectionView dataSurce

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSString* imageName = [@"background_" stringByAppendingFormat:@"%d",(indexPath.row + 1)];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    cell.backgroundView.layer.masksToBounds = YES;
    cell.backgroundView.layer.cornerRadius = 6;
    [cell.backgroundView setBackgroundColor:[UIColor whiteColor]];
    cell.backgroundView.alpha = 1.0f;
    
    UIView* bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    bgColorView.layer.cornerRadius = 6;
    bgColorView.layer.borderWidth = 1.0f;
    bgColorView.layer.borderColor = [UIColor redColor].CGColor;
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

#pragma mark - collectionView layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionViewWidth, collectionViewHeight);
}

@end
