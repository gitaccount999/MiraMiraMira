//
//  wtmk
//
//  Created by tambi on 9/29/21.
//

#import "WTMKBridge.h"
#include "HiddenWatermark.hpp"

@interface WTMKBridge()
{
    HiddenWatermark* sharedTool;
}
@end

@implementation WTMKBridge

- (id) init {
    if ((self = [super init])) {
        sharedTool = new HiddenWatermark();
    }
    
    return self;
}

- (void) test:(NSString*) originImage watermarkImage:(NSString*) watermarkImage outputImage:(NSString*) outputImage {
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* output = [documentDirectory stringByAppendingPathComponent:@"purchaserecord2.jpg"];

    sharedTool->addWatermark(originImage.UTF8String, watermarkImage.UTF8String, output.UTF8String);

    NSString* output1 = [documentDirectory stringByAppendingPathComponent:@"purchaserecord3.jpg"];

    sharedTool->extWatermark(output.UTF8String, output1.UTF8String);
}

- (void) dealloc {
    delete sharedTool;
}
@end
