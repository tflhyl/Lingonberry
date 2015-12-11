//
//  LNBSliderDelegate.h
//  Lingonberry-example
//
//  Created by Theodore Felix Leo on 11/12/15.
//  Copyright © 2015 Theodore Felix Leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LNBSlider;

@protocol LNBSliderDelegate <NSObject>

@optional

- (void)slider:(LNBSlider *)slider didSelectValue:(NSUInteger)value;

@end
