//
//  ViewController.m
//  XBScrollTextViewDemo
//
//  Created by xxb on 2020/4/24.
//  Copyright © 2020 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBScrollTextView.h"

@interface ViewController () <XBScrollTextViewDelegate>
{
    XBScrollTextView *_scrollTextView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self scrollTextViewTest];
}
- (void)scrollTextViewTest
{
    NSArray *arr = @[@"11111111111111111111111111111111111111111111111111111111111111111",
                     @"222222222222222222222222222222222",
                     @"333333333333333333333"];
    CGFloat width = 200;
    _scrollTextView = [[XBScrollTextView alloc] initWithTextArr:arr duration:4 maxWidth:width repeat:true fill:true];
    _scrollTextView.frame = CGRectMake(50, 150, width, 600);
    [self.view addSubview:_scrollTextView];
//    [_scrollTextView scrollStyle:ScrollStyle_height heightIfNeed:100];
    [_scrollTextView setInterval:3];
    _scrollTextView.delegate = self;
    [_scrollTextView setFont:[UIFont systemFontOfSize:30]];
//    [_scrollTextView setTextColor:[UIColor orangeColor]];
    [_scrollTextView setTextColorArr:@[[UIColor greenColor],[UIColor redColor],[UIColor blueColor]]];
    [_scrollTextView startScroll];
    _scrollTextView.backgroundColor = [UIColor blackColor];
}

- (void)scrollTextViewDidEndScrollOnce:(XBScrollTextView *)scrollTextView
{
    NSLog(@"scrollTextViewDidEndScrollOnce");
}

- (void)scrollTextViewDidEndScrollRound:(XBScrollTextView *)scrollTextView
{
    NSLog(@"scrollTextViewDidEndScrollRound");
}

@end
