//
//  ViewController.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "ViewController.h"
#import "Vertex.h"
#import "BaseEffect.h"
#import "MazeGenerator.h"
#import "CubeModel.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CubeModel *_cube;
    BaseEffect *_shader; //Shader controller
    NSMutableArray *_walls;
    MazeGenerator *mGen;
    float rotationAngle;
    int xrotation;
    UIImageView *dayNight;
    UIImageView *playerIcon;
    GLKVector4 skycolor;
    GLKVector4 daycolor;
    GLKVector4 nightcolor;
    GLKVector3 camPos;
    GLKVector3 camForward;
    UIView *minimapContainer;
    GLKVector3 cameraTranslation;
    
    
    float vInit;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set OpenGL view
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [EAGLContext setCurrentContext:view.context];
    
    //Pan gesture for player movement
    UIPanGestureRecognizer *panSingleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePanGesture: )];
    panSingleGesture.maximumNumberOfTouches = 1;
    panSingleGesture.minimumNumberOfTouches = 1;
    
    [self.view addGestureRecognizer:panSingleGesture];
    
    //Double tap gesture for showing mini map.
    UITapGestureRecognizer *doubleTap2F = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minimapHandler:)];
    doubleTap2F.numberOfTapsRequired = 2;
    doubleTap2F.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:doubleTap2F];
    
    //Double tap gesture for reseting player position
    UITapGestureRecognizer *doubleTap1F = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerReset:)];
    doubleTap1F.numberOfTapsRequired = 2;
    doubleTap1F.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTap1F];
    
    //Button for toggling day/night
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame = CGRectMake(5,20,100,25);
    [lightButton setTitle:@"Day/Night" forState:UIControlStateNormal];
    [lightButton setBackgroundColor:[UIColor blackColor]];
    [lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lightButton addTarget:self action:@selector(dayNightSwap:) forControlEvents:UIControlEventTouchDown];
    [lightButton setEnabled:YES];
    [self.view addSubview:lightButton];
    
    
    //Button for toggling day/night
    UIButton *up = [UIButton buttonWithType:UIButtonTypeCustom];
    up.frame = CGRectMake(5,50,25,25);
    [up setTitle:@"Up" forState:UIControlStateNormal];
    [up setBackgroundColor:[UIColor blackColor]];
    [up setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [up addTarget:self action:@selector(upHandle:) forControlEvents:UIControlEventTouchDown];
    [up setEnabled:YES];
    [self.view addSubview:up];
    
    UIButton *down = [UIButton buttonWithType:UIButtonTypeCustom];
    down.frame = CGRectMake(5,75,25,25);
    [down setTitle:@"Down" forState:UIControlStateNormal];
    [down setBackgroundColor:[UIColor blackColor]];
    [down setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [down addTarget:self action:@selector(downHandle:) forControlEvents:UIControlEventTouchDown];
    [down setEnabled:YES];
    [self.view addSubview:down];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    left.frame = CGRectMake(5,100,25,25);
    [left setTitle:@"Left" forState:UIControlStateNormal];
    [left setBackgroundColor:[UIColor blackColor]];
    [left setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [left addTarget:self action:@selector(leftHandle:) forControlEvents:UIControlEventTouchDown];
    [left setEnabled:YES];
    [self.view addSubview:left];
    
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    right.frame = CGRectMake(5,125,25,25);
    [right setTitle:@"Right" forState:UIControlStateNormal];
    [right setBackgroundColor:[UIColor blackColor]];
    [right setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(rightHandle:) forControlEvents:UIControlEventTouchDown];
    [right setEnabled:YES];
    [self.view addSubview:right];
    
    
    
    
    //Setting initial image for day/night indicator
    dayNight = [[UIImageView alloc] initWithFrame:CGRectMake(105, 20, 25, 25)];
    dayNight.image = [UIImage imageNamed:@"sun"];
    [self.view addSubview:dayNight];
    
    //Creating a container for mini map elements.
    minimapContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (4 * 25) - 5, 20, 100, 100)];
    [minimapContainer setBackgroundColor:[UIColor blackColor]];
    [minimapContainer setAlpha:0.65];
    [self.view addSubview:minimapContainer];
    [minimapContainer setHidden:YES];

    //Label for mini map container
    UILabel *minimapLabel = [[UILabel alloc] init];
    minimapLabel.frame = CGRectMake(0,0,100,25);
    [minimapLabel setText:@"Minimap"];
    [minimapLabel setBackgroundColor:[UIColor blackColor]];
    [minimapLabel setTextColor:[UIColor whiteColor]];
    [minimapLabel setTextAlignment:NSTextAlignmentCenter];
    [minimapContainer addSubview:minimapLabel];
    
    //Set up scene elements
    [self setupScene];
    
    //Add player icon to minimap. Has to be done after scene setup so it's not hidden by map tiles
    playerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 25, 25)];
    playerIcon.image = [UIImage imageNamed:@"Player.png"];
    playerIcon.transform = CGAffineTransformMakeRotation(M_PI);
    [minimapContainer addSubview:playerIcon];
}

-(void) upHandle : (id) sender
{
    camPos = GLKVector3Make(camPos.x + 0.5, camPos.y, camPos.z);
}

-(void) downHandle : (id) sender
{
    camPos = GLKVector3Make(camPos.x - 0.5, camPos.y, camPos.z);
}

-(void) leftHandle : (id) sender
{
    camPos = GLKVector3Make(camPos.x, camPos.y, camPos.z + 0.5);
}

-(void) rightHandle : (id) sender
{
    camPos = GLKVector3Make(camPos.x, camPos.y, camPos.z - 0.5);
}

//Additional setup code
- (void) setupScene
{
    //Initiate shader
    _shader = [[BaseEffect alloc] initWithVertexShader:@"VertexShader.glsl" fragmentShader:@"FragmentShader.glsl"];
    
    //Setup projection view
    _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);
    
    mGen = [MazeGenerator alloc];
    [mGen setupMaze:_shader];
    _walls = [mGen getWalls];
    
    //Setting up mini map
    NSMutableArray *minimap = [mGen generateMinimap];
    int mapY = 25; //First element y coordinate
    int mapX = 0; //First element x coordinate
    for(int r = 0; r < minimap.count; r++)
    {
        NSMutableArray *row = [minimap objectAtIndex:r];
        for(int c = 0; c < [row count]; c++)
        {
            //Create new image view and add to mini map container
            UIImageView *tile = [[UIImageView alloc] initWithFrame:CGRectMake(mapX, mapY, 25, 25)];
            tile.image = [UIImage imageNamed:[row objectAtIndex:c]];
            [minimapContainer addSubview:tile];
            mapX +=25; //Increment x position
        }
        mapY += 25; //Increment y position
        mapX = 0; //Reset x position
    }
    
    //Set vectors for toggling night and day sky colors
    daycolor = GLKVector4Make(0/255.0, 180.0/255.0, 200.0/255.0, 1.0);
    nightcolor = GLKVector4Make(20/255.0, 60.0/255.0, 80.0/255.0, 1.0);
    skycolor = daycolor; //Set initial to day
    
    //Place cube at the start of the maze.
    _cube = [[CubeModel alloc] initWithShader:_shader];
    _cube.scale = 0.2;
    _cube.position = GLKVector3Make(0, 0, 0);
    
    //Trying to figure out movement and whatnot
    rotationAngle = M_PI;
    camForward = GLKVector3Make(0, 0, -1);
    camPos = GLKVector3Make(0, 0, 0);
    
    cameraTranslation = GLKVector3Make(0, 0, 0);
    
    vInit = 0;
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //Set background color
    glClearColor(skycolor.r, skycolor.g, skycolor.g, skycolor.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Enable some rendering options
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    GLKMatrix4 viewMatrix = GLKMatrix4MakeRotation(rotationAngle, 0, 1, 0);
    viewMatrix = GLKMatrix4Translate(viewMatrix, camPos.x, camPos.y, camPos.z);
    
    //Render each wall
    for(id wall in _walls)
    {
        [wall renderWithParentModelViewMatrix:viewMatrix];
    }
    
    //Render the cube
    [_cube renderWithParentModelViewMatrix:viewMatrix];
    
    //Update player icon
    playerIcon.transform = CGAffineTransformMakeRotation(rotationAngle);
    playerIcon.transform = CGAffineTransformTranslate(playerIcon.transform, camPos.x, camPos.z);
}

//Open GL update function
- (void) update
{
    //Update cube for rotation
    [_cube updateWithDelta:[self timeSinceLastUpdate]];
}

//Pan handler for rotating and moving
- (void) handleSinglePanGesture:(UIPanGestureRecognizer *) sender
{
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint translation = [sender translationInView:sender.view];
        float x = translation.x/sender.view.frame.size.width;
        float y = translation.y/sender.view.frame.size.width;
        //camPos = GLKVector3Add(camPos, GLKVector3Make(x, 0, y));
        
    }
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [sender translationInView:sender.view];
        CGPoint velocity = [sender velocityInView:sender.view];

        float tY = translation.y/sender.view.frame.size.width;
        float fX = velocity.x/sender.view.frame.size.width;
        
        rotationAngle += fX;
        
        GLKVector3 forward = GLKVector3Make(sinf(rotationAngle), 0, cosf(rotationAngle));
        
        if(tY != vInit)
        {
            camPos = GLKVector3Add(camPos, GLKVector3MultiplyScalar(forward, tY));
            vInit = tY;
        }

        
        
        //Z Increase = north
        //Z decrease = south
        //X increase = east
        //X decrease = west
        
        
        /**CGPoint velocity = [sender velocityInView:sender.view];
        float x = velocity.x/sender.view.frame.size.width;
        float y = velocity.y/sender.view.frame.size.height;
        xrotation += y;
        
        x = GLKMathRadiansToDegrees(x);
        
        
        rotationAngle += x;
        
        GLKVector3 translation = GLKVector3Make(x, 0, y);
        
        GLKVector3 translationDiff = GLKVector3Subtract(translation, cameraTranslation);
        
        NSLog(@"x:%f,z:%f", translationDiff.x, translationDiff.z);
        cameraTranslation = translation;

        if(x > 0 && rotationAngle > 360) rotationAngle += (x - (360));
        else if(x < 0 && rotationAngle < -360) rotationAngle += (x + (360));
        else rotationAngle += x/2;
        //NSLog(@"rot:%f", x);
        camForward = GLKVector3Make(sinf(GLKMathDegreesToRadians(x)), 0, cosf(GLKMathDegreesToRadians(x)));
        GLKVector3 move = GLKVector3Make(camForward.x/10, camForward.y/10, camForward.z/10);
        //NSLog(@"x:%f,y:%f,z:%f",camForward.x, camForward.y, camForward.z);
        if(y != 0)camPos = GLKVector3Add(camPos, translationDiff);*/
    }
}

//Button handler for switching between night and day
- (void) dayNightSwap : (id) sender
{
    bool day = _shader.ambientLight == 0.75 ? true : false; //Is it day?
    //If its day, change to night. Else change to day.
    _shader.ambientLight = day ? 0.1 : 0.75;
    dayNight.image = day ? [UIImage imageNamed:@"moon.png"] : [UIImage imageNamed:@"sun.png"];
    skycolor = day ? nightcolor : daycolor;
}

//Tap handler for showing/hiding the minimap
- (void) minimapHandler : (id) sender
{
    [minimapContainer setHidden:!minimapContainer.hidden];
}

//Tap handler for reseting player location
- (void) playerReset : (id) sender
{
    rotationAngle = M_PI;
    camForward = GLKVector3Make(0, 0, -1);
    camPos = GLKVector3Make(0, 0, -1);
}

@end
