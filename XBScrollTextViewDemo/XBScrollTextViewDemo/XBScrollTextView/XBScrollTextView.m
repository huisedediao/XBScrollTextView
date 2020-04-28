//
//  XBScrollTextView.m
//  smarthome
//
//  Created by xxb on 2020/4/23.
//  Copyright © 2020 DreamCatcher. All rights reserved.
//

#import "XBScrollTextView.h"

@interface XBScrollTextView ()
{
    ///外部变量
    NSArray *_textArr;
    CGFloat _maxWidth;
    BOOL _isScrolling; ///外部控制内部是否滚动的变量
    CGFloat _interval;
    ScrollStyle _scrollStyle;
    CGFloat _scrollHeight;//滚动的高度
    CGFloat _duration;
    BOOL _repeat;
    BOOL _fill;
    UIFont *_font;
    UIColor *_textColor;
    NSArray *_arrTextColor;
    NSTextAlignment _textAlignment;
    
    ///内部变量
    //不变
    int _fps;
    CGFloat _offsetP;
    NSMutableArray *_arrHeight;
    NSMutableDictionary *_attrs;
    //变
    int _startIndex;
    CGFloat _offsetStart;
    CGFloat _offsetEndScroll;
    BOOL _isScrollingIn; ///内部自己控制是否滚动的变量
}
@end

@implementation XBScrollTextView

- (instancetype)initWithTextArr:(NSArray *)textArr duration:(CGFloat)duration maxWidth:(CGFloat)maxWidth repeat:(BOOL)repeat fill:(BOOL)fill
{
    if (self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        _fill = fill;
        _repeat = repeat;
        _isScrollingIn = true;
        _scrollStyle = ScrollStyle_everyText;
        _interval = 2;
        _fps = 60;
        _duration = duration;
        _maxWidth = maxWidth;
        _font = [UIFont systemFontOfSize:15];
        _textColor = [UIColor blackColor];
        _textAlignment = NSTextAlignmentCenter;
        
        _arrHeight = [NSMutableArray new];
        _attrs = [NSMutableDictionary new];
        
        [self setFont:_font];
        [self setTextArr:textArr];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"XBScrollTextView 销毁");
}

- (void)drawRect:(CGRect)rect
{
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:_textAlignment];
    [_attrs setObject:style forKey:NSParagraphStyleAttributeName];
    
    ///实际的index
    NSInteger index = [self enSureIndex:_startIndex];
    
    ///无限滚动
    _offsetStart += _offsetP;
    _offsetEndScroll += _offsetP;
    
    CGFloat currentTextHeight = [_arrHeight[index] floatValue];
    if (_offsetStart > currentTextHeight)
    {
        _startIndex++;
        _offsetStart -= currentTextHeight;
    }
    
    if (_scrollStyle == ScrollStyle_everyText)
    {
        _scrollHeight = currentTextHeight;
    }
    else if (_scrollHeight == ScrollStyle_height)
    {

    }

    if (_offsetEndScroll > _scrollHeight)
    {
        _offsetEndScroll -= _scrollHeight;
        [self stopScrollIn];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollTextViewDidEndScrollOnce:)])
        {
            [self.delegate scrollTextViewDidEndScrollOnce:self];
        }
        
        if (_repeat || ![self isCompleteOnceRound])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startScrollIn];
            });
        }
        if ([self isNextRound])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scrollTextViewDidEndScrollRound:)])
            {
                [self.delegate scrollTextViewDidEndScrollRound:self];
            }
        }
    }
    
    ///startIndex可能更新了，确保index正确
    index = [self enSureIndex:_startIndex];

    ///获取所有需要显示的文字
    NSMutableArray *arrMNeedShow = [NSMutableArray new];
    NSMutableArray *arrMColors = [NSMutableArray new];
    
    NSInteger indexOver = index;
    CGFloat heigthForShow = -_offsetStart;
    while (heigthForShow < rect.size.height)
    {
        NSInteger tempIndex = [self enSureIndex:indexOver];
        heigthForShow += [_arrHeight[tempIndex] floatValue];
        [arrMNeedShow addObject:_textArr[tempIndex]];
        if (_arrTextColor)
        {
            NSInteger colorIndex = tempIndex % _arrTextColor.count;
            [arrMColors addObject:_arrTextColor[colorIndex]];
        }
        else
        {
            [arrMColors addObject:_textColor];
        }
        indexOver ++;
        if (!_fill && indexOver >= _textArr.count)
        {
            break;
        }
    }
    
    ///显示
    CGFloat top = -_offsetStart;
    for (int i = 0; i < arrMNeedShow.count; i++)
    {
        [_attrs setObject:arrMColors[i] forKey:NSForegroundColorAttributeName];
        NSString *text = arrMNeedShow[i];
        NSInteger heightIndex = [_textArr indexOfObject:text];
        CGFloat height = [_arrHeight[heightIndex] floatValue];
        [text drawInRect:CGRectMake(0, top, _maxWidth, height) withAttributes:_attrs];
        top += height;
    }
}

#pragma mark - 公有方法
- (void)setFont:(UIFont *)font
{
    _font = font;
    [_attrs setObject:_font forKey:NSFontAttributeName];
    
    if (_textArr)
    {
        [self setTextArr:_textArr];
    }
    
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setNeedsDisplay];
}

- (void)setTextColorArr:(NSArray *)textColorArr
{
    _arrTextColor = textColorArr;
    [self setNeedsDisplay];
}

- (void)setTextArr:(NSArray *)textArr
{
    _textArr = textArr;
    [_arrHeight removeAllObjects];
    CGFloat totalHeight = 0;
    for (int i = 0; i < _textArr.count; i++)
    {
        NSString *text = _textArr[i];
        _arrHeight[i] = @([self getStringHeightWithText:text font:_font viewWidth:_maxWidth]);
        totalHeight += [_arrHeight[i] floatValue];
    }
    _offsetP = totalHeight / _fps / _duration;
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    [self setNeedsDisplay];
}

- (void)startScroll
{
    _isScrolling = true;
    [self scroll];
}

- (void)stopScroll
{
    _isScrolling = false;
}

- (void)scrollStyle:(ScrollStyle)scrollStyle heightIfNeed:(CGFloat)heightIfNeed
{
    _scrollStyle = scrollStyle;
    _scrollHeight = heightIfNeed;
    [self setNeedsDisplay];
}

- (void)setInterval:(CGFloat)interval
{
    _interval = interval;
    [self setNeedsDisplay];
}

- (void)reset
{
    _startIndex = 0;
    _offsetStart = 0;
    _offsetEndScroll = 0;
    _isScrollingIn = true;
}

- (BOOL)isScrolling
{
    return _isScrolling;
}

#pragma mark - 私有方法
- (void)startScrollIn
{
    _isScrollingIn = true;
    [self scroll];
}

- (void)stopScrollIn
{
    _isScrollingIn = false;
}

- (void)scroll
{
    if (self.superview == nil)
    {
        return;
    }
    if (_isScrolling == false)
    {
        return;
    }
    if (_isScrollingIn == false)
    {
        return;
    }
    [self setNeedsDisplay];
    CGFloat time = 1.0 / _fps;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scroll];
    });
}

- (BOOL)isCompleteOnceRound
{
    return _startIndex >= _textArr.count;
}

- (BOOL)isNextRound
{
    return _startIndex > 0 && (_startIndex % _textArr.count == 0);
}

- (NSInteger)enSureIndex:(NSInteger)index
{
    return index % _textArr.count;
}

- (CGFloat)getStringHeightWithText:(NSString *)text font:(UIFont *)font viewWidth:(CGFloat)width
{
    NSDictionary *attrs = @{NSFontAttributeName :font};
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
    return  size.height;
}

@end




