//
//  ViewController.h
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotaryControlView.h"

@interface ViewController : UIViewController <RotaryControlDelegate> {
    RotaryControlView *primaryRotaryControl;
    RotaryControlView *secondaryRotaryControl;
}

@end
