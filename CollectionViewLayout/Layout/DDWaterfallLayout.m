//
//  DDCollectionViewLayout.m
//  CollectionViewDemo
//
//  Created by 张桂杨 on 2017/4/27.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDWaterfallLayout.h"

static NSString *kCollectionHeader = @"CollectionHeader";

@interface DDWaterfallLayout (){
    CGFloat _itemWidth;
    
    CGPoint _startContentOffset;
    BOOL _needReloadData;
    
    NSInteger _sectionsCount;
    
    BOOL _hasInitStartContentOffset;
    
    
    Class _headerClass;
    
    CGFloat _oldContentOffsetY;
    
    BOOL _willChangeBound;
    
}
@property (nonatomic, strong) UICollectionViewLayoutAttributes *collectionHeaderLayoutAttributes;
@property (strong, nonatomic) NSMutableDictionary *cellLayoutInfo;//保存cell的布局
@property (strong, nonatomic) NSMutableDictionary *headLayoutInfo;//保存头视图的布局
@property (strong, nonatomic) NSMutableDictionary *footLayoutInfo;//保存尾视图的布局

@property (assign, nonatomic) CGFloat startY;//记录开始的Y
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSMutableDictionary *> *maxYForColumn;//记录每个区 每一列 最下面那个cell的底部y值
@property (nonatomic, strong) NSMutableDictionary *startYForSection;
@end


@implementation DDWaterfallLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfColumns = 3;
        self.sectionInset = UIEdgeInsetsZero;
        self.columnSpacing = 10;
        self.rowSpacing = 10;
        
        self.maxYForColumn = [NSMutableDictionary dictionary];
        self.startYForSection = [NSMutableDictionary dictionary];
        self.cellLayoutInfo = [NSMutableDictionary dictionary];
        self.headLayoutInfo = [NSMutableDictionary dictionary];
        self.footLayoutInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    [super invalidateLayoutWithContext:context];
    _needReloadData = context.invalidateDataSourceCounts || context.invalidateEverything;
}

- (void)prepareLayout {
    [super prepareLayout];
    if (_needReloadData) {
        [self loadData];
    } else {
        [self updateHeaderLayout];
    }
    
}

- (void)updateHeaderLayout {
    
    CGFloat pinOffset = self.collectionView.contentOffset.y - _startContentOffset.y;
    NSInteger pinSection = -1;
    if (pinOffset > CGRectGetMaxY(_collectionHeaderLayoutAttributes.frame)) {
        for (NSInteger i = 0; i < _startYForSection.count; i++) {
            if (i < _startYForSection.count - 1) {
                if (pinOffset < [_startYForSection[@(i + 1)] integerValue] && pinOffset >= [_startYForSection[@(i)] integerValue]) {
                    pinSection = i;
                    break;
                }
            } else {
                pinSection = _startYForSection.count - 1;
            }
        }
    }
    
    [self.headLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (indexPath.section == pinSection) {
            UICollectionViewLayoutAttributes *pinAttribute = self.headLayoutInfo[indexPath];
            // 计算悬停位置
            if (pinOffset <= 0) {
                pinAttribute.frame = CGRectMake(0, 0, CGRectGetWidth(self.collectionView.bounds), self->_headerViewHeight);
            } else {
                pinAttribute.frame = CGRectMake(0, pinOffset, CGRectGetWidth(self.collectionView.bounds), self->_headerViewHeight);
            }
            // 做顶上出的效果
            if (pinSection + 1 < self->_sectionsCount) {
                CGFloat nextSectionStartY = [self->_startYForSection[@(pinSection + 1)] floatValue];
                if (nextSectionStartY <= CGRectGetMaxY(pinAttribute.frame)) {
                    pinAttribute.frame = CGRectMake(0, nextSectionStartY - self->_headerViewHeight, CGRectGetWidth(self.collectionView.bounds), self->_headerViewHeight);
                }
            }
        } else if (indexPath.section < pinSection) {
            UICollectionViewLayoutAttributes *attribute = self.headLayoutInfo[indexPath];
            CGFloat startYForSection = [self->_startYForSection[@(indexPath.section + 1)] floatValue];
            attribute.frame = (CGRect){0, startYForSection - CGRectGetHeight(attribute.frame), attribute.frame.size};
        } else {
            UICollectionViewLayoutAttributes *attribute = self.headLayoutInfo[indexPath];
            CGFloat startYForSection = [self->_startYForSection[@(indexPath.section)] floatValue];
            attribute.frame = (CGRect){0, startYForSection, attribute.frame.size};
        }
    }];
    
    
}

- (void)loadData {
    // 有导航栏的时候，整个视图会向下偏移，记录一下偏移值，用于计算区头悬停的位置
    if (!_hasInitStartContentOffset) {
        _startContentOffset = self.collectionView.contentOffset;
        _hasInitStartContentOffset = YES;
    }
    
    self.startY = 0;
    //重新布局需要清空
    [self.cellLayoutInfo removeAllObjects];
    [self.headLayoutInfo removeAllObjects];
    [self.footLayoutInfo removeAllObjects];
    [self.maxYForColumn removeAllObjects];
    [self.startYForSection removeAllObjects];
    
    CGFloat contentWidth = self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right;
    [self calCollectionHeader];
    _sectionsCount = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < _sectionsCount; section++) {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsAtSection:)]) {
            NSInteger numberOfColumnsAtSection = [self.delegate collectionView:self.collectionView layout:self numberOfColumnsAtSection:section];
            if (numberOfColumnsAtSection > 0) {
                _numberOfColumns = numberOfColumnsAtSection;
            }
        }
        
        _itemWidth = (contentWidth - self.columnSpacing * (self.numberOfColumns - 1))/self.numberOfColumns;
        [self calSectionHeaderWithSection:section];
        [self calItemFrameWithSection:section];
    }
    
    CGFloat maxContentOffsetY = self.startY - CGRectGetHeight(self.collectionView.bounds);
    
    if (@available(iOS 11.0, *)) {
        maxContentOffsetY = self.startY - CGRectGetHeight(self.collectionView.bounds) + self.collectionView.safeAreaInsets.bottom;
    }
    
    // 重新布局之后，如果collection不会滚动，则不会再次调用 prepareLayout，将导致不会重新计算区头的位置
    // 如果当前CollectionView 的 contentOffset.y 小于等于 最大可偏移量，则collection 是不会滚动的
    // 此时需要手动更新区头设置
    if (self.collectionView.contentOffset.y <= maxContentOffsetY) {
        [self updateHeaderLayout];
    }
}


#pragma mark - 计算位置
// collection 头部视图
#pragma mark ---Collection Header
- (void)calCollectionHeader {
    if (_headerClass) {
        _collectionHeaderLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kCollectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        if ([self.delegate respondsToSelector:@selector(headerSizeForCollectionView:layout:)]) {
            CGSize headerSize = [self.delegate headerSizeForCollectionView:self.collectionView layout:self];
            _collectionHeaderLayoutAttributes.frame = (CGRect){0, 0, headerSize};
            self.startY = headerSize.height;
        }
    }
}

#pragma mark ---区头
- (void)calSectionHeaderWithSection:(NSInteger)section {
    self.startYForSection[@(section)] = @(self.startY);
    NSIndexPath *supplementaryViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    
    if (_headerViewHeight > 0 && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:supplementaryViewIndexPath];
        attribute.frame = CGRectMake(0, self.startY, CGRectGetWidth(self.collectionView.bounds), _headerViewHeight);
        self.headLayoutInfo[supplementaryViewIndexPath] = attribute;
        self.startY = self.startY + _headerViewHeight + self.sectionInset.top;
    } else {
        //没有头视图的时候，也要设置section的第一排cell到顶部的距离
        self.startY = self.startY + self.sectionInset.top;
    }
}

#pragma mark ---cell
- (void)calItemFrameWithSection:(NSInteger)section {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    self.maxYForColumn[@(section)] = dict;
    for (int i = 0; i < _numberOfColumns; i++) {
        self.maxYForColumn[@(section)][@(i)] = @(self.startY);
    }
    
    NSInteger rowsCount = [self.collectionView numberOfItemsInSection:section];
    for (NSInteger row = 0; row < rowsCount; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGFloat minY = 0;
        NSInteger shorterColumn = [self queryShorterColumnForSection:section resultY:&minY];
        
        CGFloat x = shorterColumn * _itemWidth + self.sectionInset.left + shorterColumn * self.columnSpacing;
        
        CGFloat height = [(id<DDCollectionViewLayoutDelegate>)self.delegate collectionView:self.collectionView layout:self heightOfItemAtIndexPath:indexPath itemWidth:_itemWidth];
        
        attribute.frame = CGRectMake(x, minY, _itemWidth, height);
        self.cellLayoutInfo[indexPath] = attribute;
        
        CGFloat maxY = minY + self.rowSpacing + height;
        self.maxYForColumn[@(section)][@(shorterColumn)] = @(maxY);
        
        if (row == rowsCount -1) {
            for (int i = 0; i < _numberOfColumns; i++) {
                maxY = MAX(maxY, [self.maxYForColumn[@(section)][@(i)] floatValue]);
            }
            self.startY = maxY - self.rowSpacing + self.sectionInset.bottom;
        }
    }
}

- (NSInteger)queryShorterColumnForSection:(NSInteger)section resultY:(CGFloat *)resultY {
    NSInteger shorterColumn = 0;
    CGFloat minY = [self.maxYForColumn[@(section)][@(0)] floatValue];
    for (int i = 1; i < _numberOfColumns; i++) {
        if ([self.maxYForColumn[@(section)][@(i)] floatValue] < minY) {
            minY = [self.maxYForColumn[@(section)][@(i)] floatValue];
            shorterColumn = i;
        }
    }
    *resultY = minY;
    return shorterColumn;
}



#pragma mark - deleagte

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    // 添加当前屏幕可见的collection头视图的布局
    if (_collectionHeaderLayoutAttributes) {
        if (CGRectIntersectsRect(rect, _collectionHeaderLayoutAttributes.frame)) {
            [allAttributes addObject:_collectionHeaderLayoutAttributes];
        }
    }
    
    //添加当前屏幕可见的secton头视图的布局
    [self.headLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    //添加当前屏幕可见的cell的布局
    [self.cellLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, MAX(self.startY, self.collectionView.frame.size.height));
}

//return YES;表示一旦滑动就实时调用上面这个layoutAttributesForElementsInRect:方法
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return self.sectionHeadersPinToVisibleBounds && [self.collectionView.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)] && _headerViewHeight > 0;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellLayoutInfo[indexPath];
}
- (void)registerCollectionHeaderClass:(Class)headerClass {
    _headerClass = headerClass;
    [self registerClass:headerClass forDecorationViewOfKind:kCollectionHeader];
}
@end
