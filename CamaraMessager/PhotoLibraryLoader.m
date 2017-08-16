//
//  PhotoLibraryLoader.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/7/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoLibraryLoader.h"
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "Constants.h"
#import "MediaItem.h"

@interface PhotoLibraryLoader ()

@property (nonatomic) NSMutableArray* mediaInformationMutableArray;
@property (nonatomic) dispatch_queue_t loaderImagesQueue;
@property (nonatomic) NSMutableArray* mediaItems;

@end

@implementation PhotoLibraryLoader

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static PhotoLibraryLoader* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[PhotoLibraryLoader alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
    
        _mediaItems = [[NSMutableArray alloc] init];
        _loaderImagesQueue = dispatch_queue_create("LOADER_GALARY_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    return  self;
}

#pragma mark - check Permission

- (void)checkPermission:(void (^)(NSError *))completion {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        
        // Access has been granted.
        if (completion) {
            
            completion(nil);
        }
    } else if (status == PHAuthorizationStatusDenied) {
        
        // Access has been denied.
        if (completion) {
            
            completion([NSError errorWithDomain:@"" code:PHAuStatusDenied userInfo:nil]);
        }
    } else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                // Access has been granted.
                if (completion) {
                    
                    completion(nil);
                }
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    // Access has been denied.
                    if (completion) {
                        
                        completion([NSError errorWithDomain:@"" code:PHAuStatusDenied userInfo:nil]);
                    }
                });
            }
        }];
    } else if (status == PHAuthorizationStatusRestricted) {
        
        // Restricted access - normally won't happen.
        if (completion) {
            
            completion([NSError errorWithDomain:@"" code:PHAuStatusRestricted userInfo:nil]);
        }
    }
}

#pragma mark - get Images

- (void)getImages:(void (^)(NSMutableArray *, NSError *))completion {
    
    PHFetchOptions* options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult* assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHImageRequestOptions* imageRequestOptions = [[PHImageRequestOptions alloc] init];
    PHVideoRequestOptions* videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    _mediaInformationMutableArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < assetsFetchResults.count; i++) {
        
        PHAsset* asset = assetsFetchResults[i];
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOptions resultHandler:^(NSData* imageData, NSString* dataUTI, UIImageOrientation orientation, NSDictionary* info) {
                
                 if ([info objectForKey:@"PHImageFileURLKey"]) {
                     
                     NSURL* path = [info objectForKey:@"PHImageFileURLKey"];
                     NSLog(@"%@",path);
                     
                     MediaItem* itemMedia = [[MediaItem alloc] init];
                     [itemMedia setInputType:AssetInput];
                     [itemMedia setImageUrl:path];
                     [itemMedia setIdentifier:asset.localIdentifier];
                     [_mediaInformationMutableArray addObject:itemMedia];
                     
                     if (_mediaInformationMutableArray.count == assetsFetchResults.count) {
                         
                        completion(_mediaInformationMutableArray, nil);
                     }
                 }
             }];
            
            imageRequestOptions = nil;    
        } else {
           
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequestOptions resultHandler:^(AVAsset* _Nullable assetVideo, AVAudioMix* _Nullable audioMix, NSDictionary* _Nullable info) {
                
                AVURLAsset* playerAsset = (AVURLAsset*) assetVideo;
                NSLog(@"%@",[playerAsset URL]);
                MediaItem* itemMedia = [[MediaItem alloc] init];
                [itemMedia setInputType:AssetInput];
                [itemMedia setImageUrl:[playerAsset URL]];
                [itemMedia setIdentifier:asset.localIdentifier];
                [itemMedia setUrlAsset:playerAsset];
                [_mediaInformationMutableArray addObject:itemMedia];
                if (_mediaInformationMutableArray.count == assetsFetchResults.count) {
                    
                    completion(_mediaInformationMutableArray, nil);
                }
            }];
            
            videoRequestOptions = nil;
        }
    }
}


@end
