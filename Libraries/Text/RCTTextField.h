/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <AppKit/AppKit.h>

@class RCTEventDispatcher;

@interface RCTTextField : NSTextField <NSTextFieldDelegate>

@property (nonatomic, assign) BOOL caretHidden;
@property (nonatomic, assign) BOOL autoCorrect;
@property (nonatomic, assign) BOOL selectTextOnFocus;
@property (nonatomic, assign) NSEdgeInsets contentInset;
@property (nonatomic, strong) NSColor *placeholderTextColor;
@property (nonatomic, assign) NSInteger mostRecentEventCount;
@property (nonatomic, strong) NSNumber *maxLength;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher NS_DESIGNATED_INITIALIZER;
//- (void)textFieldDidChange;

@end
