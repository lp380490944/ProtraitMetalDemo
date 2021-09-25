//
//  LPVertexModel.h
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#import <Foundation/Foundation.h>

@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface LPVertexModel : NSObject
//positon pixel space
@property(nonatomic,assign)vector_float2 position;
//2D texture coordinate
@property(nonatomic,assign)vector_float4 color;
@end

NS_ASSUME_NONNULL_END
