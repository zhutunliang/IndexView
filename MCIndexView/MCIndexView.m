//
//  MCIndexView.m
//  sogousearch
//
//  Created by nemo on 2019/9/4.
//  Copyright © 2019 搜狗. All rights reserved.
//

#import "MCIndexView.h"

@interface MCIndexView ()
@property (nonatomic, copy) NSArray<NSString *> *indexItems;                        /**< 组标题数组 */
@property (nonatomic, strong) NSMutableArray<UILabel *> *itemsViewArray;            /**< 标题视图数组 */
@property (nonatomic, assign) NSInteger selectedIndex;                              /**< 当前选中下标 */
@property (nonatomic, assign) CGFloat minY;                                         /**< Y坐标最小值 */
@property (nonatomic, assign) CGFloat maxY;                                         /**< Y坐标最大值 */
@property (nonatomic, assign) CGSize itemMaxSize;                                   /**< item大小，参照W大小设置 */
@property (nonatomic, strong) UIImageView *selectedImageView;                       /**< 当前选中item的背景圆 */
@property (nonatomic, assign) BOOL isCallback;                                      /**< 是否需要调用代理方法，如果是scrollView自带的滚动，则不需要触发代理方法，如果是滑动指示器视图，则触发代理方法 */
@property (nonatomic, assign) BOOL isUpScroll;                                      /**< 是否是上拉滚动 */
@property (nonatomic, assign) BOOL isFirstLoad;                                     /**< 是否第一次加载tableView */
@property (nonatomic, assign) CGFloat oldY;                                         /**< 滚动的偏移量 */
@property (nonatomic, assign) BOOL isAllowedChange;                                 /**< 是否允许改变当前组 */
@property (nonatomic, strong) UIImpactFeedbackGenerator *generator;                 /**< 震动反馈  */
@end

@implementation MCIndexView


#pragma mark - Public

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if(self.isAllowedChange && !self.isUpScroll && !self.isFirstLoad) {
        //最上面组头（不一定是第一个组头，指最近刚被顶出去的组头）又被拉回来
        [self setSelectionIndex:section];  //section
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (self.isAllowedChange && !self.isFirstLoad && self.isUpScroll) {
        //最上面的组头被顶出去
        [self setSelectionIndex:section + 1]; //section + 1
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y > self.oldY) {
//        self.isUpScroll = YES;      // 上滑
//    }
//    else {
//        self.isUpScroll = NO;       // 下滑
//    }
//    self.isFirstLoad = NO;
//
//    self.oldY = scrollView.contentOffset.y;
    
    UITableView *tableView = (UITableView *)scrollView;
   NSInteger firstVisibleSection = tableView.indexPathsForVisibleRows[0].section;
    self.selectedIndex = firstVisibleSection;
}



- (void)reload {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(sectionIndexTitles)]) {
        self.indexItems = [self.dataSource sectionIndexTitles];
        if (self.indexItems.count == 0) {
            return;
        }
    }
    else {
        return;
    }
    self.selectedIndex = 0;
    //初始化属性设置
    [self attributeSettings];
    //初始化title
    [self initialiseAllTitles];
}

- (void)didMoveToSuperview {
    [self reload];
}

#pragma mark - 外部传入当前选中组
- (void)setSelectionIndex:(NSInteger)index {
    if (index >= 0 && index <= self.indexItems.count) {
        //改变组下标
        self.isCallback = NO;
        self.selectedIndex = index;
    }
}

- (void)attributeSettings {
     self.titleFontSize = 11;
     self.marginRight = 4;
    self.titleSpace = 4;
     self.itemMaxSize = CGSizeMake(13, 13);
    //默认就允许滚动改变组
    self.isAllowedChange = YES;
    
    self.isFirstLoad = YES;
}

- (void)initialiseAllTitles {
    //清除缓存
    for (UIView *subview in self.itemsViewArray) {
        [subview removeFromSuperview];
    }
    [self.itemsViewArray removeAllObjects];
    self.selectedImageView.layer.mask = nil;
    self.selectedImageView.frame = CGRectZero;
   
    
    NSInteger itemCount = self.indexItems.count;
    CGFloat WH = 13;
    CGFloat totalHeight =  itemCount * WH + (itemCount - 1) * self.titleSpace;
    
    //高度是否符合
//    CGFloat totalHeight = (self.indexItems.count * self.titleFontSize) + ((self.indexItems.count + 1) * self.titleSpace);
    if (CGRectGetHeight(self.frame) < totalHeight) {
        NSLog(@"View height is not enough");
        return;
    }
    //宽度是否符合
//    CGFloat totalWidth = self.titleFontSize + self.marginRight;
//    if (CGRectGetWidth(self.frame) < totalWidth) {
//        NSLog(@"View width is not enough");
//        return;
//    }
    //设置Y坐标最小值 --  居中
    self.minY = (CGRectGetHeight(self.frame) - totalHeight) / 2.0;
    CGFloat startY = self.minY  + self.titleSpace;
    //标题视图布局
    for (int i = 0; i < itemCount; i++) {
        NSString *title = self.indexItems[i];
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - self.marginRight - self.titleFontSize, startY, self.itemMaxSize.width, self.itemMaxSize.height)];
       itemLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:self.titleFontSize];
        itemLabel.textColor = [UIColor blackColor];
        itemLabel.text = title;
        itemLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.itemsViewArray addObject:itemLabel];
        [self addSubview:itemLabel];
        //重新计算start Y
        startY = startY + self.itemMaxSize.height + self.titleSpace;
    }
    //设置Y坐标最大值
    self.maxY = startY;
}

#pragma mark - 事件处理
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    //滑动期间不允许scrollview改变组
    self.isAllowedChange = NO;
    [self selectedIndexByPoint:location];
    if (@available(iOS 10.0, *)) {
      self.generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    [self selectedIndexByPoint:location];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    
    if (location.y < self.minY || location.y > self.maxY) {
        return;
    }
    
    //重新计算坐标
    [self selectedIndexByPoint:location];
    
    //滑动结束后，允许scrollview改变组
    self.isAllowedChange = YES;
    self.generator = nil;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    //滑动结束后，允许scrollview改变组
    self.isAllowedChange = YES;
    self.generator = nil;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //滑动到视图之外时的处理
    [self cancelTrackingWithEvent:event];
}


#pragma mark - 根据Y坐标计算选中位置，当坐标有效时，返回YES
- (void)selectedIndexByPoint:(CGPoint)location {
    if (location.y >= self.minY && location.y <= self.maxY) {
        //计算下标
        NSInteger offsetY = location.y - self.minY - (self.titleSpace / 2.0);
        //单位高
        CGFloat item = self.itemMaxSize.height + self.titleSpace;
        //计算当前下标
        NSInteger index = (offsetY / item) ;//+ ((offsetY % item == 0)?0:1) - 1;
        NSLog(@"当前选中的index---%ld",index);
        if (index != self.selectedIndex && index < self.indexItems.count && index >= 0) {
            self.isCallback = YES;
            self.selectedIndex = index;
            if (@available(iOS 10.0, *)) {
                [self.generator prepare];
                [self.generator impactOccurred];
            }
        }
    }
}

#pragma mark - setter

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    NSInteger newIndex = selectedIndex;
    NSInteger oldIndex = _selectedIndex;
    if (oldIndex >= 0 && oldIndex < self.itemsViewArray.count) {
        UILabel *oldItemLabel = self.itemsViewArray[oldIndex];
        oldItemLabel.textColor = [UIColor blackColor];
        self.selectedImageView.frame = CGRectZero;
    }
    if (newIndex >= 0 && newIndex < self.itemsViewArray.count) {
        
        UILabel *newItemLabel = self.itemsViewArray[newIndex];
        newItemLabel.textColor = [UIColor whiteColor];
        //处理选中圆形
        CGFloat diameter = self.itemMaxSize.height + self.titleSpace;
        self.selectedImageView.frame = CGRectMake(0, 0, diameter, diameter);
        self.selectedImageView.center = newItemLabel.center;
        self.selectedImageView.layer.mask = [self imageMaskLayer:self.selectedImageView.bounds radiu:diameter/2.0];
        [self insertSubview:self.selectedImageView belowSubview:newItemLabel];
        
        //回调代理方法
        if (self.isCallback && self.delegate && [self.delegate respondsToSelector:@selector(selectedSectionIndexTitle:atIndex:)]) {
            [self.delegate selectedSectionIndexTitle:self.indexItems[newIndex] atIndex:newIndex];
        }
        
    }
    
    _selectedIndex = selectedIndex;
}

#pragma mark - Lazy load

- (NSMutableArray *)itemsViewArray {
    if (!_itemsViewArray) {
        _itemsViewArray = [NSMutableArray array];
    }
    return _itemsViewArray;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.backgroundColor = [UIColor greenColor];
    }
    return _selectedImageView;
}

- (CAShapeLayer *)imageMaskLayer:(CGRect)bounds radiu:(CGFloat)radiu {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radiu, radiu)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

#pragma mark - life cycle

- (void)dealloc {
    self.generator = nil;
}

@end
