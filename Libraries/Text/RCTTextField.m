/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTTextField.h"

#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
#import "NSView+React.h"

@implementation RCTTextField
{
  RCTEventDispatcher *_eventDispatcher;
  NSMutableArray *_reactSubviews;
  BOOL _jsRequestingFirstResponder;
  NSInteger _nativeEventCount;
  NSString * _placeholderString;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
  if ((self = [super initWithFrame:CGRectZero])) {
    RCTAssert(eventDispatcher, @"eventDispatcher is a required parameter");
    _eventDispatcher = eventDispatcher;
    self.delegate = self;

//    [self addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
//    [self addTarget:self action:@selector(textFieldBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
//    [self addTarget:self action:@selector(textFieldEndEditing) forControlEvents:UIControlEventEditingDidEnd];
//    [self addTarget:self action:@selector(textFieldSubmitEditing) forControlEvents:UIControlEventEditingDidEndOnExit];
//    self.bezeled         = NO;
//    self.editable        = NO;
    self.drawsBackground = NO;
    _reactSubviews = [NSMutableArray new];
  }
  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)setText:(NSString *)text
{
  NSInteger eventLag = _nativeEventCount - _mostRecentEventCount;
  if (eventLag == 0 && ![text isEqualToString:[self stringValue]]) {
    //NSRange *selection = [self value]
    [self setStringValue:text];
    //self.selectedTextRange = selection; // maintain cursor position/selection - this is robust to out of bounds
  } else if (eventLag > RCTTextUpdateLagWarningThreshold) {
    RCTLogWarn(@"Native TextInput(%@) is %zd events ahead of JS - try to make your JS faster.", [self stringValue], eventLag);
  }
}


- (void)setPlaceholderTextColor:(NSColor *)placeholderTextColor
{
  if (placeholderTextColor != nil && ![_placeholderTextColor isEqual:placeholderTextColor]) {
    _placeholderTextColor = placeholderTextColor;
    [self setNeedsDisplay:YES];
  }
}

- (void)setPlaceholder:(NSString *)placeholder
{
  if (placeholder != nil && ![_placeholderString isEqual:placeholder]) {
    _placeholderString = placeholder;
    [self setPlaceholderString:placeholder];
    [self setNeedsDisplay:YES];
  }
}

//- (void)drawRect:(NSRect)rect
//{
//  [super drawRect:rect];
//  if ([[self stringValue] isEqualToString:@""] && self != [[self window] firstResponder] && _placeholderTextColor != nil) {
//    NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:_placeholderTextColor, NSForegroundColorAttributeName, nil];
//    [[[NSAttributedString alloc] initWithString:_placeholderString attributes:txtDict] drawAtPoint:NSMakePoint(0,0)];
//  }
//}

- (NSArray *)reactSubviews
{
  // TODO: do we support subviews of textfield in React?
  // In any case, we should have a better approach than manually
  // maintaining array in each view subclass like this
  return _reactSubviews;
}

- (void)removeReactSubview:(NSView *)subview
{
  // TODO: this is a bit broken - if the TextField inserts any of
  // its own views below or between React's, the indices won't match
  [_reactSubviews removeObject:subview];
  [subview removeFromSuperview];
}

- (void)insertReactSubview:(NSView *)view atIndex:(NSInteger)atIndex
{
  // TODO: this is a bit broken - if the TextField inserts any of
  // its own views below or between React's, the indices won't match
  [_reactSubviews insertObject:view atIndex:atIndex];
  [super addSubview:view];
}

//- (CGRect)caretRectForPosition:(NSTextPosition *)position
//{
//  if (_caretHidden) {
//    return CGRectZero;
//  }
//  return [super selectText:(NSRange){position:position}];
//}
//
//- (CGRect)textRectForBounds:(CGRect)bounds
//{
//  CGRect rect = [super textRectForBounds:bounds];
//  return UIEdgeInsetsInsetRect(rect, _contentInset);
//}
//
//- (CGRect)editingRectForBounds:(CGRect)bounds
//{
//  return [self textRectForBounds:bounds];
//}
//
//- (void)setAutoCorrect:(BOOL)autoCorrect
//{
//  self.autocorrectionType = (autoCorrect ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo);
//}
//
//- (BOOL)autoCorrect
//{
//  return self.autocorrectionType == UITextAutocorrectionTypeYes;
//}

- (void)textDidChange:(NSNotification *)aNotification
{
  _nativeEventCount++;
  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeChange
                                 reactTag:self.reactTag
                                     text:[self stringValue]
                               eventCount:_nativeEventCount];
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
  _nativeEventCount++;
  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeEnd
                                 reactTag:self.reactTag
                                     text:[self stringValue]
                               eventCount:_nativeEventCount];
}
//

//- (void)textFieldSubmitEditing
//{
//  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeSubmit
//                                 reactTag:self.reactTag
//                                     text:self.text
//                               eventCount:_nativeEventCount];
//}
//
- (void)textDidBeginEditing:(NSNotification *)aNotification
{
  if (_selectTextOnFocus) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self selectAll:nil];
    });
  }
  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeFocus
                                 reactTag:self.reactTag
                                     text:[self stringValue]
                               eventCount:_nativeEventCount];
}

- (BOOL)becomeFirstResponder
{
  _jsRequestingFirstResponder = YES;
  BOOL result = [super becomeFirstResponder];
  _jsRequestingFirstResponder = NO;
  return result;
}

- (BOOL)resignFirstResponder
{
  BOOL result = [super resignFirstResponder];
  if (result)
  {
    [_eventDispatcher sendTextEventWithType:RCTTextEventTypeBlur
                                   reactTag:self.reactTag
                                       text:[self stringValue]
                                 eventCount:_nativeEventCount];
  }
  return result;
}

- (BOOL)canBecomeFirstResponder
{
  return _jsRequestingFirstResponder;
}

@end
