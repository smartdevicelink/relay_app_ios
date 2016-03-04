//
//  SDLLabel.m
//  Relay
//

#import "SDLLabel.h"

#define FLAT_COLOR_BLACK [UIColor colorWithRed:(34 / 255.0) green:(49 / 255.0) blue:(63 / 255.0) alpha:1.0f]
#define FLAT_COLOR_GREEN [UIColor colorWithRed:(38 / 255.0) green:(166 / 255.0) blue:(91 / 255.0) alpha:1.0f]
#define FLAT_COLOR_ORANGE [UIColor colorWithRed:(249 / 255.0) green:(105 / 255.0) blue:(14 / 255.0) alpha:1.0f]
#define FLAT_COLOR_RED [UIColor colorWithRed:(217 / 255.0) green:(30 / 255.0) blue:(24 / 255.0) alpha:1.0f]


@implementation SDLLabel {
    BOOL _hasUpdatedOnce;
}

- (void)setText:(NSString *)text {
    if (_currentState == SDLLabelStateNone && !_hasUpdatedOnce) {
        self.textColor = FLAT_COLOR_BLACK;
    }
    if (!_hasUpdatedOnce) {
        _hasUpdatedOnce = YES;
    }
    [super setText:text];
}

- (void)updateToErrorStateWithString:(NSString *)string {
    [self updateToState:SDLLabelStateError
             withString:string];
}

- (void)updateToSuccessStateWithString:(NSString *)string {
    [self updateToState:SDLLabelStateSuccess
             withString:string];
}

- (void)updateToNoStateWithString:(NSString *)string {
    [self updateToState:SDLLabelStateNone
             withString:string];
}

- (void)updateToWaitingStateWithString:(NSString *)string {
    [self updateToState:SDLLabelStateWaiting
             withString:string];
}


- (void)updateToState:(SDLLabelState)newState withString:(NSString *)string {
    self.text = string;
    if (_currentState == newState) {
        return;
    }

    _currentState = newState;
    UIColor *newColor = nil;
    switch (newState) {
        case SDLLabelStateNone:
            newColor = FLAT_COLOR_BLACK;
            break;
        case SDLLabelStateError:
            newColor = FLAT_COLOR_RED;
            break;
        case SDLLabelStateSuccess:
            newColor = FLAT_COLOR_GREEN;
            break;
        case SDLLabelStateWaiting:
            newColor = FLAT_COLOR_ORANGE;
            break;
        default:
            break;
    }
    self.textColor = newColor;
}


@end
