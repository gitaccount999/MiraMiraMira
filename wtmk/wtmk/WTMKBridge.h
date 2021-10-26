//
//  NSObject+WTMKBridge.h
//  wtmk
//
//  Created by tambi on 9/29/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WTMKBridge: NSObject

- (void) test:(NSString*) originImage watermarkImage:(NSString*) watermarkImage outputImage:(NSString*) outputImage;

@end

NS_ASSUME_NONNULL_END
