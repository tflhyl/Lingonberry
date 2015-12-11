//
//  LNBSlider.h
//  Lingonberry
//
//  Created by Theodore Felix Leo on 11/12/15.
//  Copyright © 2015 Theodore Felix Leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNBSliderDelegate.h"

@interface LNBSlider : UISlider

@property (assign, nonatomic, readonly) NSUInteger numberOfNodes;
@property (assign, nonatomic) CGFloat nodeDiameter;
@property (weak, nonatomic) id<LNBSliderDelegate> delegate;

- (instancetype)initWithNumberOfNodes:(NSUInteger)numberOfNodes;
- (void)setNeedsDrawNodes;

@end
