//
//  LPMainTriangleMTKView.h
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#import <UIKit/UIKit.h>
#import "LPMTKConfig.h"

@import MetalKit;

@protocol LPMainTriangleMTKViewDelegate <NSObject>

- (void)drawableResize:(CGSize)size;

- (void)renderToMetalLayer:(nonnull CAMetalLayer *)metalLayer;

@end


@interface LPMainTriangleMTKView : UIView<CALayerDelegate>
@property(nonatomic,nonnull,readonly)CAMetalLayer * metalLayer;
@property(nonatomic,nullable,weak)id<LPMainTriangleMTKViewDelegate> delegate;
@property (nonatomic, getter=isPaused) BOOL paused;

-(void)initCommon;

#if AUTOMATICALLY_RESIZE
-(void)resizeDrawable:(CGFloat)scaleFactor;
#endif

#if  ANIMATION_RENDERING
-(void)stopRenderLoop;
#endif

-(void)render;



@end


