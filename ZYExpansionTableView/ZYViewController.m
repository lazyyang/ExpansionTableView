//
//  ZYViewController.m
//  ZYExpansionTableView
//
//  Created by SMIT on 14-6-5.
//  Copyright (c) 2014年 ZY. All rights reserved.
//

#import "ZYViewController.h"

@interface ZYViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *mytableview;
@property (assign,nonatomic) BOOL isOpen;
@property (nonatomic,strong) NSIndexPath *selectIndex;
@property (nonatomic,strong) NSMutableArray *itemsArray;

@end

@implementation ZYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MyTableTestData" ofType:@"plist"];
    _itemsArray = [[NSMutableArray alloc]initWithContentsOfFile:path];
    
    _mytableview = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _mytableview.delegate = self;
    _mytableview.dataSource = self;
    [self.view addSubview:_mytableview];
    
    self.mytableview.sectionFooterHeight = 0;
    self.mytableview.sectionHeaderHeight = 0;
    self.isOpen = NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _itemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return [[_itemsArray[section] objectForKey:@"list"] count] + 1;
        }
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpen&&self.selectIndex.section == indexPath.section &&indexPath.row != 0) {
        static NSString *cellID = @"CellTwo";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]init];
        }
        cell.backgroundColor = [UIColor redColor];
        NSArray *list = [_itemsArray[indexPath.section] objectForKey:@"list"];
        cell.textLabel.text = list[indexPath.row-1];
        return cell;
    }
    else{
        static NSString *cellID = @"CellOne";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]init];
        }
        NSString *title = [_itemsArray[indexPath.section] objectForKey:@"name"];
        cell.textLabel.text = title;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            //关闭
            [self openOrClosedFirst:NO next:NO];
            self.selectIndex = nil;
        }
        else{//打开
            if (!self.selectIndex) {//没有其它的打开
                self.selectIndex = indexPath;
                self.isOpen = YES;
                [self openOrClosedFirst:YES next:NO];
            }
            else{
                self.isOpen = NO;
                [self openOrClosedFirst:NO next:YES];//关闭之前的，打开现在选择的
            }
        }
        
    }
    else{
        NSLog(@"选中数字");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中
}

/**
 *  打开关闭内容
 *
 *  @param firstState 若为NO代表关闭之前打开的，为YES则打开选择的
 *  @param nextState  若为YES，则需要关闭之前打开的
 */
- (void)openOrClosedFirst:(BOOL)firstState next:(BOOL)nextState
{
    [self.mytableview beginUpdates];
    
    int section = self.selectIndex.section;
    int contentCount = [[_itemsArray[section] objectForKey:@"list"] count];
    NSMutableArray *rowToInsert = [[NSMutableArray alloc]init];
    for (int i = 1; i < contentCount + 1; i ++) {
        NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
        [rowToInsert addObject:indexPathToInsert];
    }
    
    if (firstState) {
        [self.mytableview insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    else{
        [self.mytableview deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.mytableview endUpdates];
    
    if (nextState) {
        self.isOpen = YES;
        self.selectIndex = [self.mytableview indexPathForSelectedRow];
        [self openOrClosedFirst:YES next:NO];
    }
    
    if (self.isOpen) {
        [self.mytableview scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
