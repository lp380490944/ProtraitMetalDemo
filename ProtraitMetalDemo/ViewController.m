//
//  ViewController.m
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/15.
//

#import "ViewController.h"
#import "LPMainTriangleMTKView.h"
#import "LPRender.h"
#import "LPMainTriangleMTKSubView.h"
@import MetalKit;

@interface ViewController ()<LPMainTriangleMTKViewDelegate>{
    LPRender *_render;
}
@property (weak, nonatomic) IBOutlet LPMainTriangleMTKSubView *renderView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    id <MTLDevice> device =  MTLCreateSystemDefaultDevice();
    _renderView.metalLayer.device = device;
    _renderView.delegate = self;
    _renderView.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    _render = [[LPRender alloc] initWithMetalDevice:device drawablePixelFormat:_renderView.metalLayer.pixelFormat];
    
}
- (void)drawableResize:(CGSize)size{
    [_render drawableResize:size];
}

- (void)renderToMetalLayer:(nonnull CAMetalLayer *)metalLayer{
    [_render renderToMetalLayer:metalLayer];
}


@end
