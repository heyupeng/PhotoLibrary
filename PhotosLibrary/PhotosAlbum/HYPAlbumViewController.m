//
//  HYPAlbumViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/23.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPAlbumViewController.h"
#import "HYPAssetsViewController.h"

#import "HYPAssetModel.h"
#import "HYPImageManager.h"

#pragma mark - HYPTableViewCell
@interface HYPTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) NSString * title;

@end

@implementation HYPTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
//    if (_postImageView) {
        frame.origin.x = self.indentationLevel * self.indentationWidth;
        frame.size.width = frame.size.height;
        self.postImageView.frame = frame;
//    }
    
    frame = self.textLabel.frame;
    frame.origin.x = self.indentationWidth + CGRectGetMaxX(self.postImageView.frame);
    frame.size.width = CGRectGetWidth(self.frame) - CGRectGetMinX(frame) - 20;
    self.textLabel.frame = frame;
}


- (UIImageView *)postImageView {
    if (!_postImageView) {
        UIImageView * postImageView = [[UIImageView alloc] init];
        postImageView.contentMode = UIViewContentModeScaleAspectFill;
        postImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        postImageView.clipsToBounds = YES;
        postImageView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        [self.contentView addSubview: postImageView];
        _postImageView = postImageView;
    }
    return _postImageView;
}
@end


#pragma mark - HYPAlbumViewController
@interface HYPAlbumViewController ()<PHPhotoLibraryChangeObserver, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> * collection;
@end

@implementation HYPAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    
    [self initTableView];
    
    [self loadData];
}

/*
 controller处于UINavigationController管理下, StatusBarStyle由barStyle决定。
 当(.navigationBar.barStyle == UIBarStyleDefault && .navigationBarHidden == NO), preferredStatusBarStyle不会被调动。
 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)loadData {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
        [self fetchAssetCollections];
        return;
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        NSLog(@"%ld", status);
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            
            [self fetchAssetCollections];
        } else {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请打开相册权限" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self completionWithSuccess:NO items:nil];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
}

- (void)fetchAssetCollections {
    
    NSArray * ablums = [[HYPImageManager share] fetchAblumsWithMediaType:_showMediaType];

    self.dataSource = [NSMutableArray new];
    [self.dataSource addObjectsFromArray:ablums];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        NSLog(@"reloadData");
    });
}

- (void)setup {
    _showMediaType = HYPMediaTypeAll;
    self.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationController.navigationBar.translucent = YES;
    UIColor * barTintColor = [UIColor colorWithRed:0.50 green:0.59 blue:0.10 alpha:1];
    barTintColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor = barTintColor;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)initTableView {
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tableView registerClass:[HYPTableViewCell class] forCellReuseIdentifier:@"CellReuseIdentifier"];
    
    _tableView = tableView;
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self completionWithSuccess:NO items:NULL];
}

- (void)completionWithSuccess:(BOOL)isSuccess items:(NSArray *)items {
    if (_completion) {
        _completion(isSuccess, items);
    }
}
#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails * changeDetails = [changeInstance changeDetailsForFetchResult:self.collection];
    if (changeDetails && changeDetails.hasIncrementalChanges) {
//        PHFetchResult * fetchResult = changeDetails.fetchResultAfterChanges;
//        self.collection = fetchResult;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource? self.dataSource.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYPTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CellReuseIdentifier"];
    cell.indentationLevel = 1;
    
    HYPAlbumModel * model = [self.dataSource objectAtIndex:indexPath.row];

    NSString * text = [model.title stringByAppendingString:[NSString stringWithFormat:@" (%ld)",  model.count]];
    cell.textLabel.text = text;
    
    if (model.count) {
        [model requestSmallImage:^(UIImage *image) {
            if (image) {
                cell.postImageView.image = image;
            }
        }];
    } else {
        cell.postImageView.image = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        
    HYPAlbumModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    HYPAssetsViewController * vc = [[HYPAssetsViewController alloc] init];
    vc.title = model.title;
    vc.result = model.fetchResult;
    vc.completion = self.completion;
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
