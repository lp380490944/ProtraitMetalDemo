//
//  LPRender.m
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#import "LPRender.h"
#import "LPShaderTypes.h"
#import "LPMTKConfig.h"
#import "LPVertexModel.h"
#import "MainDefineHeader.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>


#if CREATE_DEPTH_BUFFER
static const MTLPixelFormat LPDepthPixelFormat = MTLPixelFormatDepth32Float;

#endif
static const MTLPixelFormat LPPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
//triangle edge leghth
#define TriangleSize 7
#define DrawableHeight  KScreenH * KScreenScale
#define blockSize TriangleSize/2.00

#define  RenderTargetSize 7

static const NSUInteger NumVertex = 28;
static const NSUInteger NumRow = 7;
static const NSUInteger NumColum = 7;

static const NSUInteger MaxFrameInFlight = 1;

typedef UInt16 LPIndex;
const  MTLIndexType LPIndexType = MTLIndexTypeUInt16;


static const LPIndex indices[] = {
  1,  0,  7,
  2,  1,  8,
  3,  2,  9,
 4,  3,  10,
 5,  4,  11,
 6,  5,  12, //12,//
  1,  7,  8,
  2,  8,  9,
  3,  9,  10,
  4, 10,  11,
  5, 11,  12,//17,//
  8, 7,  13,
  9, 8,  14,
  10, 9,  15,
  11, 10,  16,
  12, 11,  17, //17,//
  8, 13,   14,
  9, 14,   15,
  10, 15,  16,
  11, 16,  17, //21,//
  14, 13,  18,
  15, 14,  19,
  16, 15,  20,
  17,  16,  21, //21,//
  14, 18,  19,
  15, 19,  20,
  16, 20,  21, //24,//
  19, 18,  22,
  20, 19,  23,
  21, 20,  24, //24,//
  19, 22,  23,
  20, 23,  24, //26,//
  23, 22,  25,
  24, 23,  26, //26,//
  23, 25,  26,//
  26, 25,  27,
};

static const LPTextureVertex textureVertices[] = {
//    {{1, -1},{1, 1}},
//    {{-1, -1},{0, 1}},
//    {{-1, 1}, {0,0} },
//
    {{1, 1},{1,0}},
    {{-1, 1}, {0,0} },
    {{-1, -1},{0, 1}},
};


@implementation LPRender{
    
    // render global ivars
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLBuffer> _verticesBuffers[MaxFrameInFlight];
    id <MTLBuffer> _indexBuffer;
    id <MTLTexture> _depthTargetTexture;

    //render pass descriptor which creates a render  command encoder to draw the drawable
    //textures
    MTLRenderPassDescriptor * _drawbleRenderDescriptor;
    
    vector_uint2  _viewportSize;
    
    NSUInteger _frameNum;
    //store the triangle vertex with the vertexModel
    NSArray <LPVertexModel *>* _vertexModelArray;
    
    //The index of the metal buffer in _verticesBuffers to write to for the current frame.
    NSUInteger _currentBufferIndex;
    
    //A semaphore used to ensure that buffers read by the GPU are bit simultaneously.
    dispatch_semaphore_t _inFlightSemaphore;
    
    id <MTLRenderPipelineState> _gaussBlurPipelineState;
    MTLRenderPassDescriptor *_gaussBlurRenderTargetDesc;
    id <MTLTexture> _GaussBlurTexture;
    id <MTLTexture> _tempTexture;
}

-(instancetype)initWithMetalDevice:(nonnull id <MTLDevice>)device drawablePixelFormat:(MTLPixelFormat)drawablePixelFormat{
    self = [super init];
    if (self) {
        _frameNum = 0;
        _inFlightSemaphore = dispatch_semaphore_create(MaxFrameInFlight);
        _device = device;
        _commandQueue = [device newCommandQueue];
        
        // build texture.
        MTLTextureDescriptor * textureDescriptor = [MTLTextureDescriptor new];
        textureDescriptor.pixelFormat = LPPixelFormat;
        textureDescriptor.textureType = MTLTextureType2D;
        textureDescriptor.width = RenderTargetSize;
        textureDescriptor.height = RenderTargetSize;
        textureDescriptor.sampleCount = 1;
        textureDescriptor.usage = MTLTextureUsageShaderRead|MTLTextureUsageRenderTarget;
        _GaussBlurTexture = [_device newTextureWithDescriptor:textureDescriptor];
        textureDescriptor.usage = MTLTextureUsageShaderRead|MTLTextureUsageShaderWrite;
        _tempTexture = [_device newTextureWithDescriptor:textureDescriptor];
        _drawbleRenderDescriptor = [[MTLRenderPassDescriptor alloc] init];
        _drawbleRenderDescriptor.renderTargetWidth = RenderTargetSize;
        _drawbleRenderDescriptor.renderTargetHeight = RenderTargetSize;
        _drawbleRenderDescriptor.colorAttachments[0].texture = _GaussBlurTexture;
        _drawbleRenderDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        _drawbleRenderDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        _drawbleRenderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
#if CREATE_DEPTH_BUFFER
        _drawbleRenderDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
        _drawbleRenderDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;
        _drawbleRenderDescriptor.depthAttachment.clearDepth = 1.0;
#endif
        {
            id <MTLLibrary> shaderLib = [_device newDefaultLibrary];
            if (!shaderLib) {
                NSLog(@"Error: couldn't create a default shader library.");
                return nil;
            }
            id <MTLFunction> vertexProgram  = [shaderLib newFunctionWithName:@"vertexShader"];
            if (!vertexProgram) {
                NSLog(@"Error:couldn't load vertex function from the default library");
                return nil;
            }
            //fragment function
            id <MTLFunction> fragmentProgram = [shaderLib newFunctionWithName:@"fragmentShader"];
            if (!fragmentProgram) {
                NSLog(@"Error:couldn't load fragment function fomr the default library");
                return nil;
            }
            
            [self generateVertex];
            
            NSUInteger vertexNum = _vertexModelArray.count;
            for (NSUInteger bufferIndex = 0; bufferIndex < MaxFrameInFlight; bufferIndex++) {
                
                _verticesBuffers[bufferIndex] = [_device newBufferWithLength:sizeof(LPVertex)*vertexNum options:MTLResourceStorageModeShared];
                _verticesBuffers[bufferIndex].label = [NSString stringWithFormat:@"quad %lu",bufferIndex];
                LPVertex * vertices = _verticesBuffers[bufferIndex].contents;
                for (NSUInteger vertex = 0; vertex < vertexNum; vertex++) {
                    LPVertexModel * vertexModel = _vertexModelArray[vertex];
                    vertices[vertex].position = vertexModel.position;
                    vertices[vertex].color = vertexModel.color;
//                    vertices[vertex].texcoordinate = vertexModel.texcoordinate;
                    if (vertex == 0|| vertex == 6 || vertex == 27) {
    //                    vertices[vertex].color = simd_make_float4(1,1,1,1);
                    }
                }
            }
          
            
//            _indexBuffer = [_device newBufferWithBytes:indices length:sizeof(indices) options:MTLResourceStorageModeShared];
            _indexBuffer.label = @"MyIndexBuffer";
            
            //Create a pipeline state descriptor to create a compiled pipleline state object.
            MTLRenderPipelineDescriptor * pipelineDescriptor = [MTLRenderPipelineDescriptor new];
            pipelineDescriptor.label = @"myPipeline";
            pipelineDescriptor.vertexFunction = vertexProgram;
            pipelineDescriptor.fragmentFunction = fragmentProgram;
            pipelineDescriptor.colorAttachments[0].pixelFormat = LPPixelFormat;
            
            MTLVertexDescriptor * vertexDescriptor = [MTLVertexDescriptor new];
            vertexDescriptor.attributes[0].format = MTLVertexFormatFloat2;
            vertexDescriptor.attributes[0].bufferIndex = LPVertexInputIndexVertices;
            vertexDescriptor.attributes[0].offset = 0;

            //color
            vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
            vertexDescriptor.attributes[1].bufferIndex = LPVertexInputIndexVertices;
            vertexDescriptor.attributes[1].offset = sizeof(vector_float2);
            vertexDescriptor.layouts[0].stride = sizeof(LPVertex);

            pipelineDescriptor.vertexDescriptor = vertexDescriptor;
        
#if CREATE_DEPTH_BUFFER
            pipelineDescriptor.depthAttachmentPixelFormat = LPDepthPixelFormat;
#endif
            NSError * error;
            _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
            if (!_pipelineState) {
                NSLog(@"Error : Failed aquiring pipleline state:%@",error);
                return nil;
            }
            //guass blur
            {
                MTLRenderPipelineDescriptor * guassBlurPipeLineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
                guassBlurPipeLineDescriptor.label = @"MyGuassBlurPipeLineState";
                guassBlurPipeLineDescriptor.vertexFunction = [shaderLib newFunctionWithName:@"gaussianBlurVertexShader"];
                guassBlurPipeLineDescriptor.fragmentFunction = [shaderLib newFunctionWithName:@"gaussianBlurFragment"];
                guassBlurPipeLineDescriptor.sampleCount = 1;
                guassBlurPipeLineDescriptor.colorAttachments[0].pixelFormat = LPPixelFormat;
                
                //draw guass blur pipeline
                NSError * error;
                _gaussBlurPipelineState = [_device newRenderPipelineStateWithDescriptor:guassBlurPipeLineDescriptor error:&error];
                NSAssert(_gaussBlurPipelineState != nil, @"failed to create guassblur piplinestate");
                
            }
        }
    }
    return self;
    
}

-(void)updateState{
    LPVertex * vertices = _verticesBuffers[_currentBufferIndex].contents;
    NSUInteger vertexNum = _vertexModelArray.count;
    for (NSUInteger vertex = 0; vertex < vertexNum; vertex++) {
        LPVertexModel * vertexModel = _vertexModelArray[vertex];
        vertices[vertex].position = vertexModel.position;
        vertices[vertex].color = vertexModel.color;
    }
}

-(void)renderToMetalLayer:(nonnull CAMetalLayer*)metalLayer{
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    
    _mtkLayer = metalLayer;
    _currentBufferIndex = (_currentBufferIndex + 1) % MaxFrameInFlight;
    _frameNum++;
    
    if (_frameNum % 360 == 0) {
        [self generateVertex];
        [self updateState];
    }
    
    //create a new commmand buffer for each render pass to current drawable.
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id <CAMetalDrawable> currentDrawable = [metalLayer nextDrawable];
    
    //if the current drawable is nil ,skip rendering this frame.
    if (!currentDrawable) {
        return;
    }
    {
        
     // render to textureDrawable renderEncoder.
    id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:_drawbleRenderDescriptor];
    
    [renderEncoder setRenderPipelineState:_pipelineState];
    [renderEncoder setVertexBuffer:_verticesBuffers[_currentBufferIndex] offset:0 atIndex:LPVertexInputIndexVertices];
//    [renderEncoder setVertexBuffer:_indexBuffer offset:0 atIndex:LPVertexInputIndexIndices];
    
    {
        LPUniforms uniforms;
#if ANIMATION_RENDERING
        uniforms.scale = 0.5 + (1.0 + 0.5 * sin(_frameNum * 0.1));
        uniforms.scale = 1.0f;
#else
        uniforms.scale = 1.0f;
#endif
        uniforms.viewportSize = _viewportSize;
        [renderEncoder setVertexBytes:&uniforms length:sizeof(uniforms) atIndex:LPVertexInputIndexUniforms];
    }
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypePoint vertexStart:0 vertexCount:_verticesBuffers[_currentBufferIndex].length/sizeof(LPVertex)];
//    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:_indexBuffer.length/sizeof(LPIndex) indexType:LPIndexType indexBuffer:_indexBuffer indexBufferOffset:0];
    [renderEncoder endEncoding];
        
    }

//    MPSImageLanczosScale * zos = [[MPSImageLanczosScale alloc]initWithDevice:_device];
//    [zos encodeToCommandBuffer:commandBuffer sourceTexture:_GaussBlurTexture destinationTexture:_tempTexture];
//    MPSImageGaussianBlur * blur = [[MPSImageGaussianBlur alloc] initWithDevice:_device sigma:1];
//
//    [blur encodeToCommandBuffer:commandBuffer sourceTexture:_GaussBlurTexture destinationTexture:_tempTexture];
    
    // guassblurTexture renderEncoder.
    {
        MTLRenderPassDescriptor * gaussBlurRenderPassDescriptor = [MTLRenderPassDescriptor new];
        gaussBlurRenderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture;
        gaussBlurRenderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        gaussBlurRenderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        gaussBlurRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1.0, 1.0, 1.0);

        id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor: gaussBlurRenderPassDescriptor];
        encoder.label = @"gauss blur Command Encoder";

        [encoder setVertexBuffer:_verticesBuffers[_currentBufferIndex] offset:0 atIndex:LPVertexInputIndexVertices];
        [encoder setVertexBytes:&textureVertices length:sizeof(textureVertices) atIndex:0];
//        [encoder setVertexBuffer:_indexBuffer offset:0 atIndex:LPVertexInputIndexIndices];

        {
            LPUniforms uniforms;
    #if ANIMATION_RENDERING
            uniforms.scale = 0.5 + (1.0 + 0.5 * sin(_frameNum * 0.1));
            uniforms.scale = 1.0f;
    #else
            uniforms.scale = 1.0f;
    #endif
            uniforms.viewportSize = _viewportSize;
            [encoder setVertexBytes:&uniforms length:sizeof(uniforms) atIndex:LPVertexInputIndexUniforms];
        }



        [encoder setRenderPipelineState: _gaussBlurPipelineState];

        [encoder setFragmentTexture: _GaussBlurTexture
                            atIndex: 0];
//        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:_indexBuffer.length/sizeof(LPIndex) indexType:LPIndexType indexBuffer:_indexBuffer indexBufferOffset:0];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [encoder endEncoding];
        [commandBuffer presentDrawable:currentDrawable];
    }
    __block dispatch_semaphore_t block_semaphore = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
        dispatch_semaphore_signal(block_semaphore);
    }];
//    id <MTLRasterizationRateMap> map ;
    [commandBuffer commit];
}

-(void)drawableResize:(CGSize)drawableSize{
    _viewportSize.x = drawableSize.width;
    _viewportSize.y  = drawableSize.height;

#if  CREATE_DEPTH_BUFFER
    //深度缓冲区
    MTLTextureDescriptor * depthTargetDescriptor = [MTLTextureDescriptor new];
    depthTargetDescriptor.width = drawableSize.width;
    depthTargetDescriptor.height = drawableSize.height;
    depthTargetDescriptor.pixelFormat = LPDepthPixelFormat;
    depthTargetDescriptor.storageMode = MTLStorageModePrivate;
    depthTargetDescriptor.usage = MTLTextureUsageRenderTarget|MTLTextureUsageShaderRead|MTLTextureUsageShaderWrite;
    
    _depthTargetTexture = [_device newTextureWithDescriptor:depthTargetDescriptor];
    
    _drawbleRenderDescriptor.depthAttachment.texture = _depthTargetTexture;
#endif
    
}

-(void)generateVertex{
    const vector_float4 Colors[] = {
        { 1.0, 0.0, 0.0, 1.0 },//Red
        { 0.0, 1.0, 0.0, 1.0 },//Green
        { 0.0, 0.0, 1.0, 1.0 },//Blue
        { 1.0, 0.0, 0.0, 1.0 },//Magenta
        { 0.0, 0.0, 1.0, 1.0 },//Cyan
        { 1.0, 0.0, 1.0, 1.0 },//Yellow
    };
    const NSUInteger NumColors = sizeof(Colors)/sizeof(vector_float4);
    NSMutableArray * verticesArray = [NSMutableArray arrayWithCapacity:NumVertex];
    
    //initialize each vertexModel
    const float sliceSize = (float)TriangleSize / (float)(NumColum);
    
    NSUInteger counter = 0;
    for (NSUInteger row = 0; row < NumRow; row++) {
        const NSUInteger perRowColumNum = NumColum - row;
        for (NSUInteger colum = 0; colum < perRowColumNum; colum++) {
            
            LPVertexModel * model = [LPVertexModel new];
            vector_float2 vertexPosition;
            vertexPosition.x = -((float)blockSize) + colum * sliceSize + 0.5;
            vertexPosition.y = -((float)blockSize) + (NumRow - row) * sliceSize - 0.5;
            model.position = vertexPosition;
            model.color = Colors[counter % NumColors];
            //texture coordinate
            vector_float2 texcoordinate;
            texcoordinate.x = (float) colum/ (float)NumColum;
            texcoordinate.y =  (float)(NumRow - row)/(float)NumRow;
            
            NSLog(@"textcoordinate =( %f, %f)",texcoordinate.x,texcoordinate.y);
            
            model.texcoordinate = texcoordinate;
            UIColor * randomColor = [UIColor colorWithHue:arc4random()%360/360.0 saturation:1.0 brightness:1.0 alpha:1];
            CGFloat r;
            CGFloat g;
            CGFloat b;
            CGFloat a;
            [randomColor getRed:&r green:&g blue:&b alpha:&a];
            model.color = simd_make_float4(r,g,b,1.0f);
//            hsvColor color = getMorphColor(simd_make_float2(colum,(NumRow - row)));
//            rgb rgbColor = hsv2rgb(color);
//            model.color = simd_make_float4(rgbColor.r,rgbColor.g,rgbColor.b,1.0);
            counter++;
            [verticesArray  addObject:model];
        }
    }
    _vertexModelArray = verticesArray;
}





@end
