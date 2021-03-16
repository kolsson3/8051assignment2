//
//  Camera.m
//  Project1
//
//  Created by Kris Olsson on 2021-03-14.
//

#import "Camera.h"

@implementation Camera

- (id) init
{
    self.position = GLKVector3Make(0, 0, -1);
    self.rotationY = M_PI;
    return self;
}


- (GLKVector3) getPosition
{
    return self.position;
}

- (NSString*) getDirection
{
    if(self.forward.x == 1)
    {
        
    }
    return @"";
}

@end
