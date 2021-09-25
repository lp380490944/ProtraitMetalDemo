//
//  LPMainTriangleMTKView.m
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#import "LPMainTriangleMTKView.h"

@implementation LPMainTriangleMTKView

#pragma mark-- initialization and setup

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initCommon];
    }
    return self;
}

-(void)initCommon{
    _metalLayer = (CAMetalLayer *)self.layer;
    self.layer.delegate = self;
}

#if ANIMATION_RENDERING
-(void)stopRenderLoop{
    //subclass should implement this method.
}
- (void)dealloc
{
    [self stopRenderLoop];
}


#else

-(void)displayLayer:(CALayer *)layer{
    
    [self renderOnEvent];
}
- (void)drawRect:(CGRect)rect
{
    [self renderOnEvent];
}
-(void)renderOnEvent{
#if RENDER_ON_MAIN_THREAD
    [self render];
#else
  //dispatch rendering on a concurrent queue
    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0);
    dispatch_async(globalQueue,^(){
        [self render];
    });
#endif
}
#endif

#pragma mark-- resizing
#if  AUTOMATICALLY_RESIZE

-(void)resizeDrawable:(CGFloat)scaleFactor{
    CGSize newSize = self.bounds.size;
    newSize.width *= scaleFactor;
    newSize.height *= scaleFactor;
    
    if (newSize.width <= 0 || newSize.height <= 0) {
        return;
    }
#if RENDER_ON_MAIN_THREAD
    if (newSize.width == _metalLayer.drawableSize.width && newSize.height == _metalLayer.drawableSize.height) {
        return;
    }
    _metalLayer.drawableSize = newSize;
    
    [_delegate drawableResize:newSize];
#else
    // All Appkit and UIKit calls which notify of a resize are called on the main thread. Use a
    // synchronized block to ensure that resize notifications on the delefate are atomic.
    @synchronized (_metalLayer) {
        if (newSize.width == _metalLayer.drawableSize.width && newSize.height == _metalLayer.drawableSize.height) {
            return;
        }
        _metalLayer.drawableSize = newSize;
        [_delegate drawableResize:newSize];
    }
#endif
}
#endif

#pragma mark-- drawing

-(void)render{
#if RENDER_ON_MAIN_THREAD
    [_delegate renderToMetalLayer:_metalLayer];
#else
    @synchronized (_metalLayer) {
        [_delegate renderToMetalLayer:_metalLayer];
    }
#endif
}


@end
