//
//  CubeModel.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "FloorModel.h"

@implementation FloorModel

//Each face is defined by distinct vertices, repeated vertices needed for corners.
//Attributes orderd according to Vertex.h (position, color, tex coor, normal)
const static Vertex vertices[] =
{
    {{1,1,1},{1,0,0,1},{1,0},{0,1,0}},
    {{1,1,-1},{0,1,0,1},{1,1},{0,1,0}},
    {{-1,1,-1},{0,0,1,1},{0,1},{0,1,0}},
    {{-1,1,1},{0,0,0,1},{0,0},{0,1,0}},
};

//Indices linking vertices to make the model.
//Each face is made of triangles linked by three vertices.
//Order of vertices matters, counter clockwise order faces the camera
const static GLubyte indices[] =
{
    0,1,2,
    2,3,0,
};

//Initiation method inherited from Model.m
- (instancetype) initWithShader:(BaseEffect *) shader
{
    //Initialize cube with shader and vertex data.
    if(self = [super initWithName:"floor"
                           shader:shader
                         vertices:(Vertex *)vertices
                      vertexCount:sizeof(vertices)/sizeof(vertices[0])
                          indices:indices
                       indexCount: sizeof(indices)/sizeof(indices[0])])
    {
        //Set texture from Resources folder
        [self loadTexture:@"floor.png"];
    }
    return self;
}

//Update method interited from Model.m
-(void)updateWithDelta:(NSTimeInterval)delta
{
}

@end
