//
//  PhotoLibraryViewController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoLibraryViewController.h"
#import "PhotoLibraryLoader.h"
#import <Photos/Photos.h>
#import "Constants.h"
#import "MediaItem.h"
#import "Masonry.h"

@interface PhotoLibraryViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) PhotoLibraryLoader* photoLibraryLoader;
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) dispatch_queue_t photoQueue;
@property (nonatomic) UIButton* scrollCameraButton;
@property (nonatomic) NSMutableArray* mediaItems;
@property (nonatomic) UIButton* cameraButton;
@property (nonatomic) UIView* backgroundView;
@property (nonatomic) UIButton* exitButton;

@end

@implementation PhotoLibraryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // check status
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        
        [self setupCollectionView];
        
        [_photoLibraryLoader getImages:^(NSMutableArray* mediaItems, NSError* error) {
            
            _mediaItems = mediaItems;
            [_collectionView reloadData];
        }];
    } else {
        
        [self settupBackgroundView];
    }
    
    [self setupButton];
}

#pragma mark - setupCollectionView

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake((self.view.frame.size.width-15)/3, (self.view.frame.size.width-15)/3);
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView setBounces:YES];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:_collectionView];
    
    _photoLibraryLoader = [PhotoLibraryLoader sharedInstance];
    _photoQueue = dispatch_queue_create("PHOTO_QUEUE", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - setupButton

- (void)setupButton {

    [self setupScrollCameraButton];
}

#pragma mark - ConfigData

- (void)ConfigData {
    
    [self setupCollectionView];
    
    [_photoLibraryLoader checkPermission:^(NSError* error) {
        
        if((error.code == PHAuStatusDenied) || (error.code == PHAuStatusRestricted)) {
            
            [[[UIAlertView alloc] initWithTitle:@"This app requires access to your Galary to function properly." message: @"Please! Go to setting!" delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"GO TO SETTING", nil] show];
        } else {
            
            [_photoLibraryLoader getImages:^(NSMutableArray* mediaItems, NSError* error) {
                
                _mediaItems = mediaItems;
                [_backgroundView removeFromSuperview];
                [_collectionView reloadData];
            }];
        }
    }];
}

#pragma mark - settupBackgroundView

- (void)settupBackgroundView {
    
    _backgroundView = [[UIView alloc] init];
    [_backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview: _backgroundView];
    
    // config label
    UILabel* label  = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:36]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 2;
    label.text = @"Gửi ảnh và video từ cuộn Camera";
    [_backgroundView addSubview:label];
    
    UIButton* permissionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [permissionButton setBackgroundColor:[UIColor clearColor]];
    [permissionButton setTitle:@"Cho phép truy cập ảnh" forState:UIControlStateNormal];
    [permissionButton addTarget:self action:@selector(checkPhotoLibraryPermission:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:permissionButton];
    
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.edges.equalTo(self.view);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.center.equalTo(_backgroundView);
        make.width.lessThanOrEqualTo(_backgroundView.mas_width);
    }];
    
    [permissionButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(_backgroundView);
        make.top.equalTo(label.mas_bottom).offset(30);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - setupScrollCameraButton

- (void)setupScrollCameraButton {
    
    _scrollCameraButton = [[UIButton alloc] init];
    [_scrollCameraButton setBackgroundColor:[UIColor clearColor]];
    [_scrollCameraButton setTitle:@"Cuộn Camera" forState:UIControlStateNormal];
    [self.view addSubview: _scrollCameraButton];
    
    [_scrollCameraButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
    }];
}

#pragma mark - checkPermission

- (IBAction)checkPhotoLibraryPermission:(id)sender {
    
    [self ConfigData];
}

#pragma mark - collectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _mediaItems.count;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaItem* mediaItem = _mediaItems[indexPath.row];
    NSString* assetLibraryPath = mediaItem.identifier;
    
    [self requestImageFromAsset:assetLibraryPath withIndex:indexPath with:^(UIImage* image, NSIndexPath* index) {
        
        if (index == indexPath) {
            
        }
    }];
}

#pragma mark - collectionView delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dog"]];
    
    MediaItem* mediaItem = _mediaItems[indexPath.row];
    NSString* assetLibraryPath = mediaItem.identifier;
    
    [self requestImageFromAsset:assetLibraryPath withIndex:indexPath with:^(UIImage* image, NSIndexPath* index) {
        
        if (index == indexPath) {
            
            cell.backgroundView = [[UIImageView alloc] initWithImage:image];
        }
    }];

    return cell;
}

#pragma mark - collectionView delegate

- (void)requestImageFromAsset:(NSString *)localIdentifier withIndex:(NSIndexPath *)index with:(void (^)(UIImage *,NSIndexPath* indexPath))completion {
    
    dispatch_sync(_photoQueue, ^ {
        
        PHFetchResult* savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
        [savedAssets enumerateObjectsUsingBlock:^(PHAsset* asset, NSUInteger idx, BOOL* stop) {
            
            PHImageRequestOptions* imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.synchronous = NO;
            imageRequestOptions.deliveryMode = PHImageRequestOptionsResizeModeFast;
            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
            imageRequestOptions.version = PHImageRequestOptionsVersionUnadjusted;
            
            [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                if (result) {
                    
                    UIImage* image = [self resizeImage:result];
                    
                    if (completion) {
                    
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            completion(image, index);
                        });
                    }
                } 
            }];
        }];
    });
}

#pragma mark - resize image

- (UIImage *)resizeImage:(UIImage *)image {
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    CGFloat edgeSquare = 100;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth > imageHeight) {
        
        CGFloat scaleRatio = edgeSquare / imageHeight;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(-(imageWidth - imageHeight) / 2, 0);
    } else {
        
        CGFloat scaleRatio = edgeSquare / imageWidth;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(imageHeight - imageWidth) / 2);
    }
    
    CGSize size = CGSizeMake(edgeSquare, edgeSquare);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
