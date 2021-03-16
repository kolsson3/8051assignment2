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
            
            //Implementation as it seems borna wants it
            if(cell.eastWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c + 2, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(-90);
                
                if(cell.northWallPresent && cell.southWallPresent) [newWall loadTexture:@"wall1.png"];
                else if(cell.northWallPresent) [newWall loadTexture:@"wall3.png"];
                else if(cell.southWallPresent) [newWall loadTexture:@"wall2.png"];
                else [newWall loadTexture:@"wall4.png"];
                
                [_walls addObject:newWall];
            }
            if(cell.southWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r + 2);
                newWall.rotationY = GLKMathDegreesToRadians(180);
                
                if(cell.eastWallPresent && cell.westWallPresent) [newWall loadTexture:@"wall1.png"];
                else if(cell.eastWallPresent) [newWall loadTexture:@"wall3.png"];
                else if(cell.westWallPresent) [newWall loadTexture:@"wall2.png"];
                else [newWall loadTexture:@"wall4.png"];

                [_walls addObject:newWall];
            }
            if(cell.westWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c - 2, 0, 2*r);
                newWall.rotationY = GLKMathDegreesToRadians(90);
                
                if(cell.northWallPresent && cell.southWallPresent) [newWall loadTexture:@"wall1.png"];
                else if(cell.northWallPresent) [newWall loadTexture:@"wall2.png"];
                else if(cell.southWallPresent) [newWall loadTexture:@"wall3.png"];
                else [newWall loadTexture:@"wall4.png"];

                [_walls addObject:newWall];
            }
            if(cell.northWallPresent)
            {
                WallModel *newWall = [[WallModel alloc] initWithShader:_shader];
                newWall.position = GLKVector3Make(2*c, 0, 2*r - 2);
                newWall.rotationY = GLKMathDegreesToRadians(0);
                
                if(cell.eastWallPresent && cell.westWallPresent) [newWall loadTexture:@"wall1.png"];
                else if(cell.eastWallPresent) [newWall loadTexture:@"wall2.png"];
                else if(cell.westWallPresent) [newWall loadTexture:@"wall3.png"];
                else [newWall loadTexture:@"wall4.png"];

                [_walls addObject:newWall];
            }
            
            
            /**
                            This way places different walls for east, north, west, and south like assignment 2 in jeffs class
                    
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
            
            */
            
            
            //Generate exterior walls
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

//Return walls array
- (NSMutableArray*) getWalls
{
    return _walls;
}

//Iterate over each cell and determine which graphic to display on the minimap
- (NSMutableArray *) generateMinimap
{
    NSMutableArray *minimap = [[NSMutableArray alloc] initWithCapacity:m.rows];
    
    for(int r = 0; r < m.rows; r++)
    {
        NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:m.cols];
        for(int c = 0; c < m.cols; c++)
        {
            MazeCell cell = m.GetCell(r, c);
            
            if(!cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (1)"];
            }
            else if(!cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (4)"];
            }
            else if(!cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (2)"];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (5)"];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (3)"];
            }
            else if(!cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (7)"];
            }
            else if(cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (6)"];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (8)"];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (9)"];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (11)"];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (10)"];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (13)"];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (15)"];
            }
            else if(cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                [row addObject:@"Tile (12)"];
            }
            else if(cell.eastWallPresent && cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                [row addObject:@"Tile (14)"];
            }
            else
            {
                [row addObject:@"Tile (16)"];
            }
        }
        [minimap addObject:row];
    }
    
    return minimap;
}

@end
