//
//  ViewController.m
//  TestCircleDrag
//
//  Created by John Newman on 6/3/13.
//  Copyright (c) 2013 John Newman. All rights reserved.
//

#import "ViewController.h"
#import "RotaryControlView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    RotaryControlView *rotaryControl = [[RotaryControlView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [self.view addSubview:rotaryControl];
    rotaryControl.center = self.view.center;
    
    rotaryControl.percentage = 75;
    
    
    self.view.backgroundColor = [UIColor purpleColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
