//
//  MediaItem.h
//  NetworkPhotoAlbum
//
//  Created by CPU11367 on 7/14/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger,InputType) {
    
    NetWorkInput,
    AssetInput,
    FileLocalInput,
};

@interface MediaItem : NSObject

@property (nonatomic, assign) InputType inputType;
@property (nonatomic) AVURLAsset* urlAsset;
@property (nonatomic) NSString* identifier;
@property (nonatomic) NSURL* thumbailUrl;
@property (nonatomic) NSURL* imageUrl;
@property (nonatomic) NSURL* videoUrl;

@end
