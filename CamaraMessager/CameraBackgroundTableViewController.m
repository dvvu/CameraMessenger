//
//  CameraBackgroundTableViewController.m
//  CamaraMessager
//
//  Created by Doan Van Vu on 8/14/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "CameraBackgroundTableViewController.h"
#import "CameraBackgroundController.h"
#import "Constants.h"

@interface CameraBackgroundTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CameraBackgroundController* cameraBackgroundController;
@property (nonatomic) CameraBackgroundController* cameraBackgroundController1;
@property (nonatomic) UISearchController* searchController;
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) UICollectionView* collectionView1;
@property (nonatomic) UIView* cellSeperatorView;
@property (nonatomic) UITableView* tableView;

@end

@implementation CameraBackgroundTableViewController

#pragma mark - initWithTableView

- (instancetype)initWithTableView:(UITableView *)tableView withDelegate:(id)animationDelegate {
    
    if (self = [super init]) {
        
        _animationDelegate = animationDelegate;
        [self initTableView:tableView];
    }
    
    return self;
}

#pragma mark - initwithTableView

- (void)initTableView:(UITableView *)tableView {
    
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setBounces:NO];
    
    [self createSearchController];
}

#pragma mark - setupCollectionView

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake(collectionViewWidth, collectionViewHeight);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, collectionViewHeight) collectionViewLayout:layout];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];

    _cameraBackgroundController = [[CameraBackgroundController alloc] initWithCollectionView:_collectionView andParentViewController:nil];
    _cameraBackgroundController.imageNames = @[@"background_1",@"background_2",@"background_3",@"background_4",@"background_5"];
    _cameraBackgroundController.type = HighLightType;
    _cameraBackgroundController.collectionViewType = FirstCollectionViewType;
    _cameraBackgroundController.animationDelegate = _animationDelegate;
}

#pragma mark - setupCollectionView1

- (void)setupCollectionView1 {
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake(collectionViewWidth, collectionViewHeight);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView1 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, collectionViewHeight) collectionViewLayout:layout];
    [_collectionView1 setShowsVerticalScrollIndicator:NO];
    [_collectionView1 setShowsHorizontalScrollIndicator:NO];
    [_collectionView1 setBackgroundColor:[UIColor clearColor]];
    [_collectionView1 registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    _cameraBackgroundController1 = [[CameraBackgroundController alloc] initWithCollectionView:_collectionView1 andParentViewController:nil];
    _cameraBackgroundController1.imageNames = @[@"background1",@"background2",@"background3",@"background4",@"background5",@"background6"];
    _cameraBackgroundController1.type = FunnyType;
    _cameraBackgroundController1.collectionViewType = SecondCollectionViewType;
    _cameraBackgroundController1.animationDelegate = _animationDelegate;
}

#pragma mark - createSearchController

- (void)createSearchController {
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchController.dimsBackgroundDuringPresentation = YES;
    [_searchController.searchBar sizeToFit];
    [_tableView setTableHeaderView:_searchController.searchBar];
}

#pragma mark - numberOfSectionsInTableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

#pragma mark - numberOfRowsInSection

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

#pragma mark - cellForRowAtIndexPath

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
   
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    _cellSeperatorView = [[UIView alloc] initWithFrame:CGRectZero];
    [_cellSeperatorView setBackgroundColor:[UIColor lightGrayColor]];
    [_cellSeperatorView setFrame:CGRectMake(0, collectionViewHeight + 9, tableView.frame.size.width, 1)];
    [cell addSubview:_cellSeperatorView];
    
    if (indexPath.section == 0) {
        
        [self setupCollectionView];
        [cell addSubview:_collectionView];
    } else {
        
        [self setupCollectionView1];
        [cell addSubview:_collectionView1];
    }
    
    return cell;
}

#pragma mark - heightForRowAtIndexPath

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return collectionViewHeight + 10;
}

#pragma mark - heightForHeaderInSection

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  
    return 25;
}

#pragma mark - viewForHeaderInSection


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* viewHeader = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel* titleLabel = [UILabel.alloc initWithFrame:viewHeader.frame];
    
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [viewHeader addSubview:titleLabel];

    if (section == 0) {
        
        titleLabel.text = @"  Nổi bật";
    } else {
        
        titleLabel.text = @"  Tô điểm";
    }
    return viewHeader;
}

#pragma mark - scrollViewDidScroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // bounce top
    if (self.tableView.contentOffset.y <= 0) {
        
        [_guestureDelegate gesturn:YES];
    } else {
        
        [_guestureDelegate gesturn:NO];
    }
}


@end
