//
//  DDCarrousellayout.m
//  DevelopmentLibrary
//
//  Created by 张桂杨 on 2017/8/16.
//  Copyright © 2017年 DD. All rights reserved.
//

#import "DDCarrouselLayout.h"

@implementation DDCarrouselLayout
- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 0.0;
    self.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds)/1.5, CGRectGetHeight(self.collectionView.bounds) /1.5);
    CGFloat insertWidth = (CGRectGetWidth(self.collectionView.bounds) - CGRectGetWidth(self.collectionView.bounds)/1.5)/2.0;
    self.sectionInset = UIEdgeInsetsMake(0, insertWidth, 0, insertWidth);
    
    
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributesInArray = [NSMutableArray array];
    
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *attribs = [super layoutAttributesForElementsInRect:visibleRect];
    CGFloat center = self.collectionView.contentOffset.x + 0.5*self.collectionView.bounds.size.width;
    
    
    for (UICollectionViewLayoutAttributes *attributes in attribs) {
        
        UICollectionViewLayoutAttributes *attributesCopy = [attributes copy];
        
        CGFloat offset = ABS(attributesCopy.center.x - center);
        
        CGFloat scale = 1 - (offset/CGRectGetWidth(self.collectionView.bounds)) * self.scale;
        
        attributesCopy.transform = CGAffineTransformMakeScale(scale, scale);
        [allAttributesInArray addObject:attributesCopy];
    }
    
    return allAttributesInArray;
}



// 指定停止时的位置
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGRect oldRect = CGRectMake(proposedContentOffset.x, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *attributes = [self layoutAttributesForElementsInRect:oldRect];
    
    CGFloat minOffset = MAXFLOAT;
    CGFloat center = proposedContentOffset.x + 0.5*self.collectionView.bounds.size.width;
    
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        CGFloat offset = self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? attribute.center.x - center : attribute.center.y - center;
        if (ABS(offset) < ABS(minOffset)) {
            minOffset = offset;
        }
    }
    CGFloat newX = proposedContentOffset.x + minOffset;
    CGFloat newY = proposedContentOffset.y;
    return CGPointMake(newX, newY);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - setter && getter
- (CGFloat)scale {
    if (_scale == 0) {
        return 0.2;
    }
    return _scale;
}



@end
