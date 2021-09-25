//
//  LPShader.metal
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#include <metal_stdlib>
using namespace metal;
#include "LPShaderTypes.h"


struct RasterizerData{
    float4 clipSpacePosition [[position]];
    float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinates [[user(texturecoord)]];
};



vertex RasterizerData vertexShader( uint vertexID [[vertex_id]],constant LPVertex *vertexArray [[buffer(LPVertexInputIndexVertices)]], constant LPUniforms &uniforms[[buffer(LPVertexInputIndexUniforms)]] ){
    RasterizerData out;
    float2 pixelSpacePosition =  vertexArray[vertexID].position.xy;
    
    //scale the vertex by scale factor of the current frame.
    
    pixelSpacePosition *= uniforms.scale;
    
    float2 viewportSize = float2(uniforms.viewportSize);
    out.clipSpacePosition.xy = pixelSpacePosition/(viewportSize/2.0f);
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1.0;
    out.color = vertexArray[vertexID].color;
    return out;
}

vertex VertexOut gaussianBlurVertexShader( uint vertexID [[vertex_id]],constant LPVertex *vertexArray [[buffer(LPVertexInputIndexVertices)]], constant LPUniforms &uniforms[[buffer(LPVertexInputIndexUniforms)]] , constant float2 *texCoor [[ buffer(LPVertexInputIndexTexture) ]]){
    VertexOut out;
    float2 pixelSpacePosition =  vertexArray[vertexID].position.xy;
    
    //scale the vertex by scale factor of the current frame.
    
    pixelSpacePosition *= uniforms.scale;
    
    float2 viewportSize = float2(uniforms.viewportSize);
    out.position.xy = pixelSpacePosition/(viewportSize/2.0f);
    out.position.z = 0.0;
    out.position.w = 1.0;
   ;
    out.textureCoordinates = texCoor[vertexID];
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]]){
    return in.color;
}


fragment float4 gaussianBlurFragment(VertexOut fragmentIn [[ stage_in ]],
                                     texture2d<float, access::sample> texture [[texture(0)]]) {
    float2 offset = fragmentIn.textureCoordinates;
    constexpr sampler qsampler(coord::normalized,
                               address::clamp_to_edge);
//    float4 color = texture.sample(qsampler, coordinates);
    float width = texture.get_width();
    float height = texture.get_width();
    float xPixel = (1 / width) * 3;
    float yPixel = (1 / height) * 2;
    
    
    float3 sum = float3(0.0, 0.0, 0.0);
    
    
    // code from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
    
    // 9 tap filter
    sum += texture.sample(qsampler, float2(offset.x - 4.0*xPixel, offset.y - 4.0*yPixel)).rgb * 0.0162162162;
    sum += texture.sample(qsampler, float2(offset.x - 3.0*xPixel, offset.y - 3.0*yPixel)).rgb * 0.0540540541;
    sum += texture.sample(qsampler, float2(offset.x - 2.0*xPixel, offset.y - 2.0*yPixel)).rgb * 0.1216216216;
    sum += texture.sample(qsampler, float2(offset.x - 1.0*xPixel, offset.y - 1.0*yPixel)).rgb * 0.1945945946;
    
    sum += texture.sample(qsampler, offset).rgb * 0.2270270270;
    
    sum += texture.sample(qsampler, float2(offset.x + 1.0*xPixel, offset.y + 1.0*yPixel)).rgb * 0.1945945946;
    sum += texture.sample(qsampler, float2(offset.x + 2.0*xPixel, offset.y + 2.0*yPixel)).rgb * 0.1216216216;
    sum += texture.sample(qsampler, float2(offset.x + 3.0*xPixel, offset.y + 3.0*yPixel)).rgb * 0.0540540541;
    sum += texture.sample(qsampler, float2(offset.x + 4.0*xPixel, offset.y + 4.0*yPixel)).rgb * 0.0162162162;
    
    float4 adjusted;
    adjusted.rgb = sum;
//    adjusted.g = color.g;
    adjusted.a = 1;
    return adjusted;
}
