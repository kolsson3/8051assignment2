//
//  MazeGenerator.m
//  Project1
//
//  Created by Kris Olsson on 2021-03-12.
//

#import "MazeGenerator.h"
#import "WallModel.h"
#import "FloorModel.h"

@implementation MazeGenerator
{
    Maze m;
    NSMutableArray *_walls;
}

- (void) setupMaze : (BaseEffect *) _shader
{
    m.Create();
    _walls = [[NSMutableArray alloc] initWithCapacity:m.cols * m.rows];
    for(int r = 0; r < m.rows; r++)
    {
        for(int c = 0; c < m.cols; c++)
        {
            FloorModel *newFloor = [[FloorModel alloc] initWithShader:_shader];
            newFloor.position = GLKVector3Make(2*c, -2, 2*r);
            [_walls addObject:newFloor];
            
            MazeCell cell = m.GetCell(r, c);
            
            if(cell.eastWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c + 2, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(-90);
                [newWall loadTexture:@"wall1.png"];
                
                [_walls addObject:newWall];
            }
            if(cell.southWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r + 2);
                newWall.rotationY = GLKMathDegreesToRadians(180);
                [newWall loadTexture:@"wall2.png"];

                [_walls addObject:newWall];
            }
            if(cell.westWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c - 2, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(90);
                [newWall loadTexture:@"wall3.png"];

                [_walls addObject:newWall];
            }
            if(cell.northWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r - 2);
                newWall.rotationY = GLKMathDegreesToRadians(0);
                [newWall loadTexture:@"wall4.png"];

                [_walls addObject:newWall];
            }
            
            //These just draw outside walls so it's easier to see what's going on for testing. Can be removed.
            if(c==0)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(-90);
                [newWall loadTexture:@"wall1.png"];
                [_walls addObject:newWall];
            }
            if(r == 0 && c != 0)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(180);
                [newWall loadTexture:@"wall2.png"];
                [_walls addObject:newWall];
            }
            if(c == m.cols - 1)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(90);
                [newWall loadTexture:@"wall3.png"];
                [_walls addObject:newWall];
            }
            if(r == m.rows - 1 && c != m.cols - 1)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(0);
                [newWall loadTexture:@"wall4.png"];
                [_walls addObject:newWall];
            }
        }
    }
}

- (NSMutableArray*) getWalls
{
    return _walls;
}

@end
