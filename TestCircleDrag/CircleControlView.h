//
//  CircleControlView.h
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CircleControlButton;

@protocol CircleControlButtonDelegate <NSObject>
- (void)controlButtonDidMove:(CircleControlButton*)controlButton;
@end

@interface CircleControlView : UIView <CircleControlButtonDelegate> {
    CircleControlButton *controlButton;
    CGRect circleRect;
}
@end

