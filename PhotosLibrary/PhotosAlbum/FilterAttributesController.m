//
//  FilterAttributesController.m
//  PhotosLibrary
//
//  Created by Peng on 2018/12/5.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "FilterAttributesController.h"

#import "HYPAlbumViewController.h"
#import "HYPAssetModel.h"
#import "HYPFilterHelper.h"

#import "CIFilterAttribute.h"

#define UICellReuseIdentifier0 @"UICellReuseIdentifier0"
#define UICellReuseIdentifier1 @"UICellReuseIdentifier1"

#import "GeometryExtension.h"
#import "UITableViewCell+AccessoryButton.h"

@interface NSObject (JSONString)

@end

@implementation NSObject (JSONString)

- (NSString *)JSONString {
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    }
    return [[NSString alloc] initWithData:[self JSONData] encoding:NSUTF8StringEncoding];
}

- (NSData *)JSONData {
    if ([self isKindOfClass:NSData.class]) {
        return (NSData *)self;
    }
    else if ([self isKindOfClass:NSString.class]) {
        return [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:0 error:nil];
}

- (id)JSONObject {
    if ([self isKindOfClass:NSString.class]) {
        return self;
    }
    else if ([self isKindOfClass:NSData.class]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:0 error:nil];
    }
    return self;
}

@end

typedef NS_ENUM(NSUInteger, CellAccessoryActionType) {
    CellAccessoryActionTypeDefault,
    CellAccessoryActionTypeReset,
};

@interface AttributeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * classNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * descLabel;

@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (nonatomic) CellAccessoryActionType accessoryActionType;
@end

@implementation AttributeCell

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    if (view) {
        [self setupAccessoryActionType];
    }
    return view;
}

- (void)setupAccessoryActionType {
    self.accessoryActionType = CellAccessoryActionTypeDefault;
}

- (IBAction)resetAccessoryAction:(UIButton *)sender {
    self.accessoryActionType = CellAccessoryActionTypeReset;
    [self sendAccessoryButtonTappedActionToTableView:sender forEvent:nil];
}

@end

@interface SliderCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * minimumLable;
@property (nonatomic, weak) IBOutlet UILabel * maxinumLabel;

@property (nonatomic, weak) IBOutlet UILabel * label;

@property (nonatomic, weak) IBOutlet UISlider * slider;

@property (nonatomic, copy) void(^valueChanged)(SliderCell * cell, CGFloat value);

@end

@implementation SliderCell

- (void)setMinimum:(CGFloat)minimum {
    self.slider.minimumValue = minimum;
    self.minimumLable.text = [NSString stringWithFormat:@"%.2f", minimum];
}
- (void)setAccessibilityCustomActions:(NSArray<UIAccessibilityCustomAction *> *)accessibilityCustomActions {
    
}
- (void)setMaximum:(CGFloat)maxmum {
    self.slider.maximumValue = maxmum;
    self.maxinumLabel.text = [NSString stringWithFormat:@"%.2f", maxmum];
}

- (void)setSliderValue:(CGFloat)value {
    self.label.text = [NSString stringWithFormat:@"%.4f", value];
    self.slider.value = value;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.label.text = [NSString stringWithFormat:@"%.4f", sender.value];
    self.valueChanged(self, sender.value);
    
}
- (IBAction)sliderValueChange:(UISlider *)sender forEvent:(UIEvent *)event {
    [self sliderValueChanged:sender];
    
//    [self sendAccessoryButtonTappedActionToTableView:nil forEvent:event];
}

- (IBAction)resetAction:(UIButton *)sender {
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    NSLog(@"%@ - %zi", view, event.type);
    return view;
}

@end

#define UITableViewCellReuseIdentifier @"UITableViewCellReuseIdentifier"

#import "CustomView/HYPView.h"

@interface FilterAttributesController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

// indexPath 表。保存当前 cell 对应的 indexPath。
@property (nonatomic, strong) NSMutableDictionary * cellMap;
@property (nonatomic, strong) NSString * cellID;
@property (nonatomic, strong) NSIndexPath * currentIndexPath;

@property (nonatomic, weak) HYPTopBar * topBar;

@property (nonatomic, weak) UIImageView * imageView;
@property (nonatomic, getter=isOpenLight) BOOL openLight; // 控制 imageView 背景色

@end

@interface FilterAttributesController (ColorPicker)<UIColorPickerViewControllerDelegate>

//@property (nonatomic, copy) void(^pickColorCompletionhander)(UIColor * color);

- (void)pickColor:(void(^)(UIColor * color))pickColorCompletionhander;

@end

@implementation FilterAttributesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.FilterAttributesValueChangedBlock(self.filter, @{});
}

- (void)setup {
    [self initDataSource];
    
    self.view.backgroundColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:40/255.0 alpha:1.0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(topBarRightItemsAction:)];
    
    UITableView * tableView = [[UITableView alloc] init];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.frame = self.view.bounds;
    
    [tableView registerNib:[UINib nibWithNibName:@"AttributeCell" bundle:nil] forCellReuseIdentifier:UICellReuseIdentifier0];
    [tableView registerNib:[UINib nibWithNibName:@"SliderCell" bundle:nil] forCellReuseIdentifier:UICellReuseIdentifier1];
    [self.view addSubview:tableView];
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    self.title = self.filter.name;
    
    [self initTopBar];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    self.openLight = NO;
}

- (UIEdgeInsets)yp_safeAreaInsets {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (TARGET_OS_TV) {return safeAreaInsets;}
    
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
    } else {
//         Fallback on earlier versions
        if (!UIApplication.sharedApplication.statusBarHidden) {
            safeAreaInsets.top = 20;
        }
    }
    return safeAreaInsets;
}

- (void)initTopBar {
    CGRect frame = self.view.bounds;
    frame.size.height = 44;
    
//    UIEdgeInsets safeAeraInsets = [self yp_safeAreaInsets];
//    frame.origin.y = safeAeraInsets.top; /* Set at `viewDidLayout` */
    
    HYPTopBar * topBar = [[HYPTopBar alloc] initWithFrame:frame];
    [self.view addSubview:topBar];
    
    _topBar = topBar;
    _topBar.title = _filter.name;
}

- (void)setupDefault:(CIFilterAttribute *)att {
    if ([att.attClassName isEqualToString:NSStringFromClass([NSAttributedString class])]) {
        NSMutableAttributedString * attstr = [[NSMutableAttributedString alloc] initWithString:@"我是一个带有属性的字符串" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor grayColor]}];
        
        [attstr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName: UIColor.orangeColor} range:NSMakeRange(5, 3)];
        att.value = attstr;
    }
    else if ([att.attClassName isEqualToString:NSStringFromClass([NSString class])]) {
        att.value = @"你想要的文本";
    }
}

#define CORE_IMAGE_FILTER_REFERENCE_URL @"https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP30000136-SW29"

- (void)initDataSource {
    NSArray * inputKeys = [self.filter inputKeys];
    NSMutableArray * dataSource = [[NSMutableArray alloc] initWithCapacity:inputKeys.count];
    
    CGRect extent = self.view.bounds;
    extent.size = CGSizeFromScale(extent.size, UIScreen.mainScreen.scale);
    if ([inputKeys containsObject:kCIInputImageKey]) {
        CIImage * inputImage = [_filter valueForKey:kCIInputImageKey];
        extent = inputImage.extent;
    }
//    if ([self.filter.name containsString:@"codeGenerator"]) {
        // 条形码生成器
        if ([inputKeys containsObject:@"inputMessage"]) {
            NSString * message = CORE_IMAGE_FILTER_REFERENCE_URL;
            [self.filter setValue:[message dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
        }
//    }
    
    for (NSString * inputKey in inputKeys) {
        NSDictionary * attribute = [[self.filter attributes] objectForKey:inputKey];
        CIFilterAttribute * att = [[CIFilterAttribute alloc] initWithInputKey:inputKey attribute:attribute extent:extent];
        id value = [_filter valueForKey:inputKey];
        if (value) { att.value = value; }
        if (!value) {
            [self setupDefault:att];
            [self didChangeAttribute:att];
        }
        
        [dataSource addObject:att];
    }
    _dataSource = dataSource;
    
    _cellMap = [NSMutableDictionary new];
}

- (void)viewLayoutMarginsDidChange {
    [super viewLayoutMarginsDidChange];
    
    CGRect frame = self.view.bounds;
    frame = [self.view convertRect:frame toView:self.view.window];
    
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    
    frame = _topBar.bounds;
    if (safeAreaInsets.top > 0) {
        frame.origin.y = safeAreaInsets.top;
        frame.size.height = 44;
    } else {
        frame.size.height = 56;
    }
    _topBar.frame = frame;
    
    frame = self.view.bounds;
    frame.size.height = CGRectGetWidth(frame) * CGRectGetWidth(frame) / CGRectGetHeight(frame);
    frame.origin.y = safeAreaInsets.top + CGRectGetHeight(_topBar.frame);
    self.imageView.frame = frame;
    frame.origin.y = CGRectGetMaxY(frame);
    frame.size.height = CGRectGetHeight(self.view.bounds) - frame.origin.y;
    self.tableView.frame = frame;
    
    [self updateOutputImage:_filter.outputImage];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.openLight = !self.openLight;
}

- (void)topBarRightItemsAction:(UIBarButtonItem *)sender {
    
}

- (void)didChangeAttribute:(CIFilterAttribute *)attrubite {
    [self.filter setValue:attrubite.value forKey:attrubite.inputKey];
    if ([attrubite.inputKey hasSuffix:@"CubeDimension"]) {
        
    }
    CIImage * outputImage = self.filter.outputImage;
    [self updateOutputImage:outputImage];
}

- (void)updateOutputImage:(CIImage *)outputImage {
//    CIImage * outputImage = self.filter.outputImage;
    CGRect extent = outputImage.extent;
    if (extent.size.width > pow(10, 4)) {
        extent = self.imageView.bounds;
        extent.size = CGSizeFromScale(extent.size, UIScreen.mainScreen.scale);
//        extent.origin = CGPointMake(extent.size.width * -0.5, extent.size.width * 0.5);
        outputImage = [outputImage imageByCroppingToRect:extent];
    }
    
    self.imageView.image = CIImageToUIImage(outputImage);
}

- (void)pickImage:(void(^)(BOOL isSuccess, NSArray * items))completionhandler {
    
    HYPAlbumViewController * avc = [[HYPAlbumViewController alloc] init];
    avc.completion = ^(BOOL isSuccess, NSArray * _Nonnull items) {
        if (!isSuccess) {
            NSLog(@"取消选择");
            return;
        }
        if (items.count < 1) return;
        HYPAssetModel * model = items[0];
        UIImage * image = model.previewImage ? : model.postImage;
        completionhandler(isSuccess, @[image]);
    };
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:avc];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark setter and getter
- (void)setOpenLight:(BOOL)openLight {
    _openLight = openLight;
    if (!_openLight) {
        self.imageView.backgroundColor = UIColor.blackColor;
    }
    else {
        self.imageView.backgroundColor = UIColor.whiteColor;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataSource) {
        return self.dataSource.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        CIFilterAttribute * att = [self.dataSource objectAtIndex:section];
        return att.elementCount + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CIFilterAttribute * att = self.dataSource[indexPath.section];
    
    if (indexPath.row == 0) {
        AttributeCell * cell = (AttributeCell *)[tableView dequeueReusableCellWithIdentifier:UICellReuseIdentifier0 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.1];
        
        NSString * subText = att.attClassName;
        NSString * descText = att.attDisplayName;
        if (att.elementCount > 1) {
            [att.attClassName stringByAppendingString:[NSString stringWithFormat:@"(%zi)", att.elementCount]];
        }
        if (att.attDescription) {
            descText = [NSString stringWithFormat:@"%@ (%@)", descText, att.attDescription];
        }
        cell.titleLabel.text = att.inputKey;
        cell.classNameLabel.text = subText;
        cell.descLabel.text = descText;
        
        cell.rightImageView.backgroundColor = nil;
        cell.rightImageView.image = nil;
        if ([att.attClassName isEqualToString:@"CIColor"] && att.value) {
            cell.rightImageView.backgroundColor = [UIColor colorWithCIColor:att.value];
        }
        else if ([att.attClassName isEqualToString:@"CIImage"] && att.value) {
            cell.rightImageView.image = CIImageToUIImage(att.value);
            CGSize size = CGSizeFromScale(cell.rightImageView.image.size, cell.rightImageView.image.scale);
            cell.descLabel.text = [descText stringByAppendingFormat:@"(%.0fx%.0f)", size.width, size.height ];
        }
        return cell;
    } else {
        
        SliderCell *cell = (SliderCell *)[tableView dequeueReusableCellWithIdentifier:UICellReuseIdentifier1 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColor.clearColor;
        
        [_cellMap setValue:indexPath forKey:[NSString stringWithFormat:@"%p", cell]];
        
        cell.valueChanged = ^(SliderCell *cell, CGFloat value) {
            NSIndexPath * indexPath = self.cellMap[[NSString stringWithFormat:@"%p", cell]];
            CIFilterAttribute * att = self.dataSource[indexPath.section];
            
            NSUInteger index = indexPath.row - 1;
            [att updateValue:value atElementIndex:index];
            
            [self didChangeAttribute:att];
        };
        
        if ([att.attClassName isEqualToString:NSStringFromClass(NSNumber.class)]) {
            float minmum = 0, maxmum = 1, value = 0;
            
            if (att.sliderMinValue) minmum = [(NSNumber *)att.sliderMinValue floatValue];
            if (att.sliderMaxValue) maxmum = [(NSNumber *)att.sliderMaxValue floatValue];
            
            if (att.value) value = [(NSNumber *)att.value floatValue];
            
            [cell setMinimum:minmum];
            [cell setMaximum:maxmum];
            [cell setSliderValue: value];
        }
        else if ([att.attClassName isEqualToString:NSStringFromClass(CIVector.class)]) {
            float minmum = -1, maxmum = 1;
            NSUInteger index = indexPath.row - 1;
            if (att.sliderMinValue) minmum = [(CIVector *)att.sliderMinValue valueAtIndex:index];
            if (att.sliderMaxValue) maxmum = [(CIVector *)att.sliderMaxValue valueAtIndex:index];
            
            [cell setMinimum:minmum];
            [cell setMaximum:maxmum];
            [cell setSliderValue: [(CIVector *)att.value valueAtIndex:index]];
        }
        return cell;
    }
    
    // Configure the cell...

    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) { return 70;}
    return 80;
}

#pragma mark - Table view data delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    self.currentIndexPath = indexPath;
    
    if (indexPath.row != 0) return;
    
    CIFilterAttribute * att = self.dataSource[indexPath.section];
    if (indexPath.row == 0 && [att.attClassName isEqualToString:NSStringFromClass(CIColor.class)]) {
        weakly(self);
        [self pickColor:^(UIColor *color) {
            CIColor * ciColor = [[CIColor alloc] initWithColor:color];
            
            NSIndexPath * indexPath = weakself.currentIndexPath;
            AttributeCell * cell = [weakself.tableView cellForRowAtIndexPath:indexPath];
            cell.rightImageView.backgroundColor = color;
            
            CIFilterAttribute * att = weakself.dataSource[indexPath.section];
            att.value = ciColor;
            
            [weakself didChangeAttribute:att];
        }];
    }
    else if ([att.attClassName isEqualToString:NSStringFromClass(CIImage.class)]) {
        weakly(self);
        [self pickImage:^(BOOL isSuccess, NSArray *items) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = items[0];
                
                NSIndexPath * indexPath = weakself.currentIndexPath;
                AttributeCell * cell = [weakself.tableView cellForRowAtIndexPath:indexPath];
                cell.rightImageView.image = image;
                
                CIFilterAttribute * att = weakself.dataSource[indexPath.section];
                att.value = [[CIImage alloc] initWithImage:image];
                
                [weakself didChangeAttribute:att];
            });
        }];
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    CIFilterAttribute * att = self.dataSource[indexPath.section];
    
    if (indexPath.row == 0) {
        AttributeCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        CellAccessoryActionType actionType = cell.accessoryActionType;
        if (actionType == CellAccessoryActionTypeReset) {
            [att resetValue];
//            cell.imageView.image = nil;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            [self didChangeAttribute:att];
            return;
        }
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"" message:att.attribute.description preferredStyle:UIAlertControllerStyleAlert];
        
        [ac addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:ac animated:YES completion:nil];
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

@end


#import <objc/runtime.h>

#pragma mark - Category (ColorPickerHander)
@implementation FilterAttributesController (ColorPickerHander)

const void * pickColorCompletionhanderKey;
- (void)setPickColorCompletionhander:(void (^)(UIColor *))pickColorCompletionhander {
    objc_setAssociatedObject(self, pickColorCompletionhanderKey, pickColorCompletionhander, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIColor *))pickColorCompletionhander {
    return objc_getAssociatedObject(self, pickColorCompletionhanderKey);
}

- (void)pickColor:(void (^)(UIColor *))pickeColorCompletionhander {
    self.pickColorCompletionhander = pickeColorCompletionhander;
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController * pvc = [[UIColorPickerViewController alloc] init];
        pvc.delegate = self;
        [self presentViewController:pvc animated:YES completion:nil];
        
//        UIColorWell * colorWell = [[UIColorWell alloc] init];
//        [self.view addSubview:colorWell];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - UIColorPickerViewControllerDelegate
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController API_DEPRECATED_WITH_REPLACEMENT("", ios(14.0, 15.0)) {
    
}

- (void)colorPickerViewController:(UIColorPickerViewController *)viewController
                   didSelectColor:(UIColor *)color
                     continuously:(BOOL)continuously API_AVAILABLE(ios(15.0)) {
    
}

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    UIColor * color = viewController.selectedColor;
    
    if (self.pickColorCompletionhander) {
        self.pickColorCompletionhander(color);
        self.pickColorCompletionhander = nil;
    }
}

@end
