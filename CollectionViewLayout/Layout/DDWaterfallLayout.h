//
//  DDCollectionViewLayout.h
//  CollectionViewDemo
//
//  Created by 张桂杨 on 2017/4/27.
//  Copyright © 2017年 DD. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DDWaterfallLayout;

@protocol DDCollectionViewLayoutDelegate <NSObject>
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DDWaterfallLayout *)layout heightOfItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDWaterfallLayout *)layout numberOfColumnsAtSection:(NSInteger)section;

- (CGSize)headerSizeForCollectionView:(UICollectionView *)collectionView layout:(DDWaterfallLayout *)layout;
@end

@interface DDWaterfallLayout : UICollectionViewLayout

@property (nonatomic, assign) BOOL sectionHeadersPinToVisibleBounds;  /**< 区头是否悬停 */

@property (assign, nonatomic) NSInteger numberOfColumns;
@property (assign, nonatomic) CGFloat columnSpacing;
@property (assign, nonatomic) CGFloat rowSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (assign, nonatomic) CGFloat headerViewHeight;//头视图的高度
@property (assign, nonatomic) CGFloat footViewHeight;//尾视图的高度

@property(nonatomic, weak) id<DDCollectionViewLayoutDelegate> delegate;

- (void)registerCollectionHeaderClass:(Class)headerClass;
@end
