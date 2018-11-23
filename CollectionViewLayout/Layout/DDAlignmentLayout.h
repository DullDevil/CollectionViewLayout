//
//  DDAlignmentLayout.h
//  CollectionViewDemo
//
//  Created by 张桂杨 on 2017/4/28.
//  Copyright © 2017年 DD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DDAlignmentLayout;

@protocol DDAlignmentLayoutDelegate <NSObject>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(DDAlignmentLayout *)layout widthOfItemAtIndexPath:(NSIndexPath *)indexPath;

@end

typedef NS_ENUM (NSInteger, DDAlignmentType) {
    DDAlignmentLeft = 0,
    DDAlignmentCenter,
    DDAlignmentRight
};



@interface DDAlignmentLayout : UICollectionViewFlowLayout

- (instancetype)initWithAlignment:(DDAlignmentType)alignment;
@property (nonatomic, weak) id<DDAlignmentLayoutDelegate>delegate;
@property (nonatomic, assign) CGFloat itemHeight;
@property (assign, nonatomic) CGFloat columnSpacing;
@property (assign, nonatomic) CGFloat rowSpacing;
@end
