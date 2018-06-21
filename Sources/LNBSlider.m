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
@property (assign, nonatomic) CGFloat lastSetValue;

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
    [super setMaximumTrackTintColor:maximumTrackTintColor];
    self.maximumNodesLayersTintColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    [super setMinimumTrackImage:[self.class imageWithColor:minimumTrackTintColor] forState:UIControlStateNormal];
    [super setMinimumTrackTintColor:minimumTrackTintColor];
    self.minimumNodesLayersTintColor = minimumTrackTintColor;
}

- (void)setMinimumValue:(float)minimumValue {
    // Do nothing
}

- (void)setMaximumValue:(float)maximumValue {
    // Do nothing
}

- (void)setValue:(float)value {
    float oldValue = self.value;
    if (value > self.maximumValue) {
        [super setValue:self.maximumValue animated:NO];
    } else if (value < self.minimumValue) {
        [super setValue:self.minimumValue animated:NO];
    } else {
        [super setValue:value animated:NO];
    }
    NSLog(@"setValue: %.2f", value);
    [self updateNodes];
//    if ((int)oldValue != (int)self.value && self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
//        [self.delegate slider:self didSelectValue:self.value];
//    }
}

- (void)setValue:(float)value animated:(BOOL)animated {
    float oldValue = self.value;
    if (value > self.maximumValue) {
        [super setValue:self.maximumValue animated:animated];
    } else if (value < self.minimumValue) {
        [super setValue:self.minimumValue animated:animated];
    } else {
        if (!self.tracking) {
            value = roundf(value);
        }

        [super setValue:value animated:animated];
    }
    NSLog(@"setValueAnimated: %.2f", value);
    [self updateNodes];
    if ((int)oldValue != (int)self.value && self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
        [self.delegate slider:self didSelectValue:self.value];
    }
    if (self.tracking && (int)self.lastSetValue != roundf(self.value)) {
        NSLog(@"manual %d to %d", (int)self.lastSetValue, (int)roundf(self.value));
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    self.lastSetValue = roundf(self.value);
    NSLog(@"lastValue: %.2f", self.lastSetValue);
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
    self.lastSetValue = self.lastValue;

    CALayer *leftLayer = self.layer.sublayers[1];
    CALayer *rightLayer = self.layer.sublayers[0];
    
    CGFloat nodeDistance = (CGRectGetWidth(self.bounds) - 2*LNBSliderEndOffset)/(self.numberOfNodes - 1);
    for (NSInteger i = 0; i < self.numberOfNodes; i++) {
        CGFloat rectX = LNBSliderEndOffset + i*nodeDistance - self.nodeDiameter/2.0;
        CGFloat rectY = CGRectGetMidY(self.bounds) - self.nodeDiameter/2.0;
        CGFloat width = self.nodeDiameter;
        CGFloat height = self.nodeDiameter;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.opacity = 1;
        layer.cornerRadius = width/2.0;
//        layer.backgroundColor = i <= self.value ? self.minimumNodesLayersTintColor.CGColor : self.maximumNodesLayersTintColor.CGColor;
        layer.backgroundColor = i <= self.value ? self.minimumTrackTintColor.CGColor : self.maximumTrackTintColor.CGColor;
        layer.frame = CGRectMake(rectX, rectY, width, height);
        [self.layer insertSublayer:layer atIndex:0];
        [self.nodesLayers addObject:layer];
    }

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *whole = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                     CGRectGetMinX(self.bounds),
                                                                     CGRectGetMidY(self.bounds) - 2,
                                                                     CGRectGetMaxX(self.bounds) - (LNBSliderEndOffset - self.nodeDiameter/2.0) +LNBSliderEndOffset - self.nodeDiameter/2.0,
                                                                     4)];
    UIBezierPath *left = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                     CGRectGetMinX(self.bounds),
                                                                     CGRectGetMidY(self.bounds) - 2,
                                                                     LNBSliderEndOffset - self.nodeDiameter/2.0,
                                                                     4)];
    UIBezierPath *right = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                      CGRectGetMaxX(self.bounds) - (LNBSliderEndOffset - self.nodeDiameter/2.0),
                                                                      CGRectGetMidY(self.bounds) - 2,
                                                                      LNBSliderEndOffset - self.nodeDiameter/2.0,
                                                                      4)];
    UIBezierPath *mid = [UIBezierPath bezierPathWithRect:CGRectMake(
                                                                     CGRectGetMinX(self.bounds) +
                                                                     LNBSliderEndOffset - self.nodeDiameter/2.0,
                                      CGRectGetMidY(self.bounds) - 2,
                                                                     CGRectGetMinX(self.bounds) +
                                                                     LNBSliderEndOffset - self.nodeDiameter/2.0,
                                                                      CGRectGetMaxX(self.bounds) - (LNBSliderEndOffset - self.nodeDiameter/2.0) -
                                                                      4)];
//    [whole appendPath:mid];
//    whole.usesEvenOddFillRule = YES;
//    maskLayer.fillColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
//    maskLayer.fillRule = kCAFillRuleEvenOdd;
//    maskLayer.path = whole.CGPath;
//    self.layer.mask = maskLayer;
//    [self.layer addSublayer:maskLayer];

    CAShapeLayer *leftMask = [CAShapeLayer layer];
    CGRect leftFrame = leftLayer.frame;
    CGRect lmaskFrame = CGRectMake(0, 0, LNBSliderEndOffset - self.nodeDiameter/2.0, leftFrame.size.height);
//    leftMask.frame = leftFrame;
    UIBezierPath *lwhole = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, leftFrame.size.width, leftFrame.size.height)];
    UIBezierPath *lmask = [UIBezierPath bezierPathWithRect:lmaskFrame];
    [lmask appendPath:lwhole];
    leftMask.path = lmask.CGPath;
//    leftMask.path = [UIBezierPath bezierPathWithRect:lmaskFrame].CGPath;
    leftMask.fillRule = kCAFillRuleEvenOdd;
    leftMask.fillColor = [UIColor blackColor].CGColor;
//    leftMask.backgroundColor = [UIColor clearColor].CGColor;
//    [self.layer addSublayer:leftMask];
    leftLayer.mask = leftMask;


//    CALayer *leftmaskLayer = [CALayer layer];
//    leftmaskLayer.frame = CGRectMake(CGRectGetMinX(self.bounds),
//                                     CGRectGetMidY(self.bounds) - 2,
//                                     LNBSliderEndOffset - self.nodeDiameter/2.0,
//                                     4);
//    leftmaskLayer.backgroundColor = [UIColor clearColor].CGColor;
//    [maskLayer addSublayer:leftmaskLayer];
//    [self.layer insertSublayer:leftmaskLayer atIndex:(int)self.numberOfNodes + 2];
//    [self.maskLayers addObject:leftmaskLayer];
    
//    CALayer *rightMaskLayer = [CALayer layer];
//    rightMaskLayer.frame = CGRectMake(CGRectGetMaxX(self.bounds) - (LNBSliderEndOffset - self.nodeDiameter/2.0),
//                                      CGRectGetMidY(self.bounds) - 2,
//                                      LNBSliderEndOffset - self.nodeDiameter/2.0,
//                                      4);
//    rightMaskLayer.backgroundColor = [UIColor clearColor].CGColor;
//    [maskLayer addSublayer:rightMaskLayer];
//    [self.layer insertSublayer:rightMaskLayer atIndex:(int)self.numberOfNodes + 2];
//    [self.maskLayers addObject:rightMaskLayer];
//    self.layer.mask = maskLayer;
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
//        layer.backgroundColor = i <= currentValue ? self.minimumNodesLayersTintColor.CGColor : self.maximumNodesLayersTintColor.CGColor;
        layer.backgroundColor = i <= currentValue ? self.minimumTrackTintColor.CGColor : self.maximumTrackTintColor.CGColor;
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
            NSLog(@"idx: %d round: %.2f value: %d", idx, roundf(self.value), (NSInteger)self.value);
            if (idx != roundf(self.value)) {
//                super.value = idx;
//                [self updateNodes];
//                if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
//                    [self.delegate slider:self didSelectValue:self.value];
//                }
                [self endTrackingWithTouch:touch withEvent:event];
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
//    super.value = roundf(self.value);
//    [self updateNodes];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
//        [self.delegate slider:self didSelectValue:self.value];
//    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"end tracking");
    [super endTrackingWithTouch:touch withEvent:event];
//    super.value = roundf(self.value);
//    [self updateNodes];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectValue:)]) {
//        [self.delegate slider:self didSelectValue:self.value];
//    }
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
