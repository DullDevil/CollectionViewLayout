//
//  ViewController.m
//  CollectionViewLayout
//
//  Created by zhanggy on 2018/11/23.
//  Copyright © 2018 xporter. All rights reserved.
//

#import "ViewController.h"
#import "WaterfallViewController.h"
#import "CarrouselViewController.h"
#import "AlignmentViewController.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate> {
    NSArray *_dataArray;
}

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    _dataArray = @[@"Collection-瀑布流",@"Collection-横向缩放",@"Collection-对齐布局"];
    
}

#pragma mark - deleagte

#pragma mark ---UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

#pragma mark ---UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[WaterfallViewController alloc] init] animated:YES];
    } if (indexPath.row == 1) {
        [self.navigationController pushViewController:[[CarrouselViewController alloc] init] animated:YES];
    } if (indexPath.row == 2) {
        [self.navigationController pushViewController:[[AlignmentViewController alloc] init] animated:YES];
    }
}
@end
