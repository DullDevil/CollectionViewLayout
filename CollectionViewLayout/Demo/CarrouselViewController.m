//
//  CarrouselViewController.m
//  LayoutDemo
//
//  Created by zhanggy on 2018/11/22.
//  Copyright © 2018 xporter. All rights reserved.
//

#import "CarrouselViewController.h"
#import "DDCarrouselLayout.h"
@interface CarrouselViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation CarrouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"横向缩放";
    [self.view addSubview:self.collectionView];
}

#pragma mark - deleagte
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark - setter && getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        DDCarrouselLayout *layout = [[DDCarrouselLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds) - 64) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
@end
