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

@property (nonatomic, strong) NSString      *identifier;
@property (nonatomic, assign) double        posttime;
@property (nonatomic, strong) NSURL         *imageUrl;
@property (nonatomic, strong) NSURL         *videoUrl;
@property (nonatomic, strong) NSURL         *thumbailUrl;
@property (nonatomic, assign) double        mediaType;
@property (nonatomic, strong) NSString      *desc;
@property (nonatomic, assign) double        imageHeight;
@property (nonatomic, assign) double        imagewidth;
@property (nonatomic, assign) InputType     inputType;
@property (nonatomic, strong) AVURLAsset    *urlAsset;


@end
