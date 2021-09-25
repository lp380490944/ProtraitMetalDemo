//
//  LPMTKConfig.h
//  ProtraitMetalDemo
//
//  Created by Bluce on 2021/9/16.
//

#ifndef LPMTKConfig_h
#define LPMTKConfig_h

#define RENDER_ON_MAIN_THREAD 0

#define ANIMATION_RENDERING   1

// When enabled, the drawable's size is updated automatically whenever
// the view is resized. When disabled, you can update the drawable's
// size explicitly outside the view class.
#define AUTOMATICALLY_RESIZE  1


// When enabled, the renderer creates a depth target (i.e. depth buffer)
// and attaches with the render pass descritpr along with the drawable
// texture for rendering.  This enables the app properly perform depth testing.
#define CREATE_DEPTH_BUFFER   1


#endif /* LPMTKConfig_h */
