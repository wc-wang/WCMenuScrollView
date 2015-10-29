//
//  WCMenuCollectionViewController.h
//  WCMenuScrollViewDemo
//
//  Created by weicheng wang on 15/10/9.
//  Copyright © 2015年 weicheng wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TurnPageBlock) (NSInteger);

@interface WCMenuCollectionViewController : UIViewController

@property (nonatomic, strong) NSArray           *titleArray;
@property (nonatomic, strong) UIImageView       *lineIv;           // 指示线
@property (nonatomic, strong) UIScrollView      *menuScrollView;
@property (nonatomic, strong) UICollectionView  *collectionView;
// 设置菜单标题高亮颜色和常规颜色
@property (nonatomic, strong) UIColor           *hightLightedColor;
@property (nonatomic, strong) UIColor           *normalColor;

@property (nonatomic, strong) UIFont            *hlFont;
@property (nonatomic, strong) UIFont            *norFont;

@property (nonatomic, assign, readonly) CGFloat diffSize;

- (void)setHightLightedColor:(UIColor *)hlColor font:(UIFont *)hlFont;
- (void)setNormalColor:(UIColor *)norColor font:(UIFont *)norFont;

@property (nonatomic, readonly, copy) TurnPageBlock turnPageBlock;

- (void)setBottomViewFrame:(CGRect)frame;
- (void)turn2Page:(TurnPageBlock)callback;
@end
