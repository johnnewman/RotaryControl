//
//  CircleControlView.m
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "CircleControlView.h"
#import <QuartzCore/QuartzCore.h>

#define kBUTTON_WIDTH 30

@interface CircleControlButton : UIButton {
    NSInteger buttonCenterRadius;
}
@property (nonatomic, weak) id<CircleControlButtonDelegate> delegate;
@property (nonatomic) CGRect circleRect;
@end


@implementation CircleControlView

static UIColor *filledOrangeColor;
static UIColor *darkOrangeColor;
static UIColor *lightOrangeColor;
static UIColor *customGrayColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        filledOrangeColor = [UIColor colorWithRed:1.0 green:0.7216 blue:0.0 alpha:1.0];
        darkOrangeColor = [UIColor colorWithRed:1.0 green:0.7922 blue:0.2471 alpha:1.0];
        lightOrangeColor = [UIColor colorWithRed:1.0 green:0.8588 blue:0.4980 alpha:1.0];
        customGrayColor = [UIColor colorWithRed:0.5765 green:0.5843 blue:0.5961 alpha:1.0];
        
        CGFloat circleDiameter = frame.size.width - (kBUTTON_WIDTH * 2);
        circleRect = CGRectMake(self.frame.origin.x + kBUTTON_WIDTH, self.frame.origin.y + kBUTTON_WIDTH, circleDiameter, circleDiameter);
        
        controlButton = [[CircleControlButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - kBUTTON_WIDTH/2, self.frame.size.height - kBUTTON_WIDTH, kBUTTON_WIDTH, kBUTTON_WIDTH)];
        controlButton.layer.cornerRadius = kBUTTON_WIDTH/2;
        controlButton.backgroundColor = customGrayColor;
        controlButton.circleRect = circleRect;
        controlButton.delegate = self;
        [self addSubview:controlButton];
        
        
        percentageLabel = [[UILabel alloc] initWithFrame:self.frame];
        percentageLabel.backgroundColor = [UIColor clearColor];
        percentageLabel.textAlignment = NSTextAlignmentCenter;
        percentageLabel.font = [UIFont systemFontOfSize:90];
        percentageLabel.textColor = customGrayColor;
        [self addSubview:percentageLabel];
        
    }
    return self;
}

- (void)controlButtonDidMove:(CircleControlButton *)controlButton {
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //stroke main circle
    CGRect outerOrangeEllipse = CGRectMake(circleRect.origin.x - kBUTTON_WIDTH/2, circleRect.origin.y - kBUTTON_WIDTH/2, circleRect.size.width + kBUTTON_WIDTH, circleRect.size.width + kBUTTON_WIDTH);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, outerOrangeEllipse);
    
    CGContextSetLineWidth(context, 4.0);
    CGContextSetStrokeColorWithColor(context, filledOrangeColor.CGColor);
    CGContextStrokeEllipseInRect(context, outerOrangeEllipse);
    
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint buttonCenter = controlButton.center;
    
    CGFloat innerGrayCircleLineWidth = 4.0;
    CGFloat innerDarkOrangeCircleLineWidth = 9.0;
    CGFloat innerLightOrangeCircleLineWidth = 7.0;
    
    CGRect innerGrayCircle = [self scaleCircleRect:circleRect withScale:0.8];
    CGRect innerDarkOrangeCircle = [self modifyCircleRect:innerGrayCircle withRadiusDelta:innerGrayCircleLineWidth/2 + innerDarkOrangeCircleLineWidth/2];
    CGRect innerLightOrangeCircle = [self modifyCircleRect:innerDarkOrangeCircle withRadiusDelta:innerDarkOrangeCircleLineWidth/2 + innerLightOrangeCircleLineWidth/2];
    
    
    
    CGContextSetLineWidth(context, innerGrayCircleLineWidth);
    CGContextSetStrokeColorWithColor(context, customGrayColor.CGColor);
    CGContextStrokeEllipseInRect(context, innerGrayCircle);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, innerDarkOrangeCircleLineWidth);
    CGContextSetStrokeColorWithColor(context, darkOrangeColor.CGColor);
    CGContextStrokeEllipseInRect(context, innerDarkOrangeCircle);
    
    CGContextSetLineWidth(context, innerLightOrangeCircleLineWidth);
    CGContextSetStrokeColorWithColor(context, lightOrangeColor.CGColor);
    CGContextStrokeEllipseInRect(context, innerLightOrangeCircle);
    CGContextRestoreGState(context);
    
    //draw the initial line to the control button
    CGFloat angleInRads = atan2(buttonCenter.y - circleCenter.y, buttonCenter.x - circleCenter.x);
    
    CGFloat innerGrayCircleRadius = innerGrayCircle.size.width/2;
    
    //add full-circle arct from the bottom of the circle to the button location
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablePath, nil, circleCenter.x, circleCenter.y);
    CGPathAddArc(mutablePath, nil, circleCenter.x, circleCenter.y, outerOrangeEllipse.size.height/2, M_PI_2, angleInRads, 0);
    CGPathCloseSubpath(mutablePath);
    
    //add the inner arc that will cover the full-circle arc (due to even-odd filling)
    CGPathMoveToPoint(mutablePath, nil, circleCenter.x, circleCenter.y);
    CGPathAddArc(mutablePath, nil, circleCenter.x, circleCenter.y, innerGrayCircleRadius + innerGrayCircleLineWidth/2, M_PI_2, angleInRads, 0);
    CGPathCloseSubpath(mutablePath);
    
    CGContextAddPath(context, mutablePath);
    CGContextSetFillColorWithColor(context, filledOrangeColor.CGColor);
    CGContextEOFillPath(context);
    
    CGFloat outerCircleX = outerOrangeEllipse.size.height/2 * cos(angleInRads) + circleCenter.x;
    CGFloat outerCircleY = outerOrangeEllipse.size.height/2 * sin(angleInRads) + circleCenter.y;
    CGFloat innerCircleX = (innerGrayCircleRadius - innerGrayCircleLineWidth/2) * cos(angleInRads) + circleCenter.x;
    CGFloat innerCircleY = (innerGrayCircleRadius - innerGrayCircleLineWidth/2) * sin(angleInRads) + circleCenter.y;
    
    CGContextMoveToPoint(context, innerCircleX, innerCircleY);
    CGContextAddLineToPoint(context, outerCircleX, outerCircleY);
    CGContextStrokePath(context);
    
    
    CGFloat degrees = (angleInRads - M_PI_2) *  180 / M_PI;
    degrees = degrees > 0.0 ? degrees : degrees + 360;
    _percentage = degrees / 360;
    percentageLabel.text = [NSString stringWithFormat:@"%0.0f", _percentage * 100];
}

- (CGRect)scaleCircleRect:(CGRect)rect withScale:(CGFloat)scale
{
    CGFloat scaledCircleRadius = rect.size.width / 2 * scale;
    return CGRectMake(CGRectGetMidX(rect) - scaledCircleRadius, CGRectGetMidY(rect) - scaledCircleRadius, scaledCircleRadius * 2, scaledCircleRadius * 2);
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

@end

@implementation CircleControlButton

- (void)setCircleRect:(CGRect)circleRect
{
    _circleRect = circleRect;
    buttonCenterRadius = (CGRectGetWidth(_circleRect) / 2) + kBUTTON_WIDTH / 2;
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
