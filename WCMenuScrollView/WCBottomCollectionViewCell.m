//
//  WCBottomCollectionViewCell.m
//  WCMenuScrollViewDemo
//
//  Created by weicheng wang on 15/10/9.
//  Copyright © 2015年 weicheng wang. All rights reserved.
//

#import "WCBottomCollectionViewCell.h"

@interface WCBottomCollectionViewCell ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView     *_tableView;
}
@end
@implementation WCBottomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configTableView];
    }
    return self;
}

- (void)configTableView
{
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.contentView addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tcell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tcell"];
    }
    cell.backgroundColor = [UIColor orangeColor];
    cell.textLabel.text = [NSString stringWithFormat:@"标题 %ld",indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"详情 %ld，%ld", indexPath.section,indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

@end
