//
//  Camera.h
//  Project1
//
//  Created by Kris Olsson on 2021-03-14.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "GLKit/GLKit.h"

@interface Camera : NSObject

@property GLKVector3 forward;
@property GLKVector3 position;
@property float rotationY;
@property bool flashlight;

- (GLKVector3) getPosition;
- (NSString*) getDirection;

@end
