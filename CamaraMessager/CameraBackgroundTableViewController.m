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
@property (nonatomic) UISearchController* searchController;
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) UITableView* tableView;

@end

@implementation CameraBackgroundTableViewController

- (instancetype)initWithTableView:(UITableView *)tableView withDelegate:(id)animationDelegate {
    
    if (self = [super init]) {
        
        _animationDelegate = animationDelegate;
        [self initTableView:tableView];
    }
    
    return self;
}

#pragma mark - init with TableView

- (void)initTableView:(UITableView *)tableView {
    
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBounces:NO];
    
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];

    [self createSearchController];
    [self setupCollectionView];
}

#pragma mark - setupCollectionView

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake(collectionViewWidth, collectionViewHeight);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, collectionViewHeight) collectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setShowsVerticalScrollIndicator:NO];
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];

    _cameraBackgroundController = [[CameraBackgroundController alloc] initWithCollectionView:_collectionView andParentViewController:nil];
    _cameraBackgroundController.animationDelegate = _animationDelegate;
}

#pragma mark - createSearchController

- (void)createSearchController {
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchController.dimsBackgroundDuringPresentation = YES;
    [_searchController.searchBar sizeToFit];
    _tableView.tableHeaderView = _searchController.searchBar;
}

#pragma mark - numberOfSectionsInTableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
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
    [cell addSubview:_collectionView];
    
    return cell;
}

#pragma mark - heightForRowAtIndexPath

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return collectionViewHeight + 10;
}

#pragma mark - heightForRowAttitleForHeaderInSectionIndexPath

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Nổi bật";
}

#pragma mark - heightForHeaderInSection

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
  
    return 25;
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
