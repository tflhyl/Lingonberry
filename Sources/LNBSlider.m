//
//  LNBSlider.m
//  Lingonberry
//
//  Created by Theodore Felix Leo on 11/12/15.
//  Copyright © 2015 Theodore Felix Leo. All rights reserved.
//

#import "LNBSlider.h"

CGFloat const LNBSliderEndOffset = 15.5;

@interface LNBSlider ()

@property (strong, nonatomic) NSMutableArray *nodesLayers;
@property (assign, nonatomic) NSUInteger numberOfNodes;
@property (assign, nonatomic) BOOL needsDrawNodes;
@property (assign, nonatomic) CGFloat lastValue;
@property (strong, nonatomic) UIColor *minimumNodesLayersTintColor;
@property (strong, nonatomic) UIColor *maximumNodesLayersTintColor;
@property (strong, nonatomic) NSMutableArray *maskLayers;

@end

@implementation LNBSlider

- (instancetype)initWithNumberOfNodes:(NSUInteger)numberOfNodes {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setNeedsDrawNodes];
        self.numberOfNodes = numberOfNodes;
        [super setMinimumValue:0];
        [super setMaximumValue:numberOfNodes - 1];
        self.nodeDiameter = 12;
        self.minimumNodesLayersTintColor = [UIColor redColor];
        self.maximumNodesLayersTintColor = [UIColor lightGrayColor];
        self.continuous = NO;
    }
    return self;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    [super setMaximumTrackImage:[self.class imageWithColor:maximumTrackTintColor] forState:UIControlStateNormal];
    self.maximumNodesLayersTintColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    [super setMinimumTrackImage:[self.class imageWithColor:minimumTrackTintColor] forState:UIControlStateNormal];
    self.minimumNodesLayersTintColor = minimumTrackTintColor;
}

- (void)setMinimumValue:(float)minimumValue {
    // Do nothing
}

- (void)setMaximumValue:(float)maximumValue {
    // Do nothing
}

- (void)setValue:(float)value {
    if (value > self.maximumValue) {
        [super setValue:self.maximumValue];
    } else if (value < self.minimumValue) {
        [super setValue:self.minimumValue];
    } else {
        [super setValue:value];
    }
    [self updateNodes];
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
        [self.delegate slider:self didSelectValue:self.value];
    }
}

- (void)setValue:(float)value animated:(BOOL)animated {
    if (value > self.maximumValue) {
        [super setValue:self.maximumValue animated:animated];
    } else if (value < self.minimumValue) {
        [super setValue:self.minimumValue animated:animated];
    } else {
        [super setValue:value animated:animated];
    }
    [self updateNodes];
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
        [self.delegate slider:self didSelectValue:self.value];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self drawNodesIfNeeded];
}

- (void)drawNodesIfNeeded {
    if (!self.needsDrawNodes || self.numberOfNodes == 0 || self.nodeDiameter == 0) return;
    
    self.needsDrawNodes = NO;
    if (self.nodesLayers) {
        for (CAShapeLayer *layer in self.nodesLayers) {
            [layer removeFromSuperlayer];
        }
        for (CAShapeLayer *layer in self.maskLayers) {
            [layer removeFromSuperlayer];
        }
        [self.nodesLayers removeAllObjects];
        [self.maskLayers removeAllObjects];
    } else {
        self.nodesLayers = [NSMutableArray arrayWithCapacity:self.numberOfNodes];
        self.maskLayers = [NSMutableArray arrayWithCapacity:2];
    }
    self.lastValue = (NSInteger)self.value;
    
    CGFloat nodeDistance = (CGRectGetWidth(self.bounds) - 2*LNBSliderEndOffset)/(self.numberOfNodes - 1);
    for (NSInteger i = 0; i < self.numberOfNodes; i++) {
        CGFloat rectX = LNBSliderEndOffset + i*nodeDistance - self.nodeDiameter/2.0;
        CGFloat rectY = CGRectGetMidY(self.bounds) - self.nodeDiameter/2.0;
        CGFloat width = self.nodeDiameter;
        CGFloat height = self.nodeDiameter;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.opacity = 1;
        layer.cornerRadius = width/2.0;
        layer.backgroundColor = i <= self.value ? self.minimumNodesLayersTintColor.CGColor : self.maximumNodesLayersTintColor.CGColor;
        layer.frame = CGRectMake(rectX, rectY, width, height);
        [self.layer insertSublayer:layer atIndex:0];
        [self.nodesLayers addObject:layer];
    }
    
    CALayer *leftmaskLayer = [CALayer layer];
    leftmaskLayer.frame = CGRectMake(CGRectGetMinX(self.bounds),
                                     CGRectGetMidY(self.bounds) - 2,
                                     LNBSliderEndOffset - self.nodeDiameter/2.0,
                                     4);
    leftmaskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer insertSublayer:leftmaskLayer atIndex:(int)self.numberOfNodes + 2];
    [self.maskLayers addObject:leftmaskLayer];
    
    CALayer *rightMaskLayer = [CALayer layer];
    rightMaskLayer.frame = CGRectMake(CGRectGetMaxX(self.bounds) - (LNBSliderEndOffset - self.nodeDiameter/2.0),
                                      CGRectGetMidY(self.bounds) - 2,
                                      LNBSliderEndOffset - self.nodeDiameter/2.0,
                                      4);
    rightMaskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer insertSublayer:rightMaskLayer atIndex:(int)self.numberOfNodes + 2];
    [self.maskLayers addObject:rightMaskLayer];
}

- (void)setNeedsDrawNodes {
    _needsDrawNodes = YES;
}

- (void)updateNodes {
    NSInteger currentValue = (NSInteger)self.value;
    if (self.lastValue == currentValue) return;
    self.lastValue = currentValue;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSInteger i = 0; i < self.nodesLayers.count; i++) {
        CAShapeLayer *layer = self.nodesLayers[i];
        layer.backgroundColor = i <= currentValue ? self.minimumNodesLayersTintColor.CGColor : self.maximumNodesLayersTintColor.CGColor;
    }
    
    [CATransaction commit];
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect rect = [super trackRectForBounds:bounds];
    rect.size.width = bounds.size.width;
    rect.origin.x = bounds.origin.x;
    return rect;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL res = [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint touchLocation = [touch locationInView:self];
    for (CAShapeLayer *layer in self.nodesLayers) {
        CGRect touchFrame = layer.frame;
        touchFrame.origin.x -= 10;
        touchFrame.origin.y -= 10;
        touchFrame.size.width += 20;
        touchFrame.size.height += 20;
        if (CGRectContainsPoint(touchFrame, touchLocation)) {
            NSInteger idx = [self.nodesLayers indexOfObject:layer];
            if (idx != roundf(self.value)) {
                super.value = idx;
                [self updateNodes];
                if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
                    [self.delegate slider:self didSelectValue:self.value];
                }
                return NO;
            }
            break;
        }
    }
    [self updateNodes];
    return res;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL res = [super continueTrackingWithTouch:touch withEvent:event];
    [self updateNodes];
    return res;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    super.value = roundf(self.value);
    [self updateNodes];
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
        [self.delegate slider:self didSelectValue:self.value];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    super.value = roundf(self.value);
    [self updateNodes];
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
        [self.delegate slider:self didSelectValue:self.value];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 2);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
