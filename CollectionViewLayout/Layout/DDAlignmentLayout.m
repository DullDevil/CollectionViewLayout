//
//  DDAlignmentLayout.m
//  CollectionViewDemo
//
//  Created by 张桂杨 on 2017/4/28.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDAlignmentLayout.h"

@interface DDAlignmentLayout ()
@property (strong, nonatomic) NSMutableDictionary *cellLayoutInfo;
@property (nonatomic, strong) NSMutableArray *sectionRowsArray;

@property (nonatomic, strong) NSMutableDictionary *totalwidthInfo;
@property (nonatomic, assign) DDAlignmentType alignmentType;
@property (nonatomic, assign) CGFloat totalHeight;
@end

@implementation DDAlignmentLayout
- (instancetype)init {
    self = [super init];
    if (self) {
        self.cellLayoutInfo = [NSMutableDictionary dictionary];
        _alignmentType = DDAlignmentLeft;
    }
    return self;
}

- (instancetype)initWithAlignment:(DDAlignmentType)alignment {
    if (self = [super init]) {
        _alignmentType = alignment;
        self.cellLayoutInfo = [NSMutableDictionary dictionary];
        
    }
    return self;
    
}

- (void)prepareLayout {
    [super prepareLayout];
    self.columnSpacing = 20;
    self.rowSpacing = 20;
    
    [self.cellLayoutInfo removeAllObjects];
    _sectionRowsArray = [NSMutableArray array];
    _totalwidthInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    CGFloat sectionStartY = 0;
    _totalHeight = sectionStartY;
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *rowsArray = [NSMutableArray array];
        CGFloat totalWidth = 0;
        NSInteger row = 0;
        NSMutableArray *itemForRow = [NSMutableArray array];
        for (NSInteger index = 0; index < itemCount; index++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGFloat itemWidth = [self.delegate collectionView:self.collectionView layout:self widthOfItemAtIndexPath:indexPath];
            itemWidth = MIN(CGRectGetWidth(self.collectionView.frame), itemWidth);
            
            CGFloat lineSpacing = self.minimumLineSpacing * itemForRow.count;
            if (totalWidth + itemWidth + lineSpacing > CGRectGetWidth(self.collectionView.frame)) {
                [rowsArray addObject:[itemForRow mutableCopy]];
                [itemForRow removeAllObjects];
                [_totalwidthInfo setValue:@(totalWidth) forKey:[NSString stringWithFormat:@"%td--%td", section, row]];
                row++;
                attribute.frame = CGRectMake(0, row * (self.itemHeight + self.rowSpacing) + sectionStartY, itemWidth, self.itemHeight);
            } else {
                if (index == 0) {
                    attribute.frame = CGRectMake(0, row * (self.itemHeight + self.rowSpacing) + sectionStartY, itemWidth, self.itemHeight);
                } else {
                    attribute.frame = CGRectMake(totalWidth + self.columnSpacing, row * (self.itemHeight + self.rowSpacing) + sectionStartY, itemWidth, self.itemHeight);
                }
            }
            totalWidth = CGRectGetMaxX(attribute.frame);
            [itemForRow addObject:attribute];
            if (index == itemCount - 1) {
                [_totalwidthInfo setValue:@(totalWidth) forKey:[NSString stringWithFormat:@"%td--%td", section, row]];
                [rowsArray addObject:[itemForRow mutableCopy]];
            }
            [self.cellLayoutInfo setObject:attribute forKey:indexPath];
        }
        _totalHeight = (row + 1) * (self.itemHeight + self.rowSpacing) + _totalHeight;
        sectionStartY = _totalHeight;
        
        [_sectionRowsArray addObject:rowsArray];
    }
    if (_alignmentType != DDAlignmentLeft) {
        [self updateLayout:sectionCount];
    }
}

- (void)updateLayout:(NSInteger)sectionCount {
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSArray *rowsArray = _sectionRowsArray[section];
        for (NSInteger row = 0; row < rowsArray.count; row++) {
            NSArray *itemsForRow = rowsArray[row];
            CGFloat rowTotalWidth = [_totalwidthInfo[[NSString stringWithFormat:@"%td--%td", section, row]] floatValue];
            CGFloat leftpadding = (CGRectGetWidth(self.collectionView.frame) - rowTotalWidth)/(_alignmentType == DDAlignmentCenter ? 2 : 1);
            CGFloat minX = leftpadding;
            for (NSInteger index = 0; index < itemsForRow.count; index++) {
                UICollectionViewLayoutAttributes *attribute = itemsForRow[index];
                attribute.frame = (CGRect){minX, attribute.frame.origin.y, attribute.frame.size};
                minX = minX + attribute.size.width + self.columnSpacing;
            }
        }
        
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    //添加当前屏幕可见的cell的布局
    [self.cellLayoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attribute, BOOL *stop) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [allAttributes addObject:attribute];
        }
    }];
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame), _totalHeight);
}

@end
