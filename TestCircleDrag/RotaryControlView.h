//
//  RotaryControlView.h
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RotaryControlButton;

@protocol RotaryControlButtonDelegate <NSObject>
- (void)rotaryControlButtonDidMove:(RotaryControlButton*)controlButton;
- (void)rotaryControlButtonDidFinishMovingFromTouch:(RotaryControlButton*)controlButton;
@end

@protocol RotaryControlDelegate;

@interface RotaryControlView : UIView <RotaryControlButtonDelegate> {
    RotaryControlButton *controlButton;
    UILabel *percentageLabel;
    CGRect mainCircleRect;
}

@property (nonatomic, weak)id<RotaryControlDelegate> delegate;

@property (nonatomic, assign) CGFloat percentage;

@property (nonatomic, strong) UIColor *mainBackgroundColor;

@property (nonatomic, assign) CGFloat fillWidth;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat outerCircleEdgeWidth;

@property (nonatomic, assign) CGFloat controlButtonSize;
@property (nonatomic, strong) UIColor *controlColor;
@property (nonatomic, assign) CGFloat innerCircleEdgeWidth;

@property (nonatomic, strong) UIColor *innerDetailCircleColor;
@property (nonatomic, assign) CGFloat innerDetailCircleEdgeWidth;

@property (nonatomic, strong) UIColor *outerDetailCircleColor;
@property (nonatomic, assign) CGFloat outerDetailCircleEdgeWidth;

- (void)setPercentage:(CGFloat)percentage animated:(BOOL)animated;
- (void)useDefaultSizes;
- (void)useDefaultColors;

@end

@protocol RotaryControlDelegate <NSObject>
- (void)rotaryControlDidFinishChangingValueFromUserTouch:(RotaryControlView*)rotaryControlView;
@end

