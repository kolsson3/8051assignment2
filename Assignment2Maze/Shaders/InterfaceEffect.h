//
//  BaseEffect.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.

#import <Foundation/Foundation.h>

#import "GLKit/GLKit.h"

@interface InterfaceEffect : NSObject

@property (nonatomic, assign) GLuint programHandle; //GL structure for passing shader data
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix; //Matrix for model local transform
@property (assign) GLuint texture; //Texture applied to the model

- (id)initWithVertexShader:(NSString *)vertextShader
            fragmentShader:(NSString *)fragmentShader;

- (void)prepareToDraw;

@end
