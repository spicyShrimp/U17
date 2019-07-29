//
//  UINavigationSXFixSpace.m
//  UINavigation-SXFixSpace
//
//  Created by charles on 2019/7/26.
//  Copyright © 2018年 None. All rights reserved.
//

#import "UINavigationSXFixSpace.h"
#import <objc/runtime.h>

void sx_swizzle(Class oldClass, NSString *oldSelector, Class newClass) {
    NSString *newSelector = [NSString stringWithFormat:@"sx_%@", oldSelector];
    Method old = class_getInstanceMethod(oldClass, NSSelectorFromString(oldSelector));
    Method new = class_getInstanceMethod(newClass, NSSelectorFromString(newSelector));
    method_exchangeImplementations(old, new);
}

@implementation UINavigationConfig

+ (instancetype)shared {
    static UINavigationConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

-(instancetype)init {
    if (self = [super init]) {
        self.sx_defaultFixSpace = 0;
        self.sx_disableFixSpace = NO;
    }
    return self;
}

- (CGFloat)sx_systemSpace {
    return MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) > 375 ? 20 : 16;
}

@end

@implementation UINavigationItem (SXFixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {} else {
            NSArray <NSString *>*oriSels = @[@"setLeftBarButtonItem:",
                                             @"setLeftBarButtonItem:animated:",
                                             @"setLeftBarButtonItems:",
                                             @"setLeftBarButtonItems:animated:",
                                             @"setRightBarButtonItem:",
                                             @"setRightBarButtonItem:animated:",
                                             @"setRightBarButtonItems:",
                                             @"setRightBarButtonItems:animated:"];
            
            [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
                sx_swizzle(self, oriSel, self);
            }];
        }
    });
}

-(void)sx_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

-(void)sx_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem animated:(BOOL)animated {
    if (!UINavigationConfig.shared.sx_disableFixSpace && leftBarButtonItem) {//存在按钮且需要调节
        [self setLeftBarButtonItems:@[leftBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self sx_setLeftBarButtonItem:leftBarButtonItem animated:animated];
    }
}


-(void)sx_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

-(void)sx_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems animated:(BOOL)animated {
    if (!UINavigationConfig.shared.sx_disableFixSpace && leftBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
        CGFloat width = UINavigationConfig.shared.sx_defaultFixSpace - UINavigationConfig.shared.sx_systemSpace;
        if (firstItem.width == width) {//已经存在space
            [self sx_setLeftBarButtonItems:leftBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:leftBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self sx_setLeftBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self sx_setLeftBarButtonItems:leftBarButtonItems animated:animated];
    }
}

-(void)sx_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    [self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (void)sx_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem animated:(BOOL)animated {
    if (![UINavigationConfig shared].sx_disableFixSpace && rightBarButtonItem) {//存在按钮且需要调节
        [self setRightBarButtonItems:@[rightBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self sx_setRightBarButtonItem:rightBarButtonItem animated:animated];
    }
}

-(void)sx_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (void)sx_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems animated:(BOOL)animated {
    if (!UINavigationConfig.shared.sx_disableFixSpace && rightBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
        CGFloat width = UINavigationConfig.shared.sx_defaultFixSpace - UINavigationConfig.shared.sx_systemSpace;
        if (firstItem.width == width) {//已经存在space
            [self sx_setRightBarButtonItems:rightBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:rightBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self sx_setRightBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self sx_setRightBarButtonItems:rightBarButtonItems animated:animated];
    }
}

-(UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end

@implementation NSObject (SXFixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            NSDictionary <NSString *, NSString *>*oriSels = @{@"_UINavigationBarContentView": @"layoutSubviews",
                                                              @"_UINavigationBarContentViewLayout": @"_updateMarginConstraints"};
            [oriSels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull cls, NSString * _Nonnull oriSel, BOOL * _Nonnull stop) {
                sx_swizzle(NSClassFromString(cls), oriSel, NSObject.class);
            }];
        }
    });
}

- (void)sx_layoutSubviews {
    [self sx_layoutSubviews];
    if (UINavigationConfig.shared.sx_disableFixSpace) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentView")]) return;
    id layout = [self valueForKey:@"_layout"];
    if (!layout) return;
    SEL selector = NSSelectorFromString(@"_updateMarginConstraints");
    IMP imp = [layout methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(layout, selector);
}

- (void)sx__updateMarginConstraints {
    [self sx__updateMarginConstraints];
    if (UINavigationConfig.shared.sx_disableFixSpace) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentViewLayout")]) return;
    [self sx_adjustLeadingBarConstraints];
    [self sx_adjustTrailingBarConstraints];
}

- (void)sx_adjustLeadingBarConstraints {
    if (UINavigationConfig.shared.sx_disableFixSpace) return;
    NSArray<NSLayoutConstraint *> *leadingBarConstraints = [self valueForKey:@"_leadingBarConstraints"];
    if (!leadingBarConstraints) return;
    CGFloat constant = UINavigationConfig.shared.sx_defaultFixSpace - UINavigationConfig.shared.sx_systemSpace;
    for (NSLayoutConstraint *constraint in leadingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeLeading &&
            constraint.secondAttribute == NSLayoutAttributeLeading) {
            constraint.constant = constant;
        }
    }
}

- (void)sx_adjustTrailingBarConstraints {
    if (UINavigationConfig.shared.sx_disableFixSpace) return;
    NSArray<NSLayoutConstraint *> *trailingBarConstraints = [self valueForKey:@"_trailingBarConstraints"];
    if (!trailingBarConstraints) return;
    CGFloat constant = UINavigationConfig.shared.sx_systemSpace - UINavigationConfig.shared.sx_defaultFixSpace;
    for (NSLayoutConstraint *constraint in trailingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTrailing &&
            constraint.secondAttribute == NSLayoutAttributeTrailing) {
            constraint.constant = constant;
        }
    }
}

@end

