//
//  GLHorizontalScroller.h
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/10/14.
//
//

#import <UIKit/UIKit.h>

@protocol GLHorizontalScrollerDelegate;

@interface GLHorizontalScroller : UIView <UIScrollViewDelegate>


@property (weak) id<GLHorizontalScrollerDelegate> delegate;

- (void)reload;

@end


@protocol GLHorizontalScrollerDelegate <NSObject>

@required

// Спросить делегата, сколько представлений мы покажем внутри горизонтального скроллера
- (NSInteger)numberOfViewsForHorizontalScroller:(GLHorizontalScroller *)scroller;

// Попросить делегата получить представление по индексу <index>
- (UIView *)horizontalScroller:(GLHorizontalScroller *)scroller viewAtIndex:(int)index;

// Сообщить делегату о нажатии на представлении по индексу <index>
- (void)horizontalScroller:(GLHorizontalScroller *)scroller clickedViewAtIndex:(int)index;

@optional

// Спросить делегата, какое из представлений отобразить при открытии
// (метод необязательный, по умолчанию 0, если делегат не реализует метод)
- (NSInteger)initialViewIndexForHorizontalScroller:(GLHorizontalScroller *)scroller;

@end