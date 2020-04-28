//
//  XBScrollTextView.h
//  smarthome
//
//  Created by xxb on 2020/4/23.
//  Copyright © 2020 DreamCatcher. All rights reserved.
//

/**
 用于上下滚动文字
 */

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScrollStyle_everyText, ///按文本滚动（默认）
    ScrollStyle_height, ///按高度滚动
} ScrollStyle;

NS_ASSUME_NONNULL_BEGIN

@class XBScrollTextView;

@protocol XBScrollTextViewDelegate <NSObject>

@optional
///滚动完一条文本或者滚动完一次设置的高度
- (void)scrollTextViewDidEndScrollOnce:(XBScrollTextView *)scrollTextView;
///完成一轮滚动，即滚动完所有文字
- (void)scrollTextViewDidEndScrollRound:(XBScrollTextView *)scrollTextView;

@end

@interface XBScrollTextView : UIView
@property (nonatomic,weak) id<XBScrollTextViewDelegate>delegate;
/**
 textArr:需要滚动的文字
 duration:在(interval == 0 && scrollStyle == ScrollStyle_everyText)的情况下，滚完一次textArr中所有内容需要的时间，简单理解为滚动时的速度，越小滚动越快
 owner:谁拥有ScrollTextView，用于在owner销毁时停止滚动
 repeat:是否循环
 fill:如果文字不够BScrollTextView高度的话，是否循环显示文字
 */
 - (instancetype)initWithTextArr:(NSArray *)textArr duration:(CGFloat)duration maxWidth:(CGFloat)maxWidth repeat:(BOOL)repeat fill:(BOOL)fill;

- (void)setFont:(UIFont *)font;

- (void)setTextColor:(UIColor *)textColor;

- (void)setTextColorArr:(NSArray *)textColorArr;

/**
 文字对齐方式，默认居中
 */
- (void)setTextAlignment:(NSTextAlignment)textAlignment;

/**
 设置textArr，在滚动时设置可能会闪屏
 */
- (void)setTextArr:(NSArray *)textArr;

/**
 开始滚动
 */
- (void)startScroll;

/**
 停止滚动
*/
- (void)stopScroll;

/**
 是否正在滚动
*/
- (BOOL)isScrolling;

/**
 设置滚动方式
 scrollStyle：滚动方式，默认ScrollStyle_everyText
 heightIfNeed：如果是ScrollStyle_height，需要传入高度，即每次滚动的高度
*/
- (void)scrollStyle:(ScrollStyle)scrollStyle heightIfNeed:(CGFloat)heightIfNeed;

/**
 每次滚动后，静止的时间，默认2s
 */
- (void)setInterval:(CGFloat)interval;

/**
 重置回原始状态
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END

