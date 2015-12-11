//
//  LNBEXViewController.m
//  Lingonberry-example
//
//  Created by Theodore Felix Leo on 11/12/15.
//  Copyright © 2015 Theodore Felix Leo. All rights reserved.
//

#import "LNBEXViewController.h"
#import "LNBSlider.h"

@interface LNBEXViewController () <LNBSliderDelegate>

@property (weak, nonatomic) LNBSlider *slider;
@property (weak, nonatomic) UILabel *label;

@end

@implementation LNBEXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LNBSlider *slider = [[LNBSlider alloc] initWithNumberOfNodes:8];
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [slider setMinimumTrackTintColor:[UIColor colorWithRed:0.78 green:0.16 blue:0.25 alpha:1.0]];
    [slider setMaximumTrackTintColor:[UIColor lightGrayColor]];
    slider.value = 5;
    
    [self.view addSubview:slider];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeTop multiplier:1 constant:100]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    [slider addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
    self.slider = slider;
    self.slider.delegate = self;
    
    UIButton *button = [[UIButton alloc] init];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"Max" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapMaxButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeTop multiplier:1 constant:200]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = [NSString stringWithFormat:@"Selected value: %lu", (unsigned long)slider.value];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeTop multiplier:1 constant:160]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual toItem:self.view
                                                          attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    self.label = label;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.slider setNeedsDrawNodes];
}

- (void)tapMaxButton:(id)sender {
    self.slider.value = 7;
}

#pragma mark - LNBSliderDelegate

- (void)slider:(LNBSlider *)slider didSelectValue:(NSUInteger)value {
    NSLog(@"Selected value: %lu", (unsigned long)value);
    self.label.text = [NSString stringWithFormat:@"Selected value: %lu", (unsigned long)value];
}

@end
