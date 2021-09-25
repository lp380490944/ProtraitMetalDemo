//
//  LPRender.h
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface LPRender : NSObject
@property(nonatomic,strong)CAMetalLayer *mtkLayer;
-(instancetype)initWithMetalDevice:(nonnull id <MTLDevice>)device drawablePixelFormat:(MTLPixelFormat)drawablePixelFormat;
-(void)drawableResize:(CGSize)drawableSize;
-(void)renderToMetalLayer:(nonnull CAMetalLayer*)metalLayer;
@end

NS_ASSUME_NONNULL_END
