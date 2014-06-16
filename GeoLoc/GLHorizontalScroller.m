//
//  GLHorizontalScroller.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/10/14.
//
//

#import "GLHorizontalScroller.h"

#define VIEW_PADDING 10
#define VIEW_DIMENSIONS 240
#define VIEWS_OFFSET 30

@interface GLHorizontalScroller () <UIScrollViewDelegate>

@end

@implementation GLHorizontalScroller
{
    UIScrollView * scroller;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        [self addSubview:scroller];
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
    }
    return self;
}


- (void)reload
{
    //нечего загружать, если нет делегата:
    if (self.delegate == nil) return;
    //удалить все subviews:
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        [obj removeFromSuperview];
    }];
    //xValue - стартовая точка всех представлений в скроллере:
    CGFloat xValue = VIEWS_OFFSET;
    for (int i = 0; i < [self.delegate numberOfViewsForHorizontalScroller:self]; i++)
    {
        //добавляем представление в нужную позицию:
        xValue += VIEW_PADDING;
        UIView * view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, VIEW_PADDING+10, VIEW_DIMENSIONS, [[UIScreen mainScreen] bounds].size.height*3/4);
        [scroller addSubview:view];
        xValue += VIEW_DIMENSIONS + VIEW_PADDING;
    }
    [scroller setContentSize:CGSizeMake(xValue + VIEWS_OFFSET, self.frame.size.height)];
    //если определён initialView, центрируем его в скроллере:
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)])
    {
        long int initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        CGPoint offset = CGPointMake(initialView * (VIEW_DIMENSIONS + (2 * VIEW_PADDING)), 0);
        [scroller setContentOffset:offset animated:YES];
    }
}



- (void)scrollerTapped:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    // Не используем enumerator, т.к. не хотим перечислять все дочерние представления.
    // Мы хотим перечислить только те subviews, которые мы добавили:
    for (int index = 0; index < [self.delegate numberOfViewsForHorizontalScroller:self]; index++)
    {
        UIView * view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location))
        {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            CGPoint offset = CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0);
            [scroller setContentOffset:offset animated:YES];
            break;
        }
    }
}

- (void)didMoveToSuperview
{
    [self reload];
}

- (void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + (VIEWS_OFFSET / 2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS + (2 * VIEW_PADDING));
    xFinal = viewIndex * (VIEW_DIMENSIONS + (2 * VIEW_PADDING));
    [scroller setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

#pragma mark methods UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}

@end
