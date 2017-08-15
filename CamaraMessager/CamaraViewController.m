//
//  CamaraViewController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CamaraViewController.h"
#import "Masonry.h"

@interface CamaraViewController ()

@property (nonatomic) AVCaptureStillImageOutput* stillImageOutput;;
@property (nonatomic) AVAuthorizationStatus authStatus;
@property (nonatomic) dispatch_queue_t cameraQueue;
@property (nonatomic) AVCaptureSession* session;
@property (nonatomic) UIView* backgroundView;
@property (nonatomic) NSString* mediaType;
@property (nonatomic) UIView* cameraView;

@end

@implementation CamaraViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    _cameraQueue = dispatch_queue_create("CAMERA_QUEUE", DISPATCH_QUEUE_SERIAL);
    _cameraView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_cameraView];
    
    _mediaType = AVMediaTypeVideo;
    _authStatus = [AVCaptureDevice authorizationStatusForMediaType:_mediaType];
    
    if (_authStatus == AVAuthorizationStatusAuthorized) {
    
        // is accessed
        [self openCamera];
    } else {
        
        [self settupBackgroundView];
    }
}

#pragma mark - open camera

- (void)openCamera {

    dispatch_async(_cameraQueue, ^ {
        
        _session = [[AVCaptureSession alloc] init];
        
        AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
       
        if (videoDevice) {

            NSError* error;
            AVCaptureDeviceInput* videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
          
            if (!error) {
                
                if ([_session canAddInput:videoInput]) {
                    
                    [_session addInput:videoInput];
                }
                
                AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
                previewLayer.frame = _cameraView.bounds;
                [_cameraView.layer addSublayer:previewLayer];
                
                _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                NSDictionary* outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
                [_stillImageOutput setOutputSettings:outputSettings];
                
                if ([_session canAddOutput:_stillImageOutput]) {
                    
                    [_session addOutput:_stillImageOutput];
                }
        
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    [_session startRunning];
                    [_cameraDelegate cameraPermission:YES];
                });
            }
        }
    });
}

#pragma mark - settupBackgroundView

- (void)settupBackgroundView {
    
    _backgroundView = [[UIView alloc] init];
    [self.view addSubview: _backgroundView];
    
    // config label
    UILabel* label  = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:36]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 2;
    label.text = @"Chụp ảnh và quay video";
    [_backgroundView addSubview:label];
    
    UIButton* permissionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [permissionButton setBackgroundColor:[UIColor clearColor]];
    [permissionButton setTitle:@"Cho phép truy cập máy ảnh" forState:UIControlStateNormal];
    [permissionButton addTarget:self action:@selector(checkCameraPermission:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - openCamara

- (IBAction)captureAction {
    
    // Open camera viewController.
    AVCaptureConnection* videoConnection = nil;
    
    for (AVCaptureConnection* connection in _stillImageOutput.connections) {
        
        for (AVCaptureInputPort* port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            
            break;
        }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError* error) {
        
        if (imageDataSampleBuffer) {
            
//            NSData* imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//            UIImage* image = [UIImage imageWithData:imageData];
        }
    }];
}

#pragma mark - checkCameraPermission

- (IBAction)checkCameraPermission:(id)sender {
    
    [self checkCameraPermission];
}

#pragma mark - changeCameraDirection

- (IBAction)changeCameraDirection {
   
    dispatch_async(_cameraQueue, ^ {
        
        if (_session) {
            
            [_session beginConfiguration];
            
            AVCaptureInput* currentCameraInput = [_session.inputs objectAtIndex:0];
            [_session removeInput:currentCameraInput];
            
            AVCaptureDevice* changeDirectionCamera = nil;
            
            if (((AVCaptureDeviceInput *)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
                
                changeDirectionCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            } else {
                
                changeDirectionCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            
            NSError* err = nil;
            
            AVCaptureDeviceInput* newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:changeDirectionCamera error:&err];
            
            if (!newVideoInput || err) {
                
                NSLog(@"Error creating capture device input: %@", err.localizedDescription);
            } else {
                
                if ([_session canAddInput:newVideoInput]) {
                    
                    [_session addInput:newVideoInput];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                [_session commitConfiguration];
            });
        }
    });
}

#pragma mark - get direction back or front.

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
   
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice* device in devices) {
       
        if ([device position] == position) {
            
            return device;
        }
    }
    return nil;
}

#pragma mark - checkPermission Camera

- (void)checkCameraPermission {
         
     if (_authStatus == AVAuthorizationStatusAuthorized) {
        
         [_backgroundView setHidden:YES];
         [self openCamera];
     } else if (_authStatus == AVAuthorizationStatusDenied) {
         
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
     } else if(_authStatus == AVAuthorizationStatusRestricted) {
         
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
     } else if(_authStatus == AVAuthorizationStatusNotDetermined) {
         
         // not determined?!
         [AVCaptureDevice requestAccessForMediaType:_mediaType completionHandler:^(BOOL granted) {
             
             if (granted) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^ {
                     
                     [_backgroundView setHidden:YES];
                     [self openCamera];
                 });
             } else {
                 
                 dispatch_async(dispatch_get_main_queue(), ^ {
                     
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                 });
             }
         }];
     } else {
         
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
     }
}

@end
