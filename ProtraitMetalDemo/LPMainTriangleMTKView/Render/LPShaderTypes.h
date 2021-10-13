//
//  LPShaderTypes.h
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#ifndef LPShaderTypes_h
#define LPShaderTypes_h

#include <simd/simd.h>

typedef enum LPVertexInputIndex{
    LPVertexInputIndexVertices = 0,
    LPVertexInputIndexUniforms = 1,
    LPVertexInputIndexIndices = 2,
}LPVertexInputIndex;


typedef struct {
    //positon pixel space
    vector_float2 position;
    
    //2D color
    vector_float4 color;
    
}LPVertex;

typedef struct {
    vector_float2 position;
    vector_float2 texcoordinate;
}LPTextureVertex;

typedef struct{
    float scale;
    vector_uint2 viewportSize;
    vector_float4 diagonalColor;
}LPUniforms;



#endif /* LPShaderTypes_h */
