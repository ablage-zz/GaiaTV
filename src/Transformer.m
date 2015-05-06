//
//  Transformer.m
//  GaiaTV
//
//  Created by marcel on 11/9/08.
//  Copyright 2008 Dealer Fusion, Inc.. All rights reserved.
//

#import "Transformer.h"


@implementation NonNilAsBoolTransformer

+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (NSNumber *)transformedValue:(id)value {
    return [NSNumber numberWithBool: !!value];
}

@end
