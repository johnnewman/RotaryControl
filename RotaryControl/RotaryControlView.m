//
//  RotaryControlView.m
//  RotaryControl
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "RotaryControlView.h"
#import <QuartzCore/QuartzCore.h>

#define kANIMATION_TIME 0.25
#define kNUM_ANIMATION_INTERVALS 20
#define kLOWER_BOUNDS_FOR_TOUCH_BUFFER 0.12
#define kUPPER_BOUNDS_FOR_TOUCH_BUFFER 0.88

@interface RotaryControlButton : UIButton
@property (nonatomic, weak) RotaryControlView *controlView;

- (void)moveButtonToPercentage:(CGFloat)percentage;
@end

@interface RotaryControlView ()
@property (nonatomic, readonly)CGRect mainCircleRect;
@property (nonatomic, readonly)CGFloat mainCircleRadius;

- (void)setupInitialLayout;
- (void)animateRotaryProgressToPercentage:(NSNumber*)percentage;
- (void)moveButtonToPercentageOnMainThread:(NSNumber*)percentage;
- (void)rotaryAnimationFinished;
- (CGRect)modifyCircleRect:(CGRect)rect withRadiusDelta:(CGFloat)radiusDelta;

- (void)rotaryControlButtonDidMoveToPercentage:(CGFloat)percentage;
- (void)rotaryControlButtonDidFinishMovingFromTouch;
@end


@implementation RotaryControlView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitialLayout];
    }
    return self;
}

- (void)setupInitialLayout
{
    self.backgroundColor = [UIColor clearColor];
    
    _maxValue = 100;
    
    [self useDefaultSizes];
    [self useDefaultColors];
    
    CGFloat circleDiameter = self.frame.size.width - _controlButtonSize;
    _mainCircleRect = CGRectMake(self.bounds.origin.x + _controlButtonSize / 2, self.bounds.origin.y + _controlButtonSize / 2, circleDiameter, circleDiameter);
    _mainCircleRadius = circleDiameter / 2;
    
    controlButton = [[RotaryControlButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(_mainCircleRect) - _controlButtonSize/2, _mainCircleRect.size.height, _controlButtonSize, _controlButtonSize)];
    controlButton.layer.cornerRadius = _controlButtonSize/2;
    controlButton.backgroundColor = _controlColor;
    controlButton.controlView = self;
    [self addSubview:controlButton];
    
    percentageLabel = [[UILabel alloc] initWithFrame:self.bounds];
    percentageLabel.backgroundColor = [UIColor clearColor];
    percentageLabel.textAlignment = NSTextAlignmentCenter;
    percentageLabel.font = [UIFont systemFontOfSize:90];
    percentageLabel.textColor = _controlColor;
    percentageLabel.text = @"0";
    [self addSubview:percentageLabel];
}

- (void)useDefaultSizes
{
    _controlButtonSize = 35;
    _fillWidth = 40;
    _innerCircleEdgeWidth = 4.0;
    _outerCircleEdgeWidth = 4.0;
    _innerDetailCircleEdgeWidth = 9.0;
    _outerDetailCircleEdgeWidth = 7.0;
}

- (void)useDefaultColors
{
    _mainBackgroundColor = [UIColor whiteColor];
    _fillColor = [UIColor colorWithRed:1.0 green:0.7216 blue:0.0 alpha:1.0];
    _innerDetailCircleColor = [UIColor colorWithRed:1.0 green:0.7922 blue:0.2471 alpha:1.0];
    _outerDetailCircleColor = [UIColor colorWithRed:1.0 green:0.8588 blue:0.4980 alpha:1.0];
    _controlColor = [UIColor colorWithRed:0.5765 green:0.5843 blue:0.5961 alpha:1.0];
}

- (void)setControlColor:(UIColor *)controlColor
{
    _controlColor = controlColor;
    controlButton.backgroundColor = _controlColor;
    percentageLabel.textColor = _controlColor;
}

- (void)setPercentage:(CGFloat)percentage
{
    [self setPercentage:percentage animated:NO];
}

- (void)setPercentage:(CGFloat)percentage animated:(BOOL)animated
{
    if (animated) {
        NSThread *animationThread = [[NSThread alloc] initWithTarget:self selector:@selector(animateRotaryProgressToPercentage:) object:[NSNumber numberWithFloat:percentage]];
        controlButton.userInteractionEnabled = NO;
        [animationThread start];
    }
    else {
        [controlButton moveButtonToPercentage:percentage];
    }
}

- (void)animateRotaryProgressToPercentage:(NSNumber*)percentage
{
    //find a set of values between current and percentage and move the button increments over _animationTime
    @autoreleasepool {
        CGFloat percentageToReach = percentage.floatValue;
        CGFloat distanceToMove = percentageToReach - _percentage;
        CGFloat progressIncrement = distanceToMove / kNUM_ANIMATION_INTERVALS;
        CGFloat sleepTime = kANIMATION_TIME / kNUM_ANIMATION_INTERVALS;
        
        for (int i = 0; i < kNUM_ANIMATION_INTERVALS; i++)
        {
            [NSThread sleepForTimeInterval:sleepTime];
            [self performSelectorOnMainThread:@selector(moveButtonToPercentageOnMainThread:) withObject:[NSNumber numberWithFloat:_percentage + progressIncrement] waitUntilDone:NO];
        }
        [self performSelectorOnMainThread:@selector(moveButtonToPercentageOnMainThread:) withObject:[NSNumber numberWithFloat:percentageToReach] waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(rotaryAnimationFinished) withObject:nil waitUntilDone:NO];
    }
}

- (void)moveButtonToPercentageOnMainThread:(NSNumber*)percentage
{
    [controlButton moveButtonToPercentage:percentage.floatValue];
}

- (void)rotaryAnimationFinished
{
    controlButton.userInteractionEnabled = YES;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //fill main circle background
    CGContextSetFillColorWithColor(context, _mainBackgroundColor.CGColor);
    CGContextFillEllipseInRect(context, _mainCircleRect);
    
    //stroke main circle edge
    CGContextSetLineWidth(context, _outerCircleEdgeWidth);
    CGContextSetStrokeColorWithColor(context, _fillColor.CGColor);
    CGContextStrokeEllipseInRect(context, _mainCircleRect);
    
    //draw inner circle
    CGRect innerCircleRect = [self modifyCircleRect:_mainCircleRect withRadiusDelta:-_fillWidth];
    CGContextSetLineWidth(context, _innerCircleEdgeWidth);
    CGContextSetStrokeColorWithColor(context, _controlColor.CGColor);
    CGContextStrokeEllipseInRect(context, innerCircleRect);
    
    //draw first inner detail circle
    CGContextSaveGState(context);
    CGRect innerDetailCircleRect = [self modifyCircleRect:innerCircleRect withRadiusDelta:_innerCircleEdgeWidth/2 + _innerDetailCircleEdgeWidth/2];
    CGContextSetLineWidth(context, _innerDetailCircleEdgeWidth);
    CGContextSetStrokeColorWithColor(context, _innerDetailCircleColor.CGColor);
    CGContextStrokeEllipseInRect(context, innerDetailCircleRect);
    
    //draw second inner detail circle
    CGRect outerDetailCircleRect = [self modifyCircleRect:innerDetailCircleRect withRadiusDelta:_innerDetailCircleEdgeWidth/2 + _outerDetailCircleEdgeWidth/2];
    CGContextSetLineWidth(context, _outerDetailCircleEdgeWidth);
    CGContextSetStrokeColorWithColor(context, _outerDetailCircleColor.CGColor);
    CGContextStrokeEllipseInRect(context, outerDetailCircleRect);
    CGContextRestoreGState(context);
    
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint buttonCenter = controlButton.center;
    CGFloat angleInRads = atan2(buttonCenter.y - circleCenter.y, buttonCenter.x - circleCenter.x);
    CGFloat innerCircleRadius = innerCircleRect.size.width/2;
    
    //add full-circle arc from the bottom of the circle to the button location
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablePath, nil, circleCenter.x, circleCenter.y);
    CGPathAddArc(mutablePath, nil, circleCenter.x, circleCenter.y, _mainCircleRect.size.height/2, M_PI_2, angleInRads, 0);
    CGPathCloseSubpath(mutablePath);
    
    //add the inner arc that will cover the full-circle arc (due to even-odd filling)
    CGPathMoveToPoint(mutablePath, nil, circleCenter.x, circleCenter.y);
    CGPathAddArc(mutablePath, nil, circleCenter.x, circleCenter.y, innerCircleRadius + _innerCircleEdgeWidth/2, M_PI_2, angleInRads, 0);
    CGPathCloseSubpath(mutablePath);
    
    //fill both paths to draw the progress fill
    CGContextAddPath(context, mutablePath);
    CGContextSetFillColorWithColor(context, _fillColor.CGColor);
    CGContextEOFillPath(context);
    
    //draw the line capping the edge of the fill progress
    CGFloat progressOnInnerCircleX = (innerCircleRadius - _innerCircleEdgeWidth/2) * cos(angleInRads) + circleCenter.x;
    CGFloat progressOnInnerCircleY = (innerCircleRadius - _innerCircleEdgeWidth/2) * sin(angleInRads) + circleCenter.y;
    
    CGContextMoveToPoint(context, progressOnInnerCircleX, progressOnInnerCircleY);
    CGContextAddLineToPoint(context, controlButton.center.x, controlButton.center.y);
    CGContextStrokePath(context);
}

- (CGRect)modifyCircleRect:(CGRect)rect withRadiusDelta:(CGFloat)radiusDelta
{
    CGRect newRect = rect;
    newRect.origin.x -= radiusDelta;
    newRect.origin.y -= radiusDelta;
    newRect.size.width += radiusDelta*2;
    newRect.size.height += radiusDelta*2;
    return newRect;
}


#pragma mark -
#pragma mark RotaryControlButton Callback Methods

- (void)rotaryControlButtonDidMoveToPercentage:(CGFloat)percentage
{
    _percentage = percentage;
    percentageLabel.text = [NSString stringWithFormat:@"%0.0f", (_maxValue * _percentage)];
    
    [self setNeedsDisplay];
}

- (void)rotaryControlButtonDidFinishMovingFromTouch
{
    if ([_delegate respondsToSelector:@selector(rotaryControlDidFinishChangingValueFromUserTouch:)])
        [_delegate rotaryControlDidFinishChangingValueFromUserTouch:self];
}

@end


@implementation RotaryControlButton

- (void)moveButtonToPercentage:(CGFloat)percentage
{
    CGFloat angleInRadians = 2 * M_PI * percentage + M_PI_2;
    CGPoint circleCenter = CGPointMake(CGRectGetMidY(_controlView.mainCircleRect), CGRectGetMidX(_controlView.mainCircleRect));
    CGFloat buttonCenterX = _controlView.mainCircleRadius * cos(angleInRadians) + circleCenter.x;
    CGFloat buttonCenterY = _controlView.mainCircleRadius * sin(angleInRadians) + circleCenter.y;
    self.center = CGPointMake(buttonCenterX, buttonCenterY);
    
    CGFloat percentageOfMove = angleInRadians - M_PI_2;
    if (percentageOfMove < 0)
        percentageOfMove += 2*M_PI;
    percentageOfMove /= 2*M_PI;
    
    [_controlView rotaryControlButtonDidMoveToPercentage:percentageOfMove];
}

//moves the button with the touch, keeping the button anchored to the circle's edge
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.superview];
    CGPoint circleCenter = CGPointMake(CGRectGetMidY(_controlView.mainCircleRect), CGRectGetMidX(_controlView.mainCircleRect));
    CGFloat touchAngle = atan2(touchPoint.y - circleCenter.y, touchPoint.x - circleCenter.x);
    
    CGFloat percentageOfTouch = touchAngle - M_PI_2;
    if (percentageOfTouch < 0)
        percentageOfTouch += 2*M_PI;
    percentageOfTouch /= 2*M_PI;
    
    if (_controlView.percentage < kLOWER_BOUNDS_FOR_TOUCH_BUFFER && percentageOfTouch > kUPPER_BOUNDS_FOR_TOUCH_BUFFER)
    {
        touchAngle = M_PI_2;
        percentageOfTouch = 0.0;
    }
    else if (_controlView.percentage > kUPPER_BOUNDS_FOR_TOUCH_BUFFER && percentageOfTouch < kLOWER_BOUNDS_FOR_TOUCH_BUFFER)
    {
        touchAngle = 2 * M_PI + M_PI_2;
        percentageOfTouch = 1.0;
    }
    CGFloat circleX = _controlView.mainCircleRadius * cos(touchAngle) + circleCenter.x;
    CGFloat circleY = _controlView.mainCircleRadius * sin(touchAngle) + circleCenter.y;
    self.center = CGPointMake(circleX, circleY);
    
    [super touchesMoved:touches withEvent:event];
    
    [_controlView rotaryControlButtonDidMoveToPercentage:percentageOfTouch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [_controlView rotaryControlButtonDidFinishMovingFromTouch];
}

@end
