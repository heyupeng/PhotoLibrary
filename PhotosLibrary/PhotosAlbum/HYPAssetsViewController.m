//
//  HYPAssetsViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/26.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPAssetsViewController.h"
#import "HYPCollectionViewCell.h"
#import "HYPAssetViewController.h"
#import "HYPPreviewViewController.h"

#import "HYPView.h"

static NSString * cellReuseIdentifier = @"CellReuseIdentifier";

#pragma mark - HYPAssetsViewController

@interface HYPAssetsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) HYPBottomBar * bottomBar;


@property (nonatomic) NSUInteger maxSelectedNumber;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> * selectedIndexPaths;
@property (nonatomic, strong) NSMutableArray<HYPAssetModel *> * selectedModels;

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> * indexPathsForAnimation;
@end

@implementation HYPAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    
    [self initCollectionView];
    
    [self setCostumBottomBar];

    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//    });
    [self refreshBottomBar];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)setup {
    self.maxSelectedNumber = 9;
    self.selectedIndexPaths = [NSMutableArray new];
    self.selectedModels = [NSMutableArray new];
    self.indexPathsForAnimation = [NSMutableArray new];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (UIBarButtonItem *)rightBarButtonItem {
    NSString * title = @"取消";
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClick:)];
    return item;
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)sender {
//    [self setAllowsSelection:self.collectionView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCostumBottomBar {
    CGRect frame = self.view.bounds;
    frame.origin.y = CGRectGetHeight(frame) - 44;
    frame.size.height = 44;
    
    _bottomBar = [[HYPBottomBar alloc] init];
    _bottomBar.backgroundColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:0.9];

    _bottomBar.frame = frame;
    [self.view addSubview:_bottomBar];
    
    // left btn
    UIButton * leftBtn = _bottomBar.leftBtn;
    leftBtn.layer.cornerRadius = 10;

    [leftBtn setTitle:@"预览" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(bottomBarLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    // right btn
    UIButton * rightBtn = _bottomBar.rightBtn;
    rightBtn.backgroundColor = [UIColor colorWithRed:0 green:119/255.0 blue:0 alpha:1];
    rightBtn.layer.cornerRadius = 10;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.enabled = NO;
    [rightBtn addTarget:self action:@selector(bottomBarRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * numberLabel = [[UILabel alloc] init];
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.backgroundColor = [UIColor colorWithRed:0 green:119/255.0 blue:0 alpha:1];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.hidden = YES;
//    [_bottomBar.contentView addSubview:numberLabel];
    
    
    numberLabel.frame = CGRectMake(375 - 60 - 44, 7, 30, 30);
    numberLabel.layer.cornerRadius = CGRectGetWidth(numberLabel.frame) * 0.5;
    numberLabel.layer.masksToBounds = YES;
    
    _bottomBar.leftBtn.enabled = NO;
    _bottomBar.rightBtn.enabled = NO;
}

- (void)bottomBarLeftBtnClick:(UIButton *)sender {
    if (!self.selectedModels || self.selectedModels.count < 1) {
        return;
    }
    
    HYPPreviewViewController * previewVC = [[HYPPreviewViewController alloc]init];
    previewVC.dataSource = [self.selectedModels copy];
    previewVC.selectedItems = self.selectedModels;
    previewVC.currenIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)bottomBarRightBtnClick:(UIButton *)sender {
    
}

- (void)refreshBottomBar {
    NSInteger count = self.selectedModels.count;
    if (count < 1) {
        _bottomBar.leftBtn.enabled = NO;
        _bottomBar.rightBtn.enabled = NO;
        _bottomBar.rightBtn.alpha = 0.7;
    } else {
        _bottomBar.leftBtn.enabled = YES;
        _bottomBar.rightBtn.enabled = YES;
        _bottomBar.rightBtn.alpha = 1.0;
    }
//    NSString * text = [NSString stringWithFormat:@"%ld", count];
//    _numberLabel.text = text;
    
    NSString * title = @"下一步";
    if (count) {
        title = [title stringByAppendingString:[NSString stringWithFormat:@"(%ld)", count]];
    }
    [_bottomBar.rightBtn setTitle:title forState:UIControlStateNormal];
}

- (void)initCollectionView {
    float n = 4, lineSpacing = 5;
    float itemWidth = CGRectGetWidth([self.view bounds]);
    itemWidth = itemWidth - lineSpacing * (n + 1);
    itemWidth /= n;
    // FlowLayout
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumInteritemSpacing = lineSpacing;
    layout.minimumLineSpacing = lineSpacing;
    
    // CollectionView
    CGRect frame = self.view.bounds;
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[HYPCollectionViewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
    [self.view addSubview:collectionView];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    _collectionView = collectionView;
}

- (CGSize)imageTargetSize {
    float scale = [UIScreen mainScreen].scale;
    CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
    return CGSizeMake(itemSize.width * scale, itemSize.height * scale);
}

- (void)loadData {
    if (!self.result) {
        return;
    }
    PHFetchResult * result = self.result;
    if (self.dataSource) [self.dataSource removeAllObjects];
    else self.dataSource = [NSMutableArray new];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HYPAssetModel * model = [[HYPAssetModel alloc] init];
        model.asset = obj;
        [self.dataSource addObject:model];
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails * changeDetails = [changeInstance changeDetailsForFetchResult:self.result];
    if (!changeDetails || !changeDetails.hasIncrementalChanges) {
        return;
    }
    PHFetchResult * fetchResult = changeDetails.fetchResultAfterChanges;
    self.result = fetchResult;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView performBatchUpdates:^{
            NSIndexSet * indexes = changeDetails.changedIndexes;
            if (indexes || indexes.count > 0) {
                
            }
        } completion:^(BOOL finished) {
            
        }];
    });
}

NSString * durationSecondToMinAndSec(NSTimeInterval duration) {
    int total = round(duration);
    int min = 0.0, sec = 0.0;
    min = total / 60;
    sec = total % 60;
    
    NSString * timeString = [NSString stringWithFormat:@"%02i:%02i", min, sec];
    return timeString;
}

#pragma mark - CollectionView dataSource and delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource? self.dataSource.count: 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HYPCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    HYPAssetModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    NSString * text = nil;
    if (model.asset.mediaType == PHAssetMediaTypeVideo) {
        text = durationSecondToMinAndSec(model.asset.duration);
    }
    cell.timeLabel.text = text;
    
    // 最大选择数小于2不显示副按钮
    if (self.maxSelectedNumber < 2) {
        cell.showAccessoryButton = NO;
    } else {
        cell.showAccessoryButton = YES;
    }
    
    
    if (self.selectedModels.count >= self.maxSelectedNumber && ! model.isSelected) {
        cell.accessoryEnable = NO;
    }else {
        cell.accessoryEnable = YES;
    }
    
    cell.accessorySelected = model.isSelected;
    if (model.isSelected) {
        NSInteger selectedIndex = [self.selectedModels indexOfObject:model];
        cell.selectedIndex = selectedIndex + 1;
    } else {
        cell.selectedIndex = -1;
    }
    
    // reload前标记的cell播放动画
    if (self.indexPathsForAnimation && self.indexPathsForAnimation.count > 0 && [self.indexPathsForAnimation containsObject:indexPath]) {
        [self.indexPathsForAnimation removeObject:indexPath];
        [cell animationKeyframes];
    }
    
    
    CGSize size = CGSizeZero;
    size = [self imageTargetSize];
    
    if (model.image) {
        cell.imageView.image = model.image;
    } else {
        [model requestImageWithSize:size compeletion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
            if (!image) { return ;}
            if ([[info objectForKey:PHImageResultIsDegradedKey] intValue] == 0) {
                if ([info objectForKey:@"PHImageFileURLKey"]) {
                    model.originImage = image;
                }
            }
            model.image = image;
            cell.imageView.image = image;
        }];
    }
    
    cell.selectCallBack = ^(HYPCollectionViewCell * _Nonnull sender, BOOL selected) {
        [self collectionViewCell:sender AccessoryButtonTap:selected];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYPAssetModel * model = [self.dataSource objectAtIndex:indexPath.row];

    if (model.asset.mediaType == PHAssetMediaTypeVideo) {
        HYPAssetViewController * avc = [[HYPAssetViewController alloc] init];
        avc.model = model;
        [self.navigationController pushViewController:avc animated:YES];
        return;
    }
    
    HYPPreviewViewController * previewVC = [[HYPPreviewViewController alloc]init];
    previewVC.dataSource = self.dataSource;
    previewVC.selectedItems = self.selectedModels;
    previewVC.currenIndexPath = indexPath;
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)collectionViewCell:(HYPCollectionViewCell *)cell AccessoryButtonTap:(BOOL)selected {
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    HYPAssetModel * model = [self.dataSource objectAtIndex:indexPath.row];

    BOOL isReloadAll = NO;
    
    if (!selected) {
        if (self.selectedModels && self.selectedModels.count >= self.maxSelectedNumber) {
            NSLog(@"达到最大可选择数");
            return;
        }
        // 小于最大可选择数
        model.isSelected = YES;
        [self.selectedModels addObject:model];
        
        [self.selectedIndexPaths addObject:indexPath];
        [self.indexPathsForAnimation addObject:indexPath];
        [cell setSelectedIndex:self.selectedModels.count];
        
        if (self.selectedModels.count == self.maxSelectedNumber) {
            isReloadAll = YES;
            [self.collectionView reloadData];
        } else {
            [self.indexPathsForAnimation removeObject:indexPath];
            [cell animationKeyframes];
        }
        
    } else {
        model.isSelected = NO;
        [self.selectedModels removeObject:model];
        
        [self.selectedIndexPaths removeObject:indexPath];
        [cell setSelectedIndex: -1];
        [self.collectionView reloadItemsAtIndexPaths:self.selectedIndexPaths];
        
        if (self.selectedModels.count == self.maxSelectedNumber - 1) {
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
    }
    [self refreshBottomBar];
}

- (void)setAllowsSelection:(UICollectionView *)collectionView {
    if (collectionView.allowsSelection) {
        self.navigationItem.rightBarButtonItem.title = @"取消";
        collectionView.allowsSelection = NO;
        collectionView.allowsMultipleSelection = YES;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"选择";
        collectionView.allowsSelection = YES;
        collectionView.allowsMultipleSelection = NO;
    }
}

@end
