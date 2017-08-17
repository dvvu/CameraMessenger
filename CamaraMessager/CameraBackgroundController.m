//
//  CameraBackgroundController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/8/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CameraBackgroundController.h"
#import "GlobalVars.h"
#import "Constants.h"

@interface CameraBackgroundController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UIViewController* parentController;
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) CGPoint cellClickedPoint;
@property (nonatomic) UIView* borderCellView;
@property (nonatomic) GlobalVars* globals;

@end

@implementation CameraBackgroundController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView andParentViewController:(UIViewController *)parentViewController {
   
    if (self = [super init]) {
        
        [self initCollectionView:collectionView];
        _parentController = parentViewController;
        _globals = [GlobalVars sharedInstance];
    }
    return self;
}

#pragma mark - init with

- (void)initCollectionView:(UICollectionView *)collectionView {
    
    _collectionView = collectionView;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    _borderCellView = [[UIView alloc] init];
    _borderCellView.backgroundColor = [UIColor clearColor];
    _borderCellView.layer.cornerRadius = 6;
    _borderCellView.layer.borderWidth = 1.0f;
    _borderCellView.layer.borderColor = [UIColor whiteColor].CGColor;
}

#pragma mark - collectionView dataSurce

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

#pragma mark - collectionView dataSurce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _imageNames.count;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage* image = [UIImage imageNamed:_imageNames[indexPath.row]];
    
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    CGPoint point = [cell convertPoint:cell.center toView:nil];
    
    _cellClickedPoint.y = point.y;
    _cellClickedPoint.x = _collectionView.contentOffset.x;
    
    // current click in collectionType is this collectionView?
    if (_collectionViewType == _globals.currentCollectionViewType) {
        
        if (!_globals.selectedIndexpath) {
            
            _globals.selectedIndexpath = indexPath;
            [_animationDelegate showCollectionViewDelegate:image withType:_type andPosition:_cellClickedPoint];
        } else {
            
            if (_globals.selectedIndexpath.row != indexPath.row && _globals.selectedIndexpath.section != indexPath.section) {
                
                _globals.selectedIndexpath = indexPath;
                [_animationDelegate showCollectionViewDelegate:image withType:_type andPosition:_cellClickedPoint];
            } else {
                
                if (_globals.selectedIndexpath == nil) {
                    
                    _globals.selectedIndexpath = indexPath;
                } else {
                    
                    _globals.selectedIndexpath = nil;
                }
                
                [_animationDelegate showCollectionViewDelegate:nil withType:_type andPosition:_cellClickedPoint];
            }
        }
    } else {
       
        _globals.currentCollectionViewType = _collectionViewType;
        _globals.selectedIndexpath = indexPath;
        
        [_animationDelegate showCollectionViewDelegate:image withType:_type andPosition:_cellClickedPoint];
    }
}

#pragma mark - collectionView dataSurce

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
 
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imageNames[indexPath.row]]];
    cell.backgroundView.layer.masksToBounds = YES;
    cell.backgroundView.layer.cornerRadius = 6;
    [cell.backgroundView setBackgroundColor:[UIColor grayColor]];
    cell.backgroundView.alpha = 0.8f;
    
    return cell;
}

#pragma mark - collectionView layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionViewWidth, collectionViewHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    _cellClickedPoint.x = scrollView.contentOffset.x;
}

@end
