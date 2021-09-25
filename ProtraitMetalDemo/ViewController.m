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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LPMainTriangleMTKView   * _view = (LPMainTriangleMTKView *)self.view;
    id <MTLDevice> device =  MTLCreateSystemDefaultDevice();
    _view.metalLayer.device = device;
    _view.delegate = self;
    _view.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    _render = [[LPRender alloc] initWithMetalDevice:device drawablePixelFormat:_view.metalLayer.pixelFormat];
    
}
- (void)drawableResize:(CGSize)size{
    [_render drawableResize:size];
}

- (void)renderToMetalLayer:(nonnull CAMetalLayer *)metalLayer{
    [_render renderToMetalLayer:metalLayer];
}


@end
