//
//  AnimationView.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/10/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CameraBackgroundTableViewController.h"
#import "CameraBackgroundController.h"
#import "GestureRecognizeDelegate.h"
#import "AnimationView.h"
#import "Constants.h"
#import "Masonry.h"

#define scrollSuccessThreshold 0.7f

@interface AnimationView () <UIGestureRecognizerDelegate, GestureRecognizeDelegate>

@property (nonatomic) CameraBackgroundTableViewController* cameraBackgroundTableViewController;
@property (nonatomic) UIPanGestureRecognizer* panGesture;
@property (nonatomic) UIButton* dismissButton;
@property (nonatomic) UITableView* tableView;
@property (nonatomic) UIView* backgroundView;
@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) BOOL shouldComplete;
@property (nonatomic) UISearchBar* searchbar;
@property BOOL isSetupLayout;

@end

@implementation AnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _isSetupLayout = NO;
        _contentView = [[UIView alloc]initWithFrame:self.frame];
        UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView* blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = _contentView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_contentView addSubview:blurEffectView];
        
        [self addSubview:_contentView];
    }
    
    return self;
}

#pragma mark - hide Layout

- (void)hideLayoutFromSupview {

    [_dismissButton setHidden:YES];
    [_backgroundView setHidden:YES];
    [self setHidden:YES];
    _contentView.alpha = 0.0f;
}

#pragma mark - hide Layout

- (void)showLayoutFromSupview {
    
    [_dismissButton setHidden:NO];
    [_backgroundView setHidden:NO];
    [self setHidden:NO];

    [_tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - setup Layout

- (void)setupLayout {
    
    if (_isSetupLayout) {
        
        [self showLayoutFromSupview];
    } else {
        
        _isSetupLayout = YES;
        _dismissButton = [[UIButton alloc] init];
        [_dismissButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_dismissButton];
        
        [_dismissButton mas_makeConstraints:^(MASConstraintMaker* make) {
            
            make.left.equalTo(self).offset(16);
            make.top.equalTo(self).offset(20);
            make.width.and.height.mas_equalTo(40);
        }];
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 70)];
        [self addSubview:_backgroundView];
        
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker* make) {
            
            make.left.equalTo(self).offset(0);
            make.top.equalTo(_dismissButton.mas_bottom).offset(10);
            make.bottom.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
        }];
        
        [self setupTableView];
    }
}

#pragma mark - setup setupTableView

- (void)setupTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _backgroundView.frame.size.width, _backgroundView.frame.size.height) style:UITableViewStyleGrouped];
    [_backgroundView addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker* make) {

        make.edges.equalTo(_backgroundView);
    }];
    
    _cameraBackgroundTableViewController = [[CameraBackgroundTableViewController alloc] initWithTableView:_tableView withDelegate:_animationDelegate];
    _cameraBackgroundTableViewController.guestureDelegate = self;
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognize:)];
    [_tableView addGestureRecognizer:_panGesture];
    _panGesture.delegate = self;
    _currentPoint = _backgroundView.center;
}

#pragma mark - setup Layout

- (void)dismiss {
    
    [UIView transitionWithView:_dismissButton duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        
        [self hideLayoutFromSupview];
        [_animationDelegate showButton];
    } completion:nil];
}

#pragma mark - panGestureRecognize

- (void)panGestureRecognize:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translation = [panGesture translationInView:panGesture.view.superview];
    
    if (panGesture.view.center.y + translation.y < _backgroundView.frame.size.height / 2) {
        
        panGesture.view.center = CGPointMake(panGesture.view.center.x, _backgroundView.frame.size.height / 2);
    } else {
        
        panGesture.view.center = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + translation.y);
    }
    
    [panGesture setTranslation:CGPointMake(0, 0) inView:self];
    CGFloat threshold = (_currentPoint.y / panGesture.view.center.y);
    CGFloat aphaView = maximumBlurView;
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        // need for _downButton and _backgroundView
        // if > 1 scroll top else bottom
        if (threshold <= 1.0f) {
            
           aphaView = (_backgroundView.frame.size.height / 2) / panGesture.view.center.y;
            
            if (aphaView > maximumBlurView) {
                
                aphaView = maximumBlurView;
            }
        } else {
            
            aphaView = maximumBlurView;
        }
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            _contentView.alpha = aphaView;
        } completion:nil];
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint finalPoint;
        
        if (threshold <= scrollSuccessThreshold) {
            
            finalPoint = CGPointMake(_currentPoint.x, _backgroundView.frame.size.height * 1.5f);
            _shouldComplete = YES;
        } else {
            
            finalPoint = _currentPoint;
            _shouldComplete = NO;
        }
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{

            _tableView.center = finalPoint;
        } completion:^(BOOL finished) {
            
            if (threshold <= scrollSuccessThreshold) {
                
                [self hideLayoutFromSupview];
                _tableView.center = _currentPoint;
                [_animationDelegate showButton];
            } else {
                
                _contentView.alpha = maximumBlurView;
            }
        }];
    }
}

#pragma mark - gestureRecognizerShouldBegin

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  
    return YES;
}

#pragma mark - gesturn delegate

- (void)gesturn:(BOOL)isGuesture {
    
    if (isGuesture) {
        
        [_tableView addGestureRecognizer:_panGesture];
    } else {
        [_tableView removeGestureRecognizer:_panGesture];
    }
}

@end
