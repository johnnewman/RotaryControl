//
//  CircleControlView.m
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "CircleControlView.h"
#import <QuartzCore/QuartzCore.h>

#define kBUTTON_WIDTH 60

@interface CircleControlButton : UIButton {
    NSInteger buttonCenterRadius;
}
@property (nonatomic, weak) id<CircleControlButtonDelegate> delegate;
@property (nonatomic) CGRect circleRect;
@end


@implementation CircleControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat circleDiameter = frame.size.width - (kBUTTON_WIDTH * 2);
        circleRect = CGRectMake(self.frame.origin.x + kBUTTON_WIDTH, self.frame.origin.y + kBUTTON_WIDTH, circleDiameter, circleDiameter);
        
        controlButton = [[CircleControlButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - kBUTTON_WIDTH/2, self.frame.size.height - kBUTTON_WIDTH, kBUTTON_WIDTH, kBUTTON_WIDTH)];
        controlButton.layer.cornerRadius = kBUTTON_WIDTH/2;
        controlButton.layer.borderWidth = 1.0;
        controlButton.backgroundColor = [UIColor clearColor];
        controlButton.circleRect = circleRect;
        controlButton.delegate = self;
        [self addSubview:controlButton];
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
    CGContextStrokeEllipseInRect(context, circleRect);
    
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint buttonCenter = controlButton.center;
    
    //draw the initial line to the bottom of the circle
    CGContextMoveToPoint(context, circleCenter.x, circleCenter.y);
    CGContextAddLineToPoint(context, circleCenter.x, CGRectGetMaxY(circleRect));
    CGContextStrokePath(context);

    //fill an arc from the bottom of the circle to the button location
    CGFloat angleInRads = atan2(buttonCenter.y - circleCenter.y, buttonCenter.x - circleCenter.x);
    CGContextMoveToPoint(context, circleCenter.x, circleCenter.y);
    CGContextAddArc(context, circleCenter.x, circleCenter.y, circleRect.size.height/2, M_PI_2, angleInRads, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
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
    touchPoint.x -= kBUTTON_WIDTH/2;
    touchPoint.y -= kBUTTON_WIDTH/2;
    
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
