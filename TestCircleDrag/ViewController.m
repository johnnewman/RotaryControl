//
//  ViewController.m
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kROTARY_SIZE ((568 - 20) / 2)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    primaryRotaryControl = [[RotaryControlView alloc] initWithFrame:CGRectMake(self.view.frame.size.width /2 - kROTARY_SIZE/2, 0, kROTARY_SIZE, kROTARY_SIZE)];
    primaryRotaryControl.delegate = self;
    [self.view addSubview:primaryRotaryControl];
    
    secondaryRotaryControl = [[RotaryControlView alloc] initWithFrame:CGRectMake(self.view.frame.size.width /2 - kROTARY_SIZE/2, kROTARY_SIZE, kROTARY_SIZE, kROTARY_SIZE)];
    secondaryRotaryControl.delegate = self;
    secondaryRotaryControl.outerDetailCircleColor = [UIColor colorWithRed:0.7098 green:0.8314 blue:0.8902 alpha:1.0];
    secondaryRotaryControl.innerDetailCircleColor = [UIColor colorWithRed:0.4706 green:0.6902 blue:0.8078 alpha:1.0];
    secondaryRotaryControl.fillColor = [UIColor colorWithRed:0.1725 green:0.5725 blue:0.8314 alpha:1.0];
    secondaryRotaryControl.controlColor = [UIColor darkGrayColor];
    [self.view addSubview:secondaryRotaryControl];
    
    self.view.backgroundColor = [UIColor purpleColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rotaryControlDidFinishChangingValueFromUserTouch:(RotaryControlView *)rotaryControlView
{
    RotaryControlView *rotaryControlToAnimate;
    if (rotaryControlView == primaryRotaryControl)
        rotaryControlToAnimate = secondaryRotaryControl;
    else
        rotaryControlToAnimate = primaryRotaryControl;
    [rotaryControlToAnimate setPercentage:rotaryControlView.percentage animated:YES];
}





@end
