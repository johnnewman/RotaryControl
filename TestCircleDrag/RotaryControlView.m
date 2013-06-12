//
//  RotaryControlView.m
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "RotaryControlView.h"
#import <QuartzCore/QuartzCore.h>

@interface RotaryControlButton : UIButton {
    NSInteger buttonCenterRadius;
}
@property (nonatomic, weak) id<RotaryControlButtonDelegate> delegate;
@property (nonatomic) CGRect circleRect;
@end

@interface RotaryControlView ()
- (void)setupInitialLayout;
- (CGRect)modifyCircleRect:(CGRect)rect withRadiusDelta:(CGFloat)radiusDelta;
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
    
    _mainBackgroundColor = [UIColor whiteColor];
    _fillColor = [UIColor colorWithRed:1.0 green:0.7216 blue:0.0 alpha:1.0];
    _innerDetailCircleColor = [UIColor colorWithRed:1.0 green:0.7922 blue:0.2471 alpha:1.0];
    _outerDetailCircleColor = [UIColor colorWithRed:1.0 green:0.8588 blue:0.4980 alpha:1.0];
    _controlColor = [UIColor colorWithRed:0.5765 green:0.5843 blue:0.5961 alpha:1.0];
    
    _controlButtonSize = 35;
    _fillWidth = 40;
    _innerCircleEdgeWidth = 4.0;
    _outerCircleEdgeWidth = 4.0;
    _innerDetailCircleEdgeWidth = 9.0;
    _outerDetailCircleEdgeWidth = 7.0;
    
    CGFloat circleDiameter = self.frame.size.width - _controlButtonSize;
    mainCircleRect = CGRectMake(self.bounds.origin.x + _controlButtonSize / 2, self.bounds.origin.y + _controlButtonSize / 2, circleDiameter, circleDiameter);
    
    controlButton = [[RotaryControlButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(mainCircleRect) - _controlButtonSize/2, mainCircleRect.size.height, _controlButtonSize, _controlButtonSize)];
    controlButton.layer.cornerRadius = _controlButtonSize/2;
    controlButton.backgroundColor = _controlColor;
    controlButton.circleRect = mainCircleRect;
    controlButton.delegate = self;
    [self addSubview:controlButton];
    
    percentageLabel = [[UILabel alloc] initWithFrame:self.frame];
    percentageLabel.backgroundColor = [UIColor clearColor];
    percentageLabel.textAlignment = NSTextAlignmentCenter;
    percentageLabel.font = [UIFont systemFontOfSize:90];
    percentageLabel.textColor = _controlColor;
    [self addSubview:percentageLabel];
}

- (void)setControlColor:(UIColor *)controlColor {
    _controlColor = controlColor;
    controlButton.backgroundColor = _controlColor;
}

- (void)setPercentage:(CGFloat)percentage {
    [self setPercentage:percentage animated:NO];
}

- (void)setPercentage:(CGFloat)percentage animated:(BOOL)animated {
    _percentage = percentage;
    if (animated) {
        
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //fill main circle background
    CGContextSetFillColorWithColor(context, _mainBackgroundColor.CGColor);
    CGContextFillEllipseInRect(context, mainCircleRect);
    
    //stroke main circle edge
    CGContextSetLineWidth(context, _outerCircleEdgeWidth);
    CGContextSetStrokeColorWithColor(context, _fillColor.CGColor);
    CGContextStrokeEllipseInRect(context, mainCircleRect);
    
    //draw inner circle
    CGRect innerCircleRect = [self modifyCircleRect:mainCircleRect withRadiusDelta:-_fillWidth];
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
    CGPathAddArc(mutablePath, nil, circleCenter.x, circleCenter.y, mainCircleRect.size.height/2, M_PI_2, angleInRads, 0);
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
    
    //update percentage label
    CGFloat degrees = (angleInRads - M_PI_2) *  180 / M_PI;
    degrees = degrees > 0.0 ? degrees : degrees + 360;
    _percentage = degrees / 360;
    percentageLabel.text = [NSString stringWithFormat:@"%0.0f", _percentage * 100];
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
#pragma mark RotaryControlButtonDelegate Methods

- (void)controlButtonDidMove:(RotaryControlButton *)controlButton {
    [self setNeedsDisplay];
}

@end


@implementation RotaryControlButton

- (void)setCircleRect:(CGRect)circleRect
{
    _circleRect = circleRect;
    buttonCenterRadius = CGRectGetWidth(_circleRect) / 2;
}


//moves the button with the touch, keeping the button anchored to the circle's edge
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.superview];
    CGPoint circleCenter = CGPointMake(CGRectGetMidY(_circleRect), CGRectGetMidX(_circleRect));
    CGFloat touchAngle = atan2(touchPoint.y - circleCenter.y, touchPoint.x - circleCenter.x);
    CGFloat circleX = buttonCenterRadius * cos(touchAngle) + circleCenter.x;
    CGFloat circleY = buttonCenterRadius * sin(touchAngle) + circleCenter.y;
    self.center = CGPointMake(circleX, circleY);
    
    if ([_delegate respondsToSelector:@selector(controlButtonDidMove:)])
        [_delegate controlButtonDidMove:self];
    [super touchesMoved:touches withEvent:event];
}

@end
