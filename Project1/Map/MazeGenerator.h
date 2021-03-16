//
//  MazeGenerator.h
//  Project1
//
//  Created by Kris Olsson on 2021-03-12.
//

#import <Foundation/Foundation.h>
#include "maze.h"
#import <OpenGLES/ES2/glext.h>
#import "GLKit/GLKit.h"
#import "BaseEffect.h"


@interface MazeGenerator : NSObject

- (void) setupMaze : (BaseEffect *) _shader;
- (NSMutableArray *) getWalls; //Return an array of walls to be drawn
- (NSMutableArray *) generateMinimap; //Generates an array of image names to draw minimap

@end
