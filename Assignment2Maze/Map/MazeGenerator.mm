//
//  MazeGenerator.m
//  Project1
//
//  Created by Kris Olsson on 2021-03-12.
//

#import "MazeGenerator.h"
#import "WallModel.h"
#import "FloorModel.h"
#import "TileModel.h"


@implementation MazeGenerator
{
    Maze m;
    NSMutableArray *_walls;
}

//Setup an array of walls to render based on output from the maze algorithm
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

//Generates a minimap of tile models. Positions are a bit hard coded.
- (NSMutableArray *) generateWallMinimap : (InterfaceEffect *) _shader
{
    NSMutableArray *wallminimap = [[NSMutableArray alloc] initWithCapacity:m.rows];

    for(int r = 0; r < m.rows; r++)
    {
        for(int c = 0; c < m.cols; c++)
        {
            MazeCell cell = m.GetCell(r, c);
            
            if(!cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (1).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (4).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (2).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (5).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (3).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (7).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (6).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (8).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (9).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (11).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (10).png"];
                [wallminimap addObject:w];
            }
            else if(!cell.eastWallPresent && cell.westWallPresent && cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (13).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && !cell.westWallPresent && cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (15).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && cell.westWallPresent && !cell.northWallPresent && cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (12).png"];
                [wallminimap addObject:w];
            }
            else if(cell.eastWallPresent && cell.westWallPresent && cell.northWallPresent && !cell.southWallPresent)
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (14).png"];
                [wallminimap addObject:w];
            }
            else
            {
                TileModel *w = [[TileModel alloc] initWithShader:_shader];
                w.position = GLKVector3Make(c*0.2,r*-0.2, 0);
                [w loadTexture:@"Tile (16).png"];
                [wallminimap addObject:w];
            }
        }
    }
    return wallminimap;
}

@end
