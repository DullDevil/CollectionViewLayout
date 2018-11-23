//
//  AlignmentViewController.m
//  LayoutDemo
//
//  Created by zhanggy on 2018/11/22.
//  Copyright © 2018 xporter. All rights reserved.
//

#import "AlignmentViewController.h"
#import "DDAlignmentLayout.h"

@interface AlignmentViewController ()<UICollectionViewDataSource,DDAlignmentLayoutDelegate,UICollectionViewDelegate> {
    NSInteger _itemCount;
}
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) DDAlignmentLayout *layout;
@end

@implementation AlignmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _itemCount = 150;
    self.title = @"对齐布局-居中";
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(changeHeader)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)changeHeader {
    _itemCount = 100;
    [self.collectionView reloadData];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemCount;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DDAlignmentLayout *)layout widthOfItemAtIndexPath:(NSIndexPath *)indexPath {
    return arc4random() % 20 + 40;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _layout = [[DDAlignmentLayout alloc] initWithAlignment:DDAlignmentCenter];
        _layout.delegate = self;
        _layout.rowSpacing = 10;
        _layout.columnSpacing = 10;
        _layout.itemHeight = 40;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds) - 64) collectionViewLayout:_layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
@end
