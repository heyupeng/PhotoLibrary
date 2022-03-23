//
//  HYPPreviewViewController.m
//  PhotosLibrary
//
//  Created by Peng on 2018/11/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "HYPPreviewViewController.h"
#import <PhotosUI/PhotosUI.h>

#import "HYPAssetViewController.h"
#import "HYPEditImageViewController.h"

#import "HYPCollectionViewCell.h"
#import "HYPAssetModel.h"
#import "HYPPhotosAlbum.h"

#import "HYPView.h"
static NSString * ImageCellReuseIdentifier = @"PreviewImageCellReuseIdentifier";
static NSString * LivePhotoCellReuseIdentifier = @"LivePhotoCellReuseIdentifier";
static NSString * VideoCellReuseIdentifier = @"VideoCellReuseIdentifier";

@interface HYPNavBar : UIView

@property (nonatomic, strong) UIButton * backBtn;
@property (nonatomic, strong) UIButton * rightBtn;

@end

@interface HYPPreviewCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) PHLivePhotoView * livePhotoView; 
@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@end

@implementation HYPPreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        PHLivePhotoView * livePhotoView = [[PHLivePhotoView alloc] init];
        
        [self.contentView addSubview:livePhotoView];
        _livePhotoView = livePhotoView;
    }
    return _livePhotoView;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        AVPlayerLayer * playLayer = [[AVPlayerLayer alloc] init];
        playLayer.videoGravity = AVLayerVideoGravityResize;
        [self.contentView.layer addSublayer:playLayer];
    }
    
    return _playerLayer;
}

@end


@interface HYPImagePreviewCell : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic, strong) HYPSrollImageView * SrollImageView;

@end

@implementation HYPImagePreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _SrollImageView = [[HYPSrollImageView alloc] initWithFrame:frame];
    _SrollImageView.autoResizeImageView = YES;
    [self.contentView addSubview:_SrollImageView];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _SrollImageView.frame = self.contentView.bounds;
}

@end

@interface HYPVideoPreviewCell : HYPPreviewCollectionViewCell<UIScrollViewDelegate>


@end

@implementation HYPVideoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.contentView.bounds;
}

@end
//@interface HYPImagePreviewCell : UICollectionViewCell<UIScrollViewDelegate>
//
//@property (nonatomic, strong) HYPScrollView * scrollView;
//@property (nonatomic, strong) UIImageView * imageView;
//
//@end
//
//@implementation HYPImagePreviewCell
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//
//    _scrollView = [[HYPScrollView alloc] init];
//    _scrollView.delegate = self;
//    _scrollView.canCancelContentTouches = NO;
//    _scrollView.multipleTouchEnabled =YES;
//    _scrollView.exclusiveTouch = YES;
//    _scrollView.maximumZoomScale = 2.5;
//    _scrollView.minimumZoomScale = 1.0;
//    [self.contentView addSubview:_scrollView];
//
//    [self addObserverForImageViewResizeWhileSetImage];
//    return self;
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    _scrollView.frame = self.contentView.bounds;
//    self.imageView.frame = _scrollView.bounds;
//}
//
//- (void)refreshImageViewCenter {
//    CGPoint center = CGRectGetInnerCenterPoint(_scrollView.bounds);
//    if (_scrollView.contentSize.width > CGRectGetWidth(_scrollView.frame)) {
//        center.x = _scrollView.contentSize.width * 0.5;
//    }
//    if (_scrollView.contentSize.height >CGRectGetHeight(_scrollView.frame)) {
//        center.y = _scrollView.contentSize.height * 0.5;
//    }
//    _imageView.center = center;
//}
//
//#pragma mark - Getter Func
//- (UIImageView *)imageView {
//    if (!_imageView) {
//        UIImageView * imageView = [[UIImageView alloc] init];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [_scrollView addSubview:imageView];
//        _imageView = imageView;
//    }
//    return _imageView;
//}
//
//#pragma mark - ScrollView Delegate
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.imageView;
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    [self refreshImageViewCenter];
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    NSLog(@"EndZooming:%.2f",scale);
///* 增加监听修改imageView size */
////    CGSize contentSize = scrollView.contentSize;
////    contentSize.height = _imageView.image.size.height / _imageView.image.size.width * contentSize.width;
////    scrollView.contentSize = contentSize;
////    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y * 0.5);
//
//    [self refreshImageViewCenter];
//}
//
//#pragma mark - Private Observer Func
//- (void)addObserverForImageViewResizeWhileSetImage {
//    [self addObserver:self forKeyPath:@"imageView.image" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//}
//
//- (void)removeObserverForImageViewResizeWhileSetImage {
//    [self removeObserver:self forKeyPath:@"imageView.image"];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([object isEqual: self] && [keyPath isEqualToString:@"imageView.image"]) {
//        CGSize imageSize = CGSizeZero;
//        UIImage * NewImage = self.imageView.image;
//        if (!NewImage) {
//            return;
//        }
//
//        imageSize = NewImage.size;
//        CGFloat ratio = imageSize.width / imageSize.height;
//
//        CGSize imageViewSize = self.contentView.bounds.size;
//        CGFloat imgViewHeight = imageViewSize.width / ratio;
//        if (imgViewHeight <= CGRectGetHeight(self.contentView.bounds)) {
//            imageViewSize.height = imgViewHeight;
//        } else {
//            imageViewSize.width = imageViewSize.height * ratio;
//        }
//
//        self.imageView.frame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
//        self.imageView.center = CGRectGetInnerCenterPoint(_scrollView.frame);
//    }
//}
//
//#pragma mark - style life
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)dealloc {
//    [self removeObserverForImageViewResizeWhileSetImage];
//}
//@end


@interface HYPPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UICollectionView * collectionView;


@property (nonatomic) NSUInteger maxSelectedNumber;

@property (nonatomic, strong) PHCachingImageManager * imageManager;

// Nav Bar
@property (nonatomic, strong) UIView * navBar;
@property (nonatomic, strong) UIButton * rightBtn;
@property (nonatomic, strong) UILabel * badgeLable;

// Bottom Bar
@property (nonatomic, strong) HYPBottomBar * bottomBar;

@property (nonatomic) BOOL statusBarHidden;
@property (nonatomic) BOOL barHidden;

@end

@implementation HYPPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.collectionView setContentOffset:CGPointMake(self.currenIndexPath.row * CGRectGetWidth(self.collectionView.frame), 0) animated:NO];
    
    [self refreshNavBar];
    [self refreshBottomBar];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.barHidden = !self.barHidden;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
    return [super prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden{
    if (_statusBarHidden == statusBarHidden) {
        return;
    }
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setBarHidden:(BOOL)barHidden {
    _barHidden = barHidden;
    self.statusBarHidden = barHidden;
    _navBar.hidden = !_navBar.hidden;
    _bottomBar.hidden = !_bottomBar.hidden;
}

- (void)setup {
    self.view.backgroundColor = [UIColor colorWithWhite:119/255.0 alpha:1];
    self.statusBarHidden = NO;
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    [self initCollectionView];
    
    [self setCustomNavbar];
    
    [self setCostumBottomBar];

}

- (void)setCustomNavbar {
    CGRect frame = self.view.bounds;
    frame.size.height = 64;
    
    UIView * navBar = [[UIView alloc] init];
    navBar.backgroundColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:0.7];
    [self.view addSubview:navBar];
    navBar.frame = frame;
    _navBar = navBar;
    
    NSString * imageName = @"style_bar_back_white";
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBar addSubview:backBtn];
    backBtn.frame = CGRectMake(10, 20, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBar addSubview:rightBtn];
    rightBtn.frame = CGRectMake(375 - 44 - 10, 20, 44, 44);
    
    imageName = @"style_bar_cell_select_def";
    [rightBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    imageName = @"style_bar_cell_select_num";
    [rightBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateSelected];

    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn = rightBtn;
    
    UILabel * numberLabel = [[UILabel alloc] init];
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [navBar addSubview:numberLabel];
    numberLabel.frame = rightBtn.frame;
    _badgeLable = numberLabel;
}

- (void)backBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnClick:(UIButton *)sender {
    NSInteger maxNumberForSelected = 9;
    BOOL isAdd = NO;
    BOOL isReloadALL = NO; // 8->9 or 9->8
    NSInteger count = self.selectedItems.count;
    
    HYPAssetModel *model = [self.dataSource objectAtIndex:_currenIndexPath.row];

    if (count >= maxNumberForSelected && !model.isSelected) {
        NSLog(@"到达最大可选择数");
    } else {
        model.isSelected = !model.isSelected;
        if (model.isSelected) {
            [self.selectedItems addObject:model];
            isAdd = YES;
            if (count + 1 >= maxNumberForSelected) {
                isReloadALL = YES;
            }
        } else {
            if (count >= maxNumberForSelected) {
                isReloadALL = YES;
            }
            [self.selectedItems removeObject:model];
        }
    }

    [self refreshNavBar];
    [self refreshBottomBar];
    if (isAdd) {
        [self animationKeyframesForView:sender];
    }
}

- (void)refreshNavBar {
    NSInteger badgeValue = self.selectedItems.count;
    NSLog(@"badge:%ld", badgeValue);
    _badgeLable.text = [NSString stringWithFormat:@"%ld", badgeValue];
    
    HYPAssetModel *model = [self.dataSource objectAtIndex:_currenIndexPath.row];
    if (badgeValue > 0 && model.isSelected) {
        NSInteger index = [self.selectedItems indexOfObject:model];
        _badgeLable.text = [NSString stringWithFormat:@"%ld", index + 1];
        _rightBtn.selected = YES;
        _badgeLable.hidden = NO;
    } else {
        _rightBtn.selected = NO;
        _badgeLable.hidden = YES;
    }
}

- (void)setCostumBottomBar {
    CGRect frame = self.view.bounds;
    frame.origin.y = CGRectGetHeight(frame) - 44;
    frame.size.height = 44;
    
    _bottomBar = [[HYPBottomBar alloc] init];
    _bottomBar.frame = frame;
    [self.view addSubview:_bottomBar];
    
    UIButton * leftBtn = _bottomBar.leftBtn;
    leftBtn.layer.cornerRadius = 10;
    
    [leftBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(bottomBarLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton * rightBtn = _bottomBar.rightBtn;
    rightBtn.backgroundColor = [UIColor colorWithRed:0 green:119/255.0 blue:0 alpha:1];
    rightBtn.layer.cornerRadius = 10;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [rightBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(bottomBarRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
 }

- (void)bottomBarLeftBtnClick:(UIButton *)sender {
    [self enterEditView];
}

- (void)bottomBarRightBtnClick:(UIButton *)sender {
}

- (void)refreshBottomBar {
    NSInteger badgeValue = self.selectedItems.count;
    
    NSString * title = @"下一步";
    if (badgeValue) {
        title = [title stringByAppendingString:[NSString stringWithFormat:@"(%ld)", badgeValue]];
    }
    [_bottomBar.rightBtn setTitle:title forState:UIControlStateNormal];
}

- (void)animationKeyframesForView:(UIView *)view {
    [UIView animateKeyframesWithDuration:0.15 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.15 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)initCollectionView {
    float n = 1, lineSpacing = 5;
    float itemWidth = CGRectGetWidth([self.view bounds]);
    itemWidth /= n;
    CGSize itemSize = CGSizeMake(itemWidth, CGRectGetHeight([self.view bounds]));
    
    // FlowLayout
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, lineSpacing, 0, lineSpacing);
    layout.itemSize = itemSize;
    layout.minimumInteritemSpacing = lineSpacing * 2;
    layout.minimumLineSpacing = lineSpacing * 2;
    
    // CollectionView
    CGRect frame = self.view.bounds;
    frame.size.width += lineSpacing * 2;
    frame.origin.x = - lineSpacing;
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    collectionView.canCancelContentTouches = NO;
    collectionView.multipleTouchEnabled = YES;
    
    [collectionView registerClass:[HYPImagePreviewCell class] forCellWithReuseIdentifier:ImageCellReuseIdentifier];
    
    [collectionView registerClass:[HYPVideoPreviewCell class] forCellWithReuseIdentifier:VideoCellReuseIdentifier];
}

- (void)loadData {
    [self.collectionView reloadData];
}

- (void)enterEditView {
    HYPAssetModel * model = [self.dataSource objectAtIndex:_currenIndexPath.row];
    
    if (model.asset.mediaType == PHAssetMediaTypeImage) {
        HYPEditImageViewController * assetVC = [[HYPEditImageViewController alloc] init];
        assetVC.model = model;
        [self.navigationController pushViewController:assetVC animated:NO];
        
        return;
    }
    HYPAssetViewController * assetVC = [[HYPAssetViewController alloc] init];
    assetVC.model = model;
    [self.navigationController pushViewController:assetVC animated:NO];
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
//    PHFetchResultChangeDetails * changeDetails = [changeInstance changeDetailsForFetchResult:self.result];
//    if (!changeDetails || !changeDetails.hasIncrementalChanges) {
//        return;
//    }
//    PHFetchResult * fetchResult = changeDetails.fetchResultAfterChanges;
//    self.result = fetchResult;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView performBatchUpdates:^{
//            NSIndexSet * indexes = changeDetails.changedIndexes;
//            if (indexes || indexes.count > 0) {
//
//            }
//        } completion:^(BOOL finished) {
//
//        }];
//    });
}

#pragma mark - CollectionView ScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        CGPoint offset = scrollView.contentOffset;
        NSInteger index = (offset.x + CGRectGetWidth(self.collectionView.frame) * 0.5) / CGRectGetWidth(self.collectionView.frame);
        if (index == _currenIndexPath.row) {
            return;
        }
        _currenIndexPath =  [NSIndexPath indexPathForRow:index inSection:_currenIndexPath.section];
        [self refreshNavBar];
    }
   
}

#pragma mark - CollectionView dataSource and delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource? self.dataSource.count: 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HYPImagePreviewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCellReuseIdentifier forIndexPath:indexPath];
    
    HYPAssetModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.asset.mediaType == PHAssetMediaTypeVideo) {
        
    }
    
    if (model.originImage) {
        cell.SrollImageView.imageView.image = model.originImage;
    } else {
        CGSize size = CGSizeZero;
        CGFloat pixelRatio = model.asset.pixelWidth / (CGFloat)model.asset.pixelHeight;
        CGFloat itemWidth = CGRectGetWidth(cell.frame);
        size = CGSizeMake(itemWidth * 2, itemWidth * 2/pixelRatio);

        PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.networkAccessAllowed = true;
        
        [self.imageManager requestImageForAsset:model.asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (!result) {
//                cell.imageView.image = model.image;
                return ;
            }
            if ([[info objectForKey:PHImageResultIsDegradedKey] intValue] == 0) {
                model.previewImage = result;
                if ([info objectForKey:@"PHImageFileURLKey"]) {
                    model.originImage = result;
                }
                model.originImage = result;
            }
            cell.SrollImageView.imageView.image = result;
        }];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.barHidden = !self.barHidden;
}

@end
