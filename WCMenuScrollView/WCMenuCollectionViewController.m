//
//  WCMenuCollectionViewController.m
//  WCMenuScrollViewDemo
//
//  Created by weicheng wang on 15/10/9.
//  Copyright © 2015年 weicheng wang. All rights reserved.
//

#import "WCMenuCollectionViewController.h"
#import "WCBottomCollectionViewCell.h"

#define kLabelTag       210500

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width


typedef enum{
    WCTapEventStart,    // 开始点击事件
    WCTapEventAnimate,  // 点击事件动画
    WCTapEventNone      // 没有点击事件
} WCTapState;

@interface WCMenuCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionViewFlowLayout  *_flow;     // UICollectionViewFlowLayout 系统提供的，对item进行网格布局的类。
    NSMutableArray              *_centerArray;      // 标题的中心横坐标
    NSMutableArray              *_widthArray;       // 标题宽度
    UITapGestureRecognizer      *_tappedRecognizer; // 当前点击事件的承担着
    NSInteger                   _currentPage;       // 当前页
    NSInteger                   _previousPage;      // 上一页
    NSInteger                   _nextPage;          // 下一页
    WCTapState                  _tappState;
    CGFloat                     _lineLastX;         // 下划线上次横坐标
    CGFloat                     _distance;          // 跳转的两个标题之间的中心距离
    CGFloat                     _lineOffsetX;       // 下划线偏移量
    double      d_r;
    double      d_g;
    double      d_b;
}

@end

@implementation WCMenuCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    [self beforeRunning];
    [self configMenuScrollView];
}
// 初始化界面
- (void)beforeRunning
{
    _flow = [[UICollectionViewFlowLayout alloc] init];
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.y  += 40;
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:_flow];
    
    _collectionView.delegate      = self;
    _collectionView.dataSource    = self;
    _collectionView.bounces       = NO;
    _collectionView.pagingEnabled = YES;
    _flow.minimumInteritemSpacing = 0;
    _flow.minimumLineSpacing      = 0;
    [_flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _flow.itemSize = [UIScreen mainScreen].bounds.size;
    [self.view addSubview:_collectionView];
    // Register cell classes
    [_collectionView registerClass:[WCBottomCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    _lineIv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, kScreenWidth/_titleArray.count, 1)];

    // 设置默认菜单栏标题颜色
    self.hightLightedColor  = [UIColor blueColor];
    self.normalColor        = [UIColor blackColor];
    self.hlFont  = [UIFont systemFontOfSize:16.0f];
    self.norFont = [UIFont systemFontOfSize:14.0f];
    
    _lineIv.backgroundColor = _hightLightedColor;
}

// 解析菜单文字颜色
- (void)analysisMenuColor
{
    UIColor *hlColor  = _hightLightedColor;
    UIColor *norColor = _normalColor;
    // 高亮颜色RGB
    CGFloat hlR;
    CGFloat hlG;
    CGFloat hlB;
    CGFloat hlA;
    [hlColor getRed:&hlR green:&hlG blue:&hlB alpha:&hlA];
    // 正常颜色RGB
    CGFloat norR;
    CGFloat norG;
    CGFloat norB;
    CGFloat norA;
    [norColor getRed:&norR green:&norG blue:&norB alpha:&norA];
    // 颜色之间的差值
    d_r = hlR - norR;
    d_g = hlG - norG;
    d_b = hlB - norB;

}

- (void)configMenuScrollView
{
    _menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 35)];
    _menuScrollView.contentSize = CGSizeMake(100*_titleArray.count, 35);
    _menuScrollView.bounces = NO;
    _menuScrollView.scrollEnabled = YES;
    _menuScrollView.showsHorizontalScrollIndicator = NO;
    _menuScrollView.delegate = self;
    [_menuScrollView addSubview:_lineIv];
    _centerArray = [NSMutableArray array];
    [self.view addSubview:_menuScrollView];
    NSInteger i = 0;
    CGFloat pointX = 0;     // 菜单标签的横坐标
    for (NSString *title in _titleArray) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pointX, 0, 100, 30)];
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        size.width += 20;
        
        label.frame = CGRectMake(pointX, 0, kScreenWidth/3, 39);
        
        label.userInteractionEnabled = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToPage:)];
        [label addGestureRecognizer:tap];
        tap.view.tag = kLabelTag + i ++;
        [_menuScrollView addSubview:label];
        [_centerArray addObject:@(label.center.x)];
        [_widthArray addObject:@(label.frame.size.width)];
        pointX = label.frame.size.width + label.frame.origin.x;
    }
    _menuScrollView.contentSize = CGSizeMake(pointX, 40);
    _lineIv.center = CGPointMake([_centerArray[0] floatValue], _lineIv.center.y);
    _lineLastX = _lineIv.center.x;
    
    [self setDiffSize];
}

- (void)setDiffSize
{
    
    //    UIFont *hlFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //    [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *hl_ctfFont = _hlFont.fontDescriptor;
    NSNumber *hlFontSize = [hl_ctfFont objectForKey:@"NSFontSizeAttribute"];
    CGFloat hlSize = hlFontSize.floatValue;
    
    UIFontDescriptor *nor_ctfFont = _norFont.fontDescriptor;
    NSNumber *norFontSize = [nor_ctfFont objectForKey:@"NSFontSizeAttribute"];
    CGFloat norSize = norFontSize.floatValue;
    _diffSize = hlSize - norSize;
}

- (void)jumpToPage:(id)sender
{
    _tappState = WCTapEventStart;
    _tappedRecognizer = (UITapGestureRecognizer *)sender;
    _currentPage = _tappedRecognizer.view.tag - kLabelTag;
//    _collectionView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width * page, 0);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentPage inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if ([scrollView isEqual:_collectionView]) {
        _distance = [_centerArray[_nextPage] floatValue] - [_centerArray[_currentPage] floatValue];
        
        float needChange = 0;
        int a =0;
        for (int i =0;i< _centerArray.count;i++) {
            NSNumber *num = _centerArray[i];
            if (num.floatValue >= _lineIv.center.x) {
                if (i-1>=0) {
                    needChange = [_centerArray[i] floatValue] - [_centerArray[i-1] floatValue];
                    a = i;
                    break;
                }
            }
        }
        float offset = 0;
        offset = needChange/kScreenWidth *(_collectionView.contentOffset.x - (a -1) *kScreenWidth);
        if (a != 0) {
            _lineIv.center = CGPointMake([_centerArray[a -1] floatValue] +  offset, _lineIv.center.y);
        }
        _lineIv.bounds = CGRectMake(0, 0, _lineIv.bounds.size.width, _lineIv.bounds.size.height);
        _lineOffsetX = _lineIv.center.x - _lineLastX;
        [self transitionAnimateWithOffset:_lineOffsetX distance:_distance];
        // 点击事件触发的动画效果
        if (_tappState == WCTapEventStart) {
            _tappState = WCTapEventAnimate;
            // 点击标签的中心横坐标
            CGFloat tappedLabelCenterX = [_centerArray[_currentPage] floatValue];
            if ( tappedLabelCenterX > kScreenWidth/2 && tappedLabelCenterX < _menuScrollView.contentSize.width - kScreenWidth/2) {
                
                [_menuScrollView setContentOffset:CGPointMake(-(kScreenWidth/2 - _tappedRecognizer.view.center.x), 0) animated:YES];
                
            }else if (tappedLabelCenterX < kScreenWidth/2) {
                
                [_menuScrollView setContentOffset:CGPointMake(0, 0)
                                         animated:YES];
            }else if (tappedLabelCenterX > _menuScrollView.contentSize.width - kScreenWidth/2) {
                
                [_menuScrollView setContentOffset:CGPointMake(_menuScrollView.contentSize.width - kScreenWidth, 0)
                                         animated:YES];
            }
            // 拖拽底部集合视图触发的动画效果
        }else if ( _tappState == WCTapEventNone ) {
            if (_lineIv.center.x > kScreenWidth/2 && _lineIv.center.x < _menuScrollView.contentSize.width - kScreenWidth/2) {
                _menuScrollView.contentOffset = CGPointMake(-(kScreenWidth/2 - _lineIv.center.x), 0);
            }else if (_lineIv.center.x < kScreenWidth/2) {
                // 菜单滚动视图滚动到最左边
                [_menuScrollView setContentOffset:CGPointMake(0, 0)
                                         animated:YES];
            }else if (_lineIv.center.x > _menuScrollView.contentSize.width - kScreenWidth/2) {
                // 菜单滚动视图滚动到最右边
                [_menuScrollView setContentOffset:CGPointMake(_menuScrollView.contentSize.width - kScreenWidth, 0)
                                         animated:YES];
            }
        }
    }
}
#pragma mark -
#pragma mark - 配置基本参数
- (void)setHightLightedColor:(UIColor *)hightLightedColor
{
    _hightLightedColor      = hightLightedColor;
    _lineIv.backgroundColor = hightLightedColor;
    UILabel *label          = (UILabel *)[self.view viewWithTag:kLabelTag];
    label.textColor         = hightLightedColor;
    [self analysisMenuColor];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    [self analysisMenuColor];
    
}

- (void)setBottomViewFrame:(CGRect)frame
{
    _collectionView.frame = frame;
}
// 高亮时标题的颜色和字体
- (void)setHightLightedColor:(UIColor *)hlColor font:(UIFont *)hlFont
{
    self.hightLightedColor = hlColor;
    self.hlFont     = hlFont;
}
// 正常状态标题的颜色和字体
- (void)setNormalColor:(UIColor *)norColor font:(UIFont *)norFont {
    self.normalColor = norColor;
    self.norFont = norFont;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _tappState = WCTapEventNone;   // 拖拽事件
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_collectionView]) {
        [self collectionViewEndAnimate];
    }
    
}
/**
 *  过场动画
 *
 *  @param offset   相对偏移量，即下一个标题距离上一个标题的偏移量
 *  @param distance 标题之间的距离
 */
- (void)transitionAnimateWithOffset:(CGFloat)offset distance:(CGFloat)distance
{
    UIColor *hlColor  = _hightLightedColor;
    UIColor *norColor = _normalColor;
    // 高亮颜色RGB
    CGFloat hlR;
    CGFloat hlG;
    CGFloat hlB;
    CGFloat hlA;
    [hlColor getRed:&hlR green:&hlG blue:&hlB alpha:&hlA];
    // 正常颜色RGB
    CGFloat norR;
    CGFloat norG;
    CGFloat norB;
    CGFloat norA;
    [norColor getRed:&norR green:&norG blue:&norB alpha:&norA];
    // 颜色之间的差值
    float d_r = hlR - norR;
    float d_g = hlG - norG;
    float d_b = hlB - norB;
    
    double p_r = d_r/_distance;
    double p_g = d_g/_distance;
    double p_b = d_b/_distance;
    
    UILabel *label1 = (UILabel *)[self.view viewWithTag:kLabelTag+_currentPage];
    UILabel *label2 = (UILabel *)[self.view viewWithTag:kLabelTag+_nextPage];
    // 渐变高亮颜色
    [label2 setTextColor:[UIColor colorWithRed:(p_r*offset+norR) green:(p_g*offset+norG) blue:(p_b*offset+norB) alpha:1]];
    // 渐变常规颜色
    [label1 setTextColor:[UIColor colorWithRed:(hlR-p_r*offset) green:(hlG-p_g*offset) blue:(hlB-p_b*offset) alpha:1]];
    
    
    
}

- (void)startTransition:(CGFloat)offset distance:(CGFloat)distance
{
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    if ([scrollView isEqual:_collectionView]) {
        [self collectionViewEndAnimate];
    }
}
// 集合视图停止动画
- (void)collectionViewEndAnimate
{
//    _currentPage = _collectionView.contentOffset.x/kScreenWidth;
//    _turnPageBlock(_currentPage);
//    _lineLastX = _lineIv.center.x;
    UILabel *label = (UILabel *)[self.view viewWithTag:kLabelTag+_currentPage];
    [label setTextColor:_hightLightedColor];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_titleArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WCBottomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor greenColor];
    }
    // Configure the cell
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    _lineLastX = _lineIv.center.x;
    _nextPage = indexPath.row;
    NSLog(@"==============>%d,%d,%f",_nextPage,_currentPage,_distance);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    _previousPage = _currentPage;
    _currentPage = _nextPage;
//    NSLog(@"===>%d",_previousPage);
}


@end
