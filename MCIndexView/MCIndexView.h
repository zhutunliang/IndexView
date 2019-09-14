//
//  MCIndexView.h
//  sogousearch
//
//  Created by nemo on 2019/9/4.
//  Copyright © 2019 搜狗. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MCIndexViewDelegate <NSObject>
- (void)selectedSectionIndexTitle:(NSString *_Nullable)title atIndex:(NSInteger)index;
@end

@protocol MCIndexViewDataSource <NSObject>
- (NSArray<NSString *> *_Nullable)sectionIndexTitles;

@end

@interface MCIndexView : UIControl

@property (nonatomic, weak, nullable) id<MCIndexViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<MCIndexViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat titleFontSize;
@property (nonatomic, strong, nullable) UIColor * titleColor;
@property (nonatomic, assign) CGFloat marginRight; // indexView 距离屏幕右的间距
@property (nonatomic, assign) CGFloat titleSpace; //index的title之间的距离

- (void)setSelectionIndex:(NSInteger)index;

- (void)tableView:(UITableView *_Nullable)tableView willDisplayHeaderView:(UIView *_Nullable)view forSection:(NSInteger)section;
- (void)tableView:(UITableView *_Nullable)tableView didEndDisplayingHeaderView:(UIView *_Nonnull)view forSection:(NSInteger)section;
// 个人认为，只需要这个 scrollViewDidScroll: 就可以拿到当前在显示的最顶层的section ,不需要上面两个方法
- (void)scrollViewDidScroll:(UIScrollView *_Nonnull)scrollView;

- (void)reload;

@end

NS_ASSUME_NONNULL_END
