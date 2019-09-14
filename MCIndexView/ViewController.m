//
//  ViewController.m
//  MCIndexView
//
//  Created by nemo on 2019/9/14.
//  Copyright © 2019 nemo. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Additions.h"
#import "MCIndexView.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,MCIndexViewDelegate,MCIndexViewDataSource>
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSDictionary *dataArray;
@property (nonatomic ,strong) NSArray *indexArray;
@property (nonatomic ,strong) MCIndexView *indexView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadUI];
    [self loadData];
}

- (void)loadUI {
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 88, self.view.width, self.view.height - 88) style:UITableViewStylePlain];
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.indexView = [[MCIndexView alloc]initWithFrame:CGRectMake(self.tableView.width - 30, 66 + 88, 30, self.view.height - 66 - 88)];
    self.indexView.delegate = self;
    self.indexView.dataSource = self;
    [self.view addSubview:self.indexView];
    self.indexView.backgroundColor = [UIColor redColor];
    [self.view bringSubviewToFront:self.indexView];
}

- (void)loadData {
    self.indexArray = @[@"#",@"A",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"X",@"Y",@"Z"];
    self.dataArray = @{@"#":@[@"KO",@"JO",@"MO"],@"A":@[@"AO",@"AP",@"AL",@"AO",@"AP",@"AL"],@"C":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"D":@[@"DP",@"DQ",@"DG",@"AO",@"AP",@"AL"],@"E":@[@"CP",@"CQ",@"CG"],@"F":@[@"CP",@"CQ",@"CG"],@"G":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"H":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"I":@[@"CP",@"CQ",@"CG"],@"J":@[@"CP",@"CQ",@"CG"],@"K":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"L":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"M":@[@"CP",@"CQ",@"AP",@"AL",@"AO",@"AP",@"AL"],@"N":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"X":@[@"CP",@"CQ",@"CG"],@"Y":@[@"CP",@"CQ",@"CG",@"AO",@"AP",@"AL"],@"Z":@[@"ZP",@"ZQ",@"CG",@"AO",@"AP",@"AL"]};
    [self.indexView reload];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.indexArray[section];
    NSArray *sectionArray = [self.dataArray objectForKey:key];
    return sectionArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSString *key = self.indexArray[indexPath.section];
    NSArray *sectionArray = [self.dataArray objectForKey:key];
    NSString *title = sectionArray[indexPath.row];
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.indexArray[section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.indexView scrollViewDidScroll:scrollView];
}

#pragma mark - MCIndexViewDataSource

- (NSArray<NSString *> *_Nullable)sectionIndexTitles {
    return self.indexArray;
}

#pragma mark - MCIndexViewDelegate

- (void)selectedSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
