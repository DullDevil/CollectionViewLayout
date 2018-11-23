//
//  WaterfallViewController.m
//  LayoutDemo
//
//  Created by zhanggy on 2018/11/22.
//  Copyright © 2018 xporter. All rights reserved.
//

#import "WaterfallViewController.h"
#import "DDWaterfallLayout.h"

@interface DDCollectionHeaderView : UICollectionReusableView

@end

@implementation DDCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        label.text = @"Collection Header";
        [self addSubview:label];
        self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

@end

@interface DDTextCollectionReusableView : UICollectionReusableView

@end

@implementation DDTextCollectionReusableView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        label.text = @"dsadsadasdsa";
        [self addSubview:label];
    }
    return self;
}

@end

@interface WaterfallViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, DDCollectionViewLayoutDelegate>
@property (strong, nonatomic) UICollectionView *waterfallLayoutCollectionView;
@property (nonatomic, strong) DDWaterfallLayout *layout;
@end

@implementation WaterfallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"瀑布流";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waterfallLayoutCollectionView];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(changeHeader)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)changeHeader {
    [_waterfallLayoutCollectionView reloadData];
    
}

#pragma mark - deleagte
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 80;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.layer.zPosition = -1;
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];

    if (indexPath.section % 3 == 0) {
        view.backgroundColor = [UIColor redColor];
    } else if (indexPath.section % 3 == 1) {
        view.backgroundColor = [UIColor yellowColor];
    } else {
        view.backgroundColor = [UIColor blueColor];
    }

    return view;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DDWaterfallLayout *)layout heightOfItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    return 120 + arc4random() % 40;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDWaterfallLayout *)layout numberOfColumnsAtSection:(NSInteger)section {
    return 3;
}

- (CGSize)headerSizeForCollectionView:(UICollectionView *)collectionView layout:(DDWaterfallLayout *)layout {
    return CGSizeMake(CGRectGetWidth(self.view.bounds), 200);
}
#pragma mark - setter && getter

- (UICollectionView *)waterfallLayoutCollectionView {
    if (!_waterfallLayoutCollectionView) {
        _layout = [[DDWaterfallLayout alloc] init];
        _layout.delegate = self;
        _layout.headerViewHeight = 120;
        _layout.sectionHeadersPinToVisibleBounds = YES;
        [_layout registerCollectionHeaderClass:[DDCollectionHeaderView class]];
        
        _waterfallLayoutCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
        
        _waterfallLayoutCollectionView.dataSource = self;
        _waterfallLayoutCollectionView.delegate = self;
        _waterfallLayoutCollectionView.backgroundColor = [UIColor grayColor];
        [_waterfallLayoutCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        [_waterfallLayoutCollectionView registerClass:[DDTextCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    return _waterfallLayoutCollectionView;
}

@end
