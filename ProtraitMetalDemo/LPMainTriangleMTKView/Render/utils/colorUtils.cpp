//
//  colorUtils.cpp
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/28.
//

#include "colorUtils.hpp"
#include <simd/simd.h>
//morph effect 由于morpheffect 是计算出来的所以就直接放在了.metal里面
static int _hue_shift = 0;

typedef struct {
float h;
float s;
float v;
}hsvColor;
typedef struct {
    float r;       // a fraction between 0 and 1
    float g;       // a fraction between 0 and 1
    float b;       // a fraction between 0 and 1
} rgb;

hsvColor hsv(float h,float s,float v){
 hsvColor color;
color.h = h;
color.s = s;
color.v = v;
return color;
}

hsvColor getMorphColor(vector_float2 vetor){
 
    double value = 0;

    value += sin(vetor.x/30.0);

    value += sin(vetor.y/15.0);

    value += sin((vetor.x + vetor.y)/30.0);

    value += sin(sqrt(vetor.x * vetor.x + vetor.y * vetor.y)/30.0);
    // shift range from -4 .. 4 to 0 .. 8
    value += 2;
    // bring range down to 0 .. 1
    value /= 4;
     hsvColor color  = hsv((_hue_shift  + (uint16_t)(value * 360)) % 360 , 1.0, 1.0);
    return color;
}


rgb hsv2rgb(hsvColor input)
{
    float      hh, p, q, t, ff;
    long        i;
    rgb         output;

    if(input.s <= 0.0) {       // < is bogus, just shuts up warnings
        output.r = input.v;
        output.g = input.v;
        output.b = input.v;
        return output;
    }
    hh = input.h;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = input.v * (1.0 - input.s);
    q = input.v * (1.0 - (input.s * ff));
    t = input.v * (1.0 - (input.s * (1.0 - ff)));

    switch(i) {
    case 0:
        output.r = input.v;
        output.g = t;
        output.b = p;
        break;
    case 1:
        output.r = q;
        output.g = input.v;
        output.b = p;
        break;
    case 2:
        output.r = p;
        output.g = input.v;
        output.b = t;
        break;

    case 3:
        output.r = p;
        output.g = q;
        output.b = input.v;
        break;
    case 4:
        output.r = t;
        output.g = p;
        output.b = input.v;
        break;
    case 5:
    default:
        output.r = input.v;
        output.g = p;
        output.b = q;
        break;
    }
    return output;
}
