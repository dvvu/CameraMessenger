//
//  ViewController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "AnimationForCollectionViewDelegate.h"
#import "PhotoLibraryViewController.h"
#import "CameraBackgroundController.h"
#import "CamaraViewController.h"
#import "TextViewController.h"
#import "ViewController.h"
#import "AnimationView.h"
#import "Constants.h"
#import "Masonry.h"

#define topScrollSuccessThreshold 1.2f
#define bottomScrollSuccessThreshold 0.8f

@interface ViewController () <UIScrollViewDelegate, AnimationForCollectionViewDelegate, CheckCameraPermissionDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@property (nonatomic) CameraBackgroundController* cameraBackgroundController;
@property (nonatomic) PhotoLibraryViewController* photoLibraryViewController;
@property (nonatomic) CamaraViewController* camaraViewController;
@property (nonatomic) TextViewController* textViewController;
@property (nonatomic) UIPanGestureRecognizer* panGesture;
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) UIImageView* backgroundImageView;
@property (nonatomic) UIView* backgroundCCatalogView;
@property (nonatomic) AnimationView* backgroundView;
@property (nonatomic) UILabel* highlightLabel;
@property (nonatomic) UIButton* downButton;
@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGFloat width;

@property (nonatomic) UIButton* changeCameRadirectionButton;
@property (nonatomic) UIButton* cameraPhotoLibraryButton;
@property (nonatomic) UIButton* cameraExitButton;
@property (nonatomic) UIButton* cameraTextButton;
@property (nonatomic) UIButton* captureButton;
@property (nonatomic) UIButton* starButton;

@property (nonatomic) UIButton* photoLibraryCameraButton;
@property (nonatomic) UIButton* photoLibraryExitButton;
@property (nonatomic) UIButton* textCameraButton;
@property (nonatomic) UIButton* textExitButton;

@property (nonatomic) CollectionViewDataType currentCollectionViewType;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupScrollView];
}

- (void)setupScrollView {
    
    _width = self.view.frame.size.width;
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_backgroundCCatalogView setHidden:YES];
    
    [self.view addSubview:_backgroundImageView];
    [self setupViewContronllerIntoScrollView];
}

#pragma mark - setupViewContronllerIntoScrollView

- (void)setupViewContronllerIntoScrollView {
    
    // PhotoLibrary viewController
    _photoLibraryViewController = [[PhotoLibraryViewController alloc]init];
    [self addChildViewController:_photoLibraryViewController];
    [_scrollView addSubview:_photoLibraryViewController.view];
    [_photoLibraryViewController didMoveToParentViewController:self];
    
    // Camera viewController
    _camaraViewController = [[CamaraViewController alloc]init];
    CGRect camaraFrame = _camaraViewController.view.frame;
    camaraFrame.origin.x = _width;
    
    _camaraViewController.cameraDelegate = self;
    _camaraViewController.view.frame = camaraFrame;
    [self addChildViewController:_photoLibraryViewController];
    [_scrollView addSubview:_camaraViewController.view];
    [_camaraViewController didMoveToParentViewController:self];
    
    // Text viewController
    _textViewController = [[TextViewController alloc]init];
    CGRect textFrame = _camaraViewController.view.frame;
    textFrame.origin.x = _width * 2;
    
    _textViewController.view.frame = textFrame;
    [self addChildViewController:_textViewController];
    [_scrollView addSubview:_textViewController.view];
    [_textViewController didMoveToParentViewController:self];
    
    // scrolview viewController
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_width * 3, self.view.frame.size.height);
    [_scrollView setContentOffset:CGPointMake(_width, _scrollView.frame.origin.y) animated:NO];
    
    [self setupBackgroundView];
}

- (void)setupBackgroundView {
    
    // backgroundView is AnimationView to have animation blur
    _backgroundView = [[AnimationView alloc]initWithFrame:self.view.frame];
    _backgroundView.animationDelegate = self;
    _backgroundView.contentView.alpha = 0.0f;
    [_backgroundView setHidden:YES];
    [_backgroundView.contentView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:_backgroundView];
    
    // _backgroundCCatalogView is View contain UICollectionView and downButton
    _backgroundCCatalogView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - collectionViewHeight - 140, _width, 140)];
    [_backgroundCCatalogView setHidden:YES];
    [self.view addSubview:_backgroundCCatalogView];
    
    [_backgroundCCatalogView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view).offset(-(capturnCameraButtonHeight + 15 + 15)); // 80 + 15 + 15
        make.height.mas_equalTo(collectionViewHeight + 45);
    }];
    
    [self setupButton];
}

#pragma mark - setupButton for screen

- (void)setupButton {
    
    // Text Screen
    [self setupTextCameraButton];
    [self setupTextExitButton];
    
    // Camera Screen
    [self setupCameraExitButton];
    [self setupCameraPhotoLibraryButton];
    [self setupCameraTextButton];
    
    // PhotoLibrary Screen
    [self setupPhotoLibraryExitButton];
    [self setupPhotoLibraryCameraButton];
}

#pragma mark - setupColletionView

- (void)setupColletionView {
    
    // check if have permission -> setup
    // setup _collectionView
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake(collectionViewWidth, collectionViewHeight);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _width, collectionViewHeight) collectionViewLayout:layout];
    [_collectionView setBounces:YES];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_backgroundCCatalogView addSubview:_collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(_backgroundCCatalogView);
        make.left.equalTo(_backgroundCCatalogView).offset(0);
        make.right.equalTo(_backgroundCCatalogView).offset(0);
        make.bottom.mas_equalTo(_backgroundCCatalogView).offset(0);
        make.height.mas_equalTo(collectionViewHeight);
    }];
    
    // setup downButton
    _downButton = [[UIButton alloc] init];
    _downButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _downButton.layer.cornerRadius = 15.f;
    _downButton.layer.borderWidth = 2;
    [_downButton setClipsToBounds:YES];
    [_downButton setImage:[UIImage imageNamed:@"ic_down"] forState:UIControlStateNormal];
    [_downButton addTarget:self action:@selector(hideCollectionView:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundCCatalogView addSubview:_downButton];
    
    [_downButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(_backgroundCCatalogView);
        make.bottom.mas_equalTo(_collectionView.mas_top).offset(-10);
        make.width.and.height.mas_equalTo(30);
    }];
    
    // setup _highlightLabel
    _highlightLabel = [[UILabel alloc] init];
    [_highlightLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [_highlightLabel setTextColor:[UIColor whiteColor]];
    [_highlightLabel setText:@"Nổi bật"];
    _highlightLabel.alpha = 0;
    [_backgroundCCatalogView addSubview:_highlightLabel];
    
    [_highlightLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.left.equalTo(_backgroundCCatalogView).offset(16);
        make.bottom.mas_equalTo(_collectionView.mas_top).offset(-10);
    }];
    
    // setup dataSource for collectionView
    _cameraBackgroundController = [[CameraBackgroundController alloc] initWithCollectionView:_collectionView andParentViewController:self];
    _cameraBackgroundController.imageNames = @[@"background_1",@"background_2",@"background_3",@"background_4",@"background_5"];
    _cameraBackgroundController.collectionViewType = FirstCollectionViewType;
    _cameraBackgroundController.type = HighLightType;
    _currentCollectionViewType = HighLightType;
    _cameraBackgroundController.animationDelegate = self;

    // add gesturn for _backgroundCCatalogView
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognize:)];
    [_backgroundCCatalogView addGestureRecognizer:_panGesture];
    _currentPoint = _backgroundCCatalogView.center;
    
    [self setupCaptureButton];
    [self setupChangeCameraButton];
    [self setupStarButton];
}

#pragma mark - settupPhotoLibraryExitButton

- (void)setupPhotoLibraryExitButton {
    
    _photoLibraryExitButton = [[UIButton alloc] init];
    [_photoLibraryExitButton setBackgroundColor:[UIColor clearColor]];
    [_photoLibraryExitButton setImage:[UIImage imageNamed:@"ic_exit"] forState: UIControlStateNormal];
    [_photoLibraryExitButton addTarget:self action:@selector(dismissController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _photoLibraryExitButton];
    
    [_photoLibraryExitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(-_width + 20);
        make.width.and.height.mas_equalTo(30);
    }];
}

#pragma mark - setupCameraExitButton

- (void)setupCameraExitButton {
    
    _cameraExitButton = [[UIButton alloc] init];
    [_cameraExitButton setBackgroundColor:[UIColor clearColor]];
    [_cameraExitButton setImage:[UIImage imageNamed:@"ic_exit"] forState: UIControlStateNormal];
    [_cameraExitButton addTarget:self action:@selector(dismissController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _cameraExitButton];
    
    [_cameraExitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(20);
        make.width.and.height.mas_equalTo(30);
    }];
}

#pragma mark - settupExitTextButton

- (void)setupTextExitButton {
    
    _textExitButton = [[UIButton alloc] init];
    [_textExitButton setBackgroundColor:[UIColor clearColor]];
    [_textExitButton setImage:[UIImage imageNamed:@"ic_exit"] forState: UIControlStateNormal];
    [_textExitButton addTarget:self action:@selector(dismissController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _textExitButton];
    
    [_textExitButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view).offset(_width + 20);
        make.width.and.height.mas_equalTo(30);
    }];
}

#pragma mark - setupPhotoLibraryCameraButton

- (void)setupPhotoLibraryCameraButton {
    
    _photoLibraryCameraButton = [[UIButton alloc] init];
    _photoLibraryCameraButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _photoLibraryCameraButton.layer.cornerRadius = 20.f;
    _photoLibraryCameraButton.layer.borderWidth = 2;
    _photoLibraryCameraButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [_photoLibraryCameraButton setClipsToBounds:YES];
    [_photoLibraryCameraButton setImage:[UIImage imageNamed:@"ic_camera"] forState:UIControlStateNormal];
    [_photoLibraryCameraButton addTarget:self action:@selector(moveToCameraViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_photoLibraryCameraButton];
    
    [_photoLibraryCameraButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(self.view).offset(-(_width + 16));
        make.bottom.mas_equalTo(self.view).offset(-15);
        make.width.and.height.mas_equalTo(40);
    }];
}

#pragma mark - setupTextCameraButton

- (void)setupTextCameraButton {
    
    _textCameraButton = [[UIButton alloc] init];
    _textCameraButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _textCameraButton.layer.cornerRadius = 20.f;
    _textCameraButton.layer.borderWidth = 2;
    _textCameraButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [_textCameraButton setClipsToBounds:YES];
    [_textCameraButton setImage:[UIImage imageNamed:@"ic_camera"] forState:UIControlStateNormal];
    [_textCameraButton addTarget:self action:@selector(moveToCameraViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_textCameraButton];
    
    [_textCameraButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.left.equalTo(self.view).offset(_width + 16);
        make.bottom.mas_equalTo(self.view).offset(-15);
        make.width.and.height.mas_equalTo(40);
    }];
}

#pragma mark - setupCapturn buton

- (void)setupCaptureButton {
    
    _captureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_captureButton setBackgroundColor:[UIColor clearColor]];
    _captureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _captureButton.layer.cornerRadius = 40.f;
    _captureButton.layer.borderWidth = 6;
    [_captureButton addTarget:self action:@selector(captureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureButton];
    
    [_captureButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-cameraButtonBottomSpace);
        make.width.and.height.mas_equalTo(capturnCameraButtonHeight);
    }];
}

#pragma mark - setupCameraPhotoLibraryButton

- (void)setupCameraPhotoLibraryButton {
    
    _cameraPhotoLibraryButton = [[UIButton alloc] init];
    _cameraPhotoLibraryButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _cameraPhotoLibraryButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    _cameraPhotoLibraryButton.layer.cornerRadius = 20.f;
    _cameraPhotoLibraryButton.layer.borderWidth = 2;
    [_cameraPhotoLibraryButton addTarget:self action:@selector(moveToLibraryViewController:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraPhotoLibraryButton setImage:[UIImage imageNamed:@"ic_photo"] forState:UIControlStateNormal];
    [_cameraPhotoLibraryButton setClipsToBounds:YES];
    [self.view addSubview:_cameraPhotoLibraryButton];
    
    [_cameraPhotoLibraryButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.left.equalTo(self.view).offset(16);
        make.bottom.mas_equalTo(self.view).offset(-cameraButtonBottomSpace);
        make.width.and.height.mas_equalTo(40);
    }];
}

#pragma mark - setupStarButton

- (void)setupStarButton {
    
    _starButton = [[UIButton alloc] init];
    [_starButton setImage:[UIImage imageNamed:@"ic_star"] forState:UIControlStateNormal];
    
    [_starButton addTarget:self action:@selector(showCollectionView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_starButton];
    
    [_starButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-(capturnCameraButtonHeight + 15 + 20));
        make.width.and.height.mas_equalTo(40);
    }];
}

#pragma mark - setupCameraTextButton

- (void)setupCameraTextButton {
    
    _cameraTextButton = [[UIButton alloc] init];
    _cameraTextButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _cameraTextButton.layer.cornerRadius = 20.f;
    _cameraTextButton.layer.borderWidth = 2;
    _cameraTextButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [_cameraTextButton addTarget:self action:@selector(moveToTextViewController:) forControlEvents:UIControlEventTouchUpInside];
    [_cameraTextButton setImage:[UIImage imageNamed:@"ic_paint"] forState:UIControlStateNormal];
    [_cameraTextButton setClipsToBounds:YES];
    [self.view addSubview:_cameraTextButton];
    
    [_cameraTextButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.right.equalTo(self.view).offset(-16);
        make.bottom.mas_equalTo(self.view).offset(-cameraButtonBottomSpace);
        make.width.and.height.mas_equalTo(40);
    }];
}

#pragma mark - setupChangeCameraButton

- (void)setupChangeCameraButton {
    
    _changeCameRadirectionButton = [[UIButton alloc] init];
    [_changeCameRadirectionButton setBackgroundColor:[UIColor clearColor]];
    [_changeCameRadirectionButton setImage:[UIImage imageNamed:@"ic_camera"] forState: UIControlStateNormal];
    [_changeCameRadirectionButton addTarget:self action:@selector(changeCameraDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _changeCameRadirectionButton];
    
    [_changeCameRadirectionButton mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.top.equalTo(self.view).offset(18);
        make.left.equalTo(self.view.mas_left).offset(70);
        make.width.and.height.mas_equalTo(35);
    }];
}

#pragma mark - showCollectionView

- (IBAction)showCollectionView:(id)sender {
    
    [self showCollectionView];
}

#pragma mark - moveToLibraryViewController

- (IBAction)moveToLibraryViewController:(id)sender {
    
    [_scrollView setContentOffset:CGPointMake(0, _scrollView.frame.origin.y) animated:YES];
}

#pragma mark - moveToTextViewController

- (IBAction)moveToTextViewController:(id)sender {
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2, _scrollView.frame.origin.y) animated:YES];
}

#pragma mark - moveToCameraViewController

- (IBAction)moveToCameraViewController:(id)sender {
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, _scrollView.frame.origin.y) animated:YES];
}

#pragma mark - changeCameraDirection

- (IBAction)changeCameraDirection:(id)sender {
    
    [_camaraViewController changeCameraDirection];
}

#pragma mark - dismissController

- (IBAction)dismissController:(id)sender {
    
}

#pragma mark - openCamara

- (IBAction)captureAction:(id)sender {
    
    [_camaraViewController captureAction];
}

#pragma mark - showCollectionView

- (void)showCollectionView {
    
    [UIView transitionWithView:self.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        
        [_backgroundCCatalogView setHidden:NO];
        [_starButton setHidden:YES];
    } completion:nil];
}

#pragma mark - close collectionView

- (IBAction)hideCollectionView:(id)sender {

    [UIView transitionWithView:self.view duration:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
        
        _backgroundCCatalogView.frame = CGRectMake(_backgroundCCatalogView.frame.origin.x, self.view.frame.size.height, _backgroundCCatalogView.frame.size.width, _backgroundCCatalogView.frame.size.height);
    } completion:^(BOOL finished) {
        
        _backgroundCCatalogView.center = _currentPoint;
        _downButton.alpha = 1.0f;
        [_starButton setHidden:NO];
        [_backgroundCCatalogView setHidden:YES];
    }];
}

#pragma mark - hide collectionView

- (void)hideCollectionView {
    
    [UIView transitionWithView:self.view duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        
        [_backgroundCCatalogView setHidden:YES];
        [_starButton setHidden:NO];
    } completion:^(BOOL finished) {
        
        _backgroundCCatalogView.center = _currentPoint;
        _downButton.alpha = 1.0f;
    }];
}

#pragma mark - scrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [_textViewController dismissKeyboard];
    
    if (scrollView.contentOffset.x < _width) {
        
        // Camera Screen
        [self layoutButtonWhenScroll:_cameraExitButton with:scrollView horizontal:_width + 32 - scrollView.contentOffset.x - _cameraExitButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_changeCameRadirectionButton with:scrollView horizontal:_width + 52 + _cameraExitButton.frame.size.width - scrollView.contentOffset.x - _changeCameRadirectionButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_starButton with:scrollView horizontal:_width * 1.5f - scrollView.contentOffset.x - _starButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_captureButton with:scrollView horizontal:_width * 1.5f - scrollView.contentOffset.x - _captureButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_cameraTextButton with:scrollView horizontal:_width * 2 - 32 - scrollView.contentOffset.x - _cameraTextButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_cameraPhotoLibraryButton with:scrollView horizontal:_width + 32 - scrollView.contentOffset.x - _cameraPhotoLibraryButton.frame.size.width/2];
        
        // Photo Screen
        [self layoutButtonWhenScroll:_photoLibraryExitButton with:scrollView horizontal:32 - scrollView.contentOffset.x - _photoLibraryExitButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_photoLibraryCameraButton with:scrollView horizontal:_width - 32 - scrollView.contentOffset.x - _photoLibraryCameraButton.frame.size.width/2];
        
        // Text Screen
        [self layoutButtonWhenScroll:_textExitButton with:scrollView horizontal:_width * 2 + 32 - scrollView.contentOffset.x - _textExitButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_textCameraButton with:scrollView horizontal:_width * 2 + 32 - scrollView.contentOffset.x - _textCameraButton.frame.size.width/2];
        
        // background Screen
        _backgroundImageView.frame = CGRectMake(_width - scrollView.contentOffset.x, _backgroundImageView.frame.origin.y, _backgroundImageView.frame.size.width, _backgroundImageView.frame.size.height);
        
        _backgroundCCatalogView.frame = CGRectMake(_width - scrollView.contentOffset.x, _backgroundCCatalogView.frame.origin.y, _backgroundCCatalogView.frame.size.width, _backgroundCCatalogView.frame.size.height);
    } else if (scrollView.contentOffset.x < _width * 2) {
        
        // Camera Screen
        [self layoutButtonWhenScroll:_cameraExitButton with:scrollView horizontal:_width + 32 - scrollView.contentOffset.x - _cameraExitButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_changeCameRadirectionButton with:scrollView horizontal:_width + 52 + _cameraExitButton.frame.size.width - scrollView.contentOffset.x - _changeCameRadirectionButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_starButton with:scrollView horizontal:_width * 1.5f - scrollView.contentOffset.x - _starButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_captureButton with:scrollView horizontal:_width * 1.5f - scrollView.contentOffset.x - _captureButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_cameraTextButton with:scrollView horizontal:_width * 2 - 32 - scrollView.contentOffset.x - _cameraTextButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_cameraPhotoLibraryButton with:scrollView horizontal:_width + 32 - scrollView.contentOffset.x - _cameraPhotoLibraryButton.frame.size.width/2];
        
        // Photo Screen
        [self layoutButtonWhenScroll:_photoLibraryExitButton with:scrollView horizontal:32 - scrollView.contentOffset.x - _photoLibraryExitButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_photoLibraryCameraButton with:scrollView horizontal:_width - 32 - scrollView.contentOffset.x - _photoLibraryCameraButton.frame.size.width/2];
        
        // Text Screen
        [self layoutButtonWhenScroll:_textExitButton with:scrollView horizontal:_width * 2 + 32 - scrollView.contentOffset.x - _textExitButton.frame.size.width/2];
        [self layoutButtonWhenScroll:_textCameraButton with:scrollView horizontal:_width * 2 + 32 - scrollView.contentOffset.x - _textCameraButton.frame.size.width/2];
    }
}

#pragma mark - layoutButtonWhenScroll

- (void)layoutButtonWhenScroll:(UIButton *)button with:(UIScrollView *)scrollView horizontal:(CGFloat)initialX {
    
    button.frame = CGRectMake(initialX, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
}

#pragma mark - pan gesture

- (void)panGestureRecognize:(UIPanGestureRecognizer *)panGesture {

    CGPoint translation = [panGesture translationInView:panGesture.view.superview];
    CGFloat aphaView = 1.0f;
    
    [_backgroundView setHidden:NO];
    
    // collectionViewHeight/2 + 80 (height of Header) - 15(_downButtonHeight/2) - 7.5(space between _downButton and collectionView and baackground view)
    if (panGesture.view.center.y + translation.y < collectionViewHeight / 2 + 57.5 + headerTableViewHeight + searchBarheight) {
        
        panGesture.view.center = CGPointMake(panGesture.view.center.x, collectionViewHeight / 2 + 57.5 + headerTableViewHeight + searchBarheight);
    } else {
        
        panGesture.view.center = CGPointMake(panGesture.view.center.x, panGesture.view.center.y + translation.y);
    }
    
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
    CGFloat threshold = (_currentPoint.y / panGesture.view.center.y);
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        // need for _downButton and _backgroundView
        // if > 1 scroll top else bottom
        if (threshold <= 1.0f) {
            
            aphaView = 1.0f;
        } else {
            
            aphaView = 1.0f - collectionViewHeight / panGesture.view.center.y;
        }
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            _downButton.alpha = aphaView;
            _backgroundView.contentView.alpha = maximumBlurView - aphaView;
            _highlightLabel.alpha = 1.0f - aphaView;
        } completion:nil];
        
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        CGPoint finalPoint;
        
        if (threshold >= topScrollSuccessThreshold) {
            
            aphaView = 0.0f;
            finalPoint = CGPointMake(_currentPoint.x, collectionViewHeight / 2 + 57.5 + headerTableViewHeight + searchBarheight);
        } else if (threshold <= bottomScrollSuccessThreshold) {
            
            finalPoint = CGPointMake(_currentPoint.x, self.view.bounds.size.height + _backgroundCCatalogView.frame.size.height);
        } else {
            
            finalPoint = _currentPoint;
        }
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            _downButton.alpha = aphaView;
            _backgroundView.contentView.alpha = maximumBlurView - aphaView;
            panGesture.view.center = finalPoint;
            
        } completion:^(BOOL finished) {
            
            _highlightLabel.alpha = 0;
            
            if (threshold >= topScrollSuccessThreshold) {
                
                [self hideCollectionView];
                [_backgroundView setupLayout];
                [self showHideButton:YES];
                [_starButton setHidden:YES];
            } else if (threshold <= bottomScrollSuccessThreshold) {
                
                [self hideCollectionView];
                [_backgroundView hideLayoutFromSupview];
                [_starButton setHidden:NO];
            }
        }];
    }
}

#pragma mark - pan show/hide button

- (void)showHideButton:(BOOL)isHidden {
    
    [_changeCameRadirectionButton setHidden:isHidden];
    [_cameraPhotoLibraryButton setHidden:isHidden];
    [_captureButton setHidden:isHidden];
    [_starButton setHidden:isHidden];
    [_cameraExitButton setHidden:isHidden];
    [_cameraTextButton setHidden:isHidden];
}

#pragma mark - showButtonDelegate

- (void)showButton {
    
    [self showHideButton:NO];
}

#pragma mark - reloadData

- (void)reloadData:(void (^)())completion {
   
    if (completion) {
        
        [_collectionView reloadData];
    }
}

#pragma mark - showCollectionViewDelegate

- (void)showCollectionViewDelegate:(UIImage *)image withType:(CollectionViewDataType)type andPosition:(CGPoint)point {
    
    if (image) {
        
        if (![_backgroundCCatalogView isHidden]) {
            
        } else {
            
            if (_currentCollectionViewType != type) {
                
                _currentCollectionViewType = type;
                
                if (type == HighLightType) {
                    
                    _highlightLabel.text = @"Nổi bật";
                    _cameraBackgroundController.imageNames = @[@"background_1",@"background_2",@"background_3",@"background_4",@"background_5"];
                    _cameraBackgroundController.collectionViewType = FirstCollectionViewType;
                    [_collectionView reloadData];
                    [_collectionView layoutIfNeeded];
                } else {
                    
                    _highlightLabel.text = @"Tô điểm";
                    _cameraBackgroundController.imageNames = @[@"background1",@"background2",@"background3",@"background4",@"background5",@"background6"];
                    _cameraBackgroundController.collectionViewType = SecondCollectionViewType;
                    [_collectionView reloadData];
                    [_collectionView layoutIfNeeded];
                }
            }
            
            // scroll for the same collectionView just have clicked.
            _backgroundCCatalogView.center = CGPointMake(_currentPoint.x, point.y - 22.5);
            [_collectionView scrollRectToVisible:CGRectMake(point.x, 0, _collectionView.frame.size.width,  _collectionView.frame.size.height) animated:YES];
            [self showCollectionView];
            
            [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                _backgroundCCatalogView.center = _currentPoint;
                [_backgroundView hideLayoutFromSupview];
            } completion:^(BOOL finished) {
                
                [self showHideButton:NO];
                [_starButton setHidden:YES];
            }];
        }
    }
    
    _backgroundImageView.image = image;
}

#pragma mark - cameraPermission

- (void)cameraPermission:(BOOL)isAllow {
    
    [self setupColletionView];
}

@end
