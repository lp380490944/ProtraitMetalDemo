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
    LPVertexInputIndexTexture = 3,
}LPVertexInputIndex;


typedef struct {
    //positon pixel space
    vector_float2 position;
    
    //2D texture coordinate
    vector_float4 color;
}LPVertex;


typedef struct{
    float scale;
    vector_uint2 viewportSize;
}LPUniforms;



#endif /* LPShaderTypes_h */
