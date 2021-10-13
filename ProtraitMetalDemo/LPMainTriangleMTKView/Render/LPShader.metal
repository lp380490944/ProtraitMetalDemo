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
    float pointSize[[point_size]];
};


constant half3 ambientLightIntensity(0.9, 0.9, 0.9);
constant half3 diffuseLightIntensity(0.9, 0.9, 0.9);
constant half3 lightDirection(0.577, 0.577, 0.577);

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinates;
};



vertex RasterizerData vertexShader( uint vertexID [[vertex_id]],constant LPVertex *vertexArray [[buffer(LPVertexInputIndexVertices)]], constant LPUniforms &uniforms[[buffer(LPVertexInputIndexUniforms)]] ){
    RasterizerData out;
    float2 pixelSpacePosition =  vertexArray[vertexID].position.xy;
    
    //scale the vertex by scale factor of the current frame.
    
    pixelSpacePosition *= uniforms.scale;
    
//    float2 viewportSize = float2(uniforms.viewportSize);
    float2 viewportSize = float2(7,7);
    out.clipSpacePosition.xy = pixelSpacePosition/(viewportSize/2.0f);
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1;
    out.pointSize = 1;
    
    out.color = vertexArray[vertexID].color;
//    out.color.rgb*=0.9;
//    out.color.a = 1 ;
    return out;
}

vertex VertexOut gaussianBlurVertexShader( uint vertexID [[vertex_id]],constant LPTextureVertex *vertexArray [[buffer(LPVertexInputIndexVertices)]], constant LPUniforms &uniforms[[buffer(LPVertexInputIndexUniforms)]]){
    VertexOut out;
    float2 pixelSpacePosition =  vertexArray[vertexID].position.xy;
    
    //scale the vertex by scale factor of the current frame.
    pixelSpacePosition *= uniforms.scale;
    
//    float2 viewportSize = float2(uniforms.viewportSize);
    out.position.xy = vertexArray[vertexID].position;
    out.position.z = 0.0;
    out.position.w = 1.0;
    out.textureCoordinates = vertexArray[vertexID].texcoordinate;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]], uint ii_id [[primitive_id]],float2 pointCoord [[point_coord]]){

    
//    if (distance(pointCoord, float2(0.5,0.5)) >= 0.6) {
//        discard_fragment();
//    }
    
//    in.color *= 0.9;
    return in.color;

//    if(in.clipSpacePosition.x < 0.5){
//        return float4(0,0,0,1);
//    }
//    normalize(in.clipSpacePosition);

}


fragment float4 gaussianBlurFragment(VertexOut fragmentIn [[ stage_in ]],
                                     texture2d<float, access::sample> texture [[texture(0)]]) {
    float2 offset = fragmentIn.textureCoordinates;
    constexpr struct sampler qsampler(coord::normalized,
                               address::clamp_to_edge);
    constexpr struct sampler sampler(coord::normalized,s_address::clamp_to_edge,filter::bicubic,t_address::clamp_to_edge,r_address::clamp_to_edge);
//    struct sampler sampler;
    float4 color = texture.sample(sampler, fragmentIn.textureCoordinates);
    return color;
    float width = texture.get_width();
    float height = texture.get_width();
    float xPixel = (1 / width) * 3;
    float yPixel = (1 / height) * 2;
    
    
    float3 sum = float3(0.0, 0.0, 0.0);
    
    float p1 = 0.1945945946;
    float p2 = 0.1216216216;
    float p3 = 0.0540540541;
    float p4 = 0.0162162162;
//    float p5 = 0.1102162162;
//    float p6 = 0.1102162162;
//    float p7 = 0.1102162162;
//    float p8 = 0.1102162162;
//    float p9 = 0.1102162162;
    
    // code from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
    
    // 9 tap filter
//    sum += texture.sample(qsampler, float2(offset.x - 8.0*xPixel, offset.y - 8.0*yPixel)).rgb * p8;
//    sum += texture.sample(qsampler, float2(offset.x - 7.0*xPixel, offset.y - 7.0*yPixel)).rgb * p7;
//    sum += texture.sample(qsampler, float2(offset.x - 6.0*xPixel, offset.y - 6.0*yPixel)).rgb * p6;
//    sum += texture.sample(qsampler, float2(offset.x - 5.0*xPixel, offset.y - 5.0*yPixel)).rgb * p5;
    sum += texture.sample(qsampler, float2(offset.x - 4.0*xPixel, offset.y - 4.0*yPixel)).rgb * p4;
    sum += texture.sample(qsampler, float2(offset.x - 3.0*xPixel, offset.y - 3.0*yPixel)).rgb * p3;
    sum += texture.sample(qsampler, float2(offset.x - 2.0*xPixel, offset.y - 2.0*yPixel)).rgb * p2;
    sum += texture.sample(qsampler, float2(offset.x - 1.0*xPixel, offset.y - 1.0*yPixel)).rgb * p1;
    
    sum += texture.sample(qsampler, offset).rgb * 0.2270270270;
    
    sum += texture.sample(qsampler, float2(offset.x + 1.0*xPixel, offset.y + 1.0*yPixel)).rgb * p1;
    sum += texture.sample(qsampler, float2(offset.x + 2.0*xPixel, offset.y + 2.0*yPixel)).rgb * p2;
    sum += texture.sample(qsampler, float2(offset.x + 3.0*xPixel, offset.y + 3.0*yPixel)).rgb * p3;
    sum += texture.sample(qsampler, float2(offset.x + 4.0*xPixel, offset.y + 4.0*yPixel)).rgb * p4;
//    sum += texture.sample(qsampler, float2(offset.x + 5.0*xPixel, offset.y + 5.0*yPixel)).rgb * p5;
//    sum += texture.sample(qsampler, float2(offset.x + 6.0*xPixel, offset.y + 6.0*yPixel)).rgb * p6;
//    sum += texture.sample(qsampler, float2(offset.x + 7.0*xPixel, offset.y + 7.0*yPixel)).rgb * p7;
//    sum += texture.sample(qsampler, float2(offset.x + 8.0*xPixel, offset.y + 8.0*yPixel)).rgb * p8;
    
    float4 adjusted;
    adjusted.rgb = sum;
    adjusted.g = color.g;
    adjusted.a = 1.0;
    
    //light
    half3 normal = normalize(half3(fragmentIn.position.xyz));
    // Compute the ambient color contribution
    half3 colorN = ambientLightIntensity * (half3)color.rgb;
    // Calculate the diffuse factor as the dot product of the normal and light direction
    float diffuseFactor = saturate(dot(normal, -lightDirection));
    // Add in the diffuse contribution from the light
    colorN += diffuseFactor * diffuseLightIntensity * (half3)color.rgb;
//    return half4(colorN, 1);
}

float4 cubic(float v)
{
    float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
    float4 s = n * n * n;
    float x = s.x;
    float y = s.y - 4.0 * s.x;
    float z = s.z - 4.0 * s.y + 6.0 * s.x;
    float w = 6.0 - x - y - z;
    return float4(x, y, z, w);
}

struct Point{
    float x;
    float y;
};

float getDist(Point p1,Point p2) {
    //两点之间计算距离公式
    return sqrt(pow(p1.x-p2.x,2) + pow(p1.y-p2.y,2));
}

float getArea(Point p1,Point p2,Point p3) {
    float a = getDist(p1, p2);
    float b = getDist(p2, p3);
    float c = getDist(p1, p3);
    float p = (a + b + c) / 2;
    return sqrt(p * (p - a) * (p - b) * (p - c));
}
//bool isInTriangle(Point p1,Point p2,Point p3,Point o) {
//    float s1 = getArea(p1,p2,o);
//    float s2 = getArea(p2,p3,o);
//    float s3 = getArea(p3,p1,o);
//    float s = getArea(p1,p2,p3);
//    return s1+s2+s3 == s; //此处没有用fabs(a-b)<eps比较，是方便大家理解思路
//}
float product(Point p1,Point p2,Point p3) {
    //首先根据坐标计算p1p2和p1p3的向量，然后再计算叉乘
    //p1p2 向量表示为 (p2.x-p1.x,p2.y-p1.y)
    //p1p3 向量表示为 (p3.x-p1.x,p3.y-p1.y)
    return (p2.x-p1.x)*(p3.y-p1.y) - (p2.y-p1.y)*(p3.x-p1.x);
}
bool isInTriangle(Point p1,Point p2,Point p3,Point o) {
    //保证p1，p2，p3是逆时针顺序
    if(product(p1, p2, p3)<0) return isInTriangle(p1,p3,p2,o);
    if(product(p1, p2, o)>0 && product(p2, p3, o)>0 && product(p3, p1, o)>0)
        return true;
    return false;
}


static float distancePoint2LineSeg(float3 point, float3 linePoint1, float3 linePoint2)
{
    float3 v12 = linePoint2 - linePoint1;
    float3 v10 = point - linePoint1;
float f = dot(v12, v10);
if (f < 0)
{
return distance(point, linePoint1);
}
float d = dot(v12, v12);


    if (f > d)
    {
        return distance(point, linePoint2);
    }

    f = f / d;
    float3 pointD = linePoint1 + f * v12;
    return distance (point, pointD);
}
