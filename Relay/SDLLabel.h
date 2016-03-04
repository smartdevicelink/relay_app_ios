//
//  SDLLabel.h
//  Relay
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SDLLabelState) {
    SDLLabelStateNone,
    SDLLabelStateError,
    SDLLabelStateSuccess,
    SDLLabelStateWaiting
};

@interface SDLLabel : UILabel

@property (nonatomic, readonly) SDLLabelState currentState;

- (void)updateToErrorStateWithString:(NSString *)string;
- (void)updateToNoStateWithString:(NSString *)string;
- (void)updateToSuccessStateWithString:(NSString *)string;
- (void)updateToWaitingStateWithString:(NSString *)string;
- (void)updateToState:(SDLLabelState)newState withString:(NSString *)string;

@end
