//
//  LPMainTriangleMTKSubView.m
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#import "LPMainTriangleMTKSubView.h"

@implementation LPMainTriangleMTKSubView{
    CADisplayLink * _displayLink;
#if !RENDER_ON_MAIN_THREAD
    //Secondry thread containing the render loop.
    NSThread * _renderThread;
    //flag to indicate rendring should cease on the main thread.
    BOOL _continueRunLoop;
#endif
    
}

#pragma mark-- initialization amd setup
+(Class)layerClass{
    return [CAMetalLayer class];
}

-(void)didMoveToWindow{
    [super didMoveToWindow];
#if ANIMATION_RENDERING
    if (self.window == nil) {
        // if moving off a window destroy the display link.
        [_displayLink invalidate];
        _displayLink = nil;
        return;
    }
    [self setupCADisplayLinkForScreen:self.window.screen];
#if RENDER_ON_MAIN_THREAD
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
#else

    @synchronized (self) {
      // Stop animation loop allowing the loop to complete if it's in progress.
        _continueRunLoop = NO;
    }
    //create and start a secondary nsthread which will have another runloop. the nsthread class will call the runthread  method at the start of the secondary thread's execution.
    _renderThread = [[NSThread alloc] initWithTarget:self selector:@selector(runThread) object:nil];
    _continueRunLoop = YES;
    [_renderThread start];
#endif
    
#endif
#if AUTOMATICALLY_RESIZE
    [self resizeDrawable:self.window.screen.nativeScale];
#else
    // Notify delegate of default drawable size when it can be calculated
    CGSize defaultDrawableSize = self.bounds.size;
    defaultDrawableSize.width *= self.layer.contentsScale;
    defaultDrawableSize.height *= self.layer.contentsScale;
    [self.delegate drawableResize:defaultDrawableSize];
#endif

}
#pragma mark - Render Loop Control
//////////////////////////////////

#if ANIMATION_RENDERING

- (void)setPaused:(BOOL)paused
{
    super.paused = paused;

    _displayLink.paused = paused;
}

- (void)setupCADisplayLinkForScreen:(UIScreen*)screen
{
    [self stopRenderLoop];

    _displayLink = [screen displayLinkWithTarget:self selector:@selector(render)];

    _displayLink.paused = self.paused;

    _displayLink.preferredFramesPerSecond = 60;
}

- (void)didEnterBackground:(NSNotification*)notification
{
    self.paused = YES;
}

- (void)willEnterForeground:(NSNotification*)notification
{
    self.paused = NO;
}

- (void)stopRenderLoop
{
    [_displayLink invalidate];
}

#if !RENDER_ON_MAIN_THREAD
- (void)runThread
{
    // Set the display link to the run loop of this thread so its call back occurs on this thread
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [_displayLink addToRunLoop:runLoop forMode:@"AAPLDisplayLinkMode"];

    // The '_continueRunLoop' ivar is set outside this thread, so it must be synchronized.  Create a
    // 'continueRunLoop' local var that can be set from the _continueRunLoop ivar in a @synchronized block
    BOOL continueRunLoop = YES;

    // Begin the run loop
    while (continueRunLoop)
    {
        // Create autorelease pool for the current iteration of loop.
        @autoreleasepool
        {
            // Run the loop once accepting input only from the display link.
            [runLoop runMode:@"AAPLDisplayLinkMode" beforeDate:[NSDate distantFuture]];
        }

        // Synchronize this with the _continueRunLoop ivar which is set on another thread
        @synchronized(self)
        {
            // Anything accessed outside the thread such as the '_continueRunLoop' ivar
            // is read inside the synchronized block to ensure it is fully/atomically written
            continueRunLoop = _continueRunLoop;
        }
    }
}
#endif // END !RENDER_ON_MAIN_THREAD

#endif // END ANIMATION_RENDERING

///////////////////////
#pragma mark - Resizing
///////////////////////

#if AUTOMATICALLY_RESIZE

// Override all methods which indicate the view's size has changed

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:contentScaleFactor];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self resizeDrawable:self.window.screen.nativeScale];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self resizeDrawable:self.window.screen.nativeScale];
}

#endif // END AUTOMATICALLY_RESIZE
@end
