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
#import "WallModel.h"
#import "InterfaceEffect.h"
#import "TileModel.h"

@interface ViewController ()
@end

@implementation ViewController
{
    CubeModel *_cube; //Cube model
    BaseEffect *_shader; //Shader controller
    NSMutableArray *_walls; //Maze walls to draw
    MazeGenerator *mGen; //Generator for maze data
    UIImageView *dayNight; //Image alternating day/night indicator
    UIImageView *flashlightIcon; //Image alternating flashlight on/off indicator
    GLKVector4 skycolor; //Sky color changing day to night
    GLKVector4 daycolor; //Sky color for day
    GLKVector4 nightcolor; //Sky color for night
    UIView *fogOptionContainer; //Container for fog options
        
    //Camera vectors
    GLKVector3 cameraPos;
    GLKVector3 cameraTarget;
    GLKVector3 cameraDirection;
    GLKVector3 cameraUp;
    GLKVector3 cameraRight;
    float rotationAngle;
    
    //Player values
    float rotationSpeed;
    float movementSpeed;
    float translationX;
    float translationY;
    
    //Minimap stuff
    NSMutableArray *miniMapWalls; //Minimap tiles
    TileModel *playerIcon; //Player tile for minimap
    InterfaceEffect *_i_shader; //Shader for minimap
    bool showMap; //Should the map be visible?
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
    
    //Two finger double tap gesture for showing mini map.
    UITapGestureRecognizer *doubleTap2F = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minimapHandler:)];
    doubleTap2F.numberOfTapsRequired = 2;
    doubleTap2F.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:doubleTap2F];
    
    //Double tap gesture for reseting player position
    UITapGestureRecognizer *doubleTap1F = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerReset:)];
    doubleTap1F.numberOfTapsRequired = 2;
    doubleTap1F.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTap1F];
    
    //Set up UI elements
    [self setupUIElements];
    
    //Set up scene elements
    [self setupScene];
}

//Additional setup code
- (void) setupScene
{
    //Camera tracking
    cameraPos = GLKVector3Make(0, 0, 0);
    cameraTarget = GLKVector3Make(0, 0, -1);
    cameraDirection = GLKVector3Normalize(GLKVector3Subtract(cameraPos, cameraTarget));
    cameraRight = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Make(0, 1, 0), cameraDirection));
    cameraUp = GLKVector3CrossProduct(cameraDirection, cameraRight);
    rotationAngle = 4.5;
    
    //Player values
    rotationSpeed = 0.35;
    movementSpeed = 0.35;
    translationX = 0;
    translationY = 0;
    
    //Enable some rendering options
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //Initiate shaders
    _shader = [[BaseEffect alloc] initWithVertexShader:@"VertexShader.glsl" fragmentShader:@"FragmentShader.glsl"];
    _i_shader = [[InterfaceEffect alloc] initWithVertexShader:@"UIVertex.glsl" fragmentShader:@"UIFragment.glsl"];
    
    //Setup projection view
    _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);
    
    mGen = [MazeGenerator alloc]; //Create maze generator
    [mGen setupMaze:_shader]; //Pass shader for setup
    _walls = [mGen getWalls]; //Get walls of the maze
    miniMapWalls = [mGen generateWallMinimap:_i_shader]; //Create minimap
    playerIcon = [[TileModel alloc] initWithShader:_i_shader]; //Create player icon for minimap
    [playerIcon loadTexture:@"Player.png"]; //Set icon texture
    showMap = false; //Hide map by default

    //Set vectors for toggling night and day sky colors
    daycolor = GLKVector4Make(0/255.0, 180.0/255.0, 200.0/255.0, 1.0);
    nightcolor = GLKVector4Make(20/255.0, 60.0/255.0, 80.0/255.0, 1.0);
    skycolor = daycolor; //Set initial to day
    
    //Place cube at the start of the maze.
    _cube = [[CubeModel alloc] initWithShader:_shader];
    _cube.scale = 0.2;
    _cube.position = GLKVector3Make(0, 0, 0);
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //Set background color
    glClearColor(skycolor.r, skycolor.g, skycolor.g, skycolor.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
    //Update camera directional vectors if changed
    cameraTarget = GLKVector3Make(sinf(rotationAngle), 0, cosf(rotationAngle));
    cameraDirection = GLKVector3Normalize(GLKVector3Subtract(cameraPos, cameraTarget));
    cameraRight = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Make(0, 1, 0), cameraDirection));
    cameraUp = GLKVector3CrossProduct(cameraDirection, cameraRight);
    
    //Debug printouts
    //NSLog(@"target:x=%f,y=%f,z=%f", cameraTarget.x, cameraTarget.y, cameraTarget.z);
    //NSLog(@"dir:x=%f,y=%f,z=%f", cameraDirection.x, cameraDirection.y, cameraDirection.z);
    //NSLog(@"pos:x=%f,y=%f,z=%f", cameraPos.x, cameraPos.y, cameraPos.z);
    //NSLog(@"angle:%f", rotationAngle);
    
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, cameraPos.x + cameraDirection.x, cameraPos.y + cameraDirection.y, cameraPos.z + cameraDirection.z, cameraUp.x, cameraUp.y, cameraUp.z);
        
    //Render each wall
    for(id wall in _walls)
    {
       [wall renderWithParentModelViewMatrix:viewMatrix];
    }
    
    //Render the cube
    [_cube renderWithParentModelViewMatrix:viewMatrix];
    
    //Draw UI models for mini map
    glClear(GL_DEPTH_BUFFER_BIT); //Clear depth so it doesnt clip
    playerIcon.position = cameraPos; //Set player icon to camera position
    playerIcon.rotationZ = rotationAngle; //Set player icon to camera rotation
    //If toggled, show the mini map
    if(showMap)
    {
        float screenWidth = self.view.frame.size.width;
        float screenHeight = self.view.frame.size.width;
        
        NSLog(@"h:%f.w:%f", screenHeight, screenWidth);
        
        for(TileModel *tile in miniMapWalls)
        {
            [playerIcon renderWithParentModelViewMatrix:viewMatrix];
            [tile renderWithParentModelViewMatrix:GLKMatrix4Identity];
        }
    }
    
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
    if(sender .state == UIGestureRecognizerStateEnded)
    {
        translationX = 0;
        translationY = 0;
    }
    else if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [sender velocityInView:sender.view];
        float fX = velocity.x;
        float fY = velocity.y;
        
        CGPoint translate = [sender translationInView:sender.view];
        float tx = translate.x;
        float ty = translate.y;
        
        if(fabsf(fX) > fabsf(fY))
        {
            if(fX > 0){
                rotationAngle -= rotationSpeed;
            }
            else if (fX < 0)
            {
                rotationAngle += rotationSpeed;
            }
        }
        else if(fabsf(fY) > fabsf(fX))
        {
            if(fY > 0)
            {
                cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraTarget, movementSpeed));
            }
            else
            {
                cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraTarget, -movementSpeed));
            }
        }
        
        
        if(tx > translationX)
        {
            //rotationAngle += rotationSpeed;

        }
        if(tx < translationX)
        {
            //rotationAngle = rotationAngle - rotationSpeed;
        }
        
        if(ty > translationY)
        {
            //cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraTarget, -movementSpeed));
        }
        if(ty < translationY)
        {
            //
        }
        translationX = tx;
        translationY = ty;
        NSLog(@"x:%f,y:%f", fX, fY);
        
        
        
        //if(fY > 0.25 || fY < -0.25)
        //{
            if(fY > 0)
            {
                
            }
            else if(fY < 0)
            {
            }
       // }
        //else
        //{
        //}
        
        //if(fY > 2 || fY < -2) cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraDirection, movementSpeed));
        
        
    }
}

//Button handler for switching between night and day
- (void) dayNightSwap : (id) sender
{
    bool day = _shader.ambientLight == 0.75 ? true : false; //Is it day?
    //If its day, change to night. Else change to day.
    _shader.ambientLight = day ? 0.1 : 0.75;
    _shader.diffuseLight = day ? 0.35 : 0.7;
    dayNight.image = day ? [UIImage imageNamed:@"moon.png"] : [UIImage imageNamed:@"sun.png"];
    skycolor = day ? nightcolor : daycolor;
}

//Button handler for turning the flashlight on or off
- (void) flashlight : (id) sender
{
    bool on = _shader.specularLight == 0.5 ? false : true; //Is the flashlight on already?
    _shader.specularLight = on ? 0.5 : 2.5; //If on, turn it off.
    _shader.diffuseLight = on ? _shader.diffuseLight * 0.5 : _shader.diffuseLight * 2;
    flashlightIcon.image = on ? [UIImage imageNamed:@"lightoff.png"] : [UIImage imageNamed:@"lighton.png"];
}

//Tap handler for showing/hiding the minimap
- (void) minimapHandler : (id) sender
{
    showMap = !showMap;
}

//Tap handler for reseting player location
- (void) playerReset : (id) sender
{
    if(![sender isKindOfClass:[UIButton class]])
    {
        //Reset camera values to initial
        cameraPos = GLKVector3Make(0, 0, 0);
        cameraTarget = GLKVector3Make(0, 0, -1);
        cameraDirection = GLKVector3Normalize(GLKVector3Subtract(cameraPos, cameraTarget));
        cameraRight = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Make(0, 1, 0), cameraDirection));
        cameraUp = GLKVector3CrossProduct(cameraDirection, cameraRight);
        rotationAngle = M_PI;
    }
}

/**
    Fog control handlers
 */

//Toggles fog and fog controls container
-(void) foggler : (id) sender
{
    _shader.fogIsActive = !_shader.fogIsActive;
    [fogOptionContainer setHidden:![fogOptionContainer isHidden]];
}

//Update fog density
- (void) fogDensityChange : (UITextField *) sender
{
    float density = [sender.text floatValue];
    if(density >= 0 && density <= 20) _shader.fogDensity = density;
    else
    {
        _shader.fogDensity = 6;
        [sender setText:@"6"];
    }
}

//Update fog distance
- (void) fogDistanceChange : (UITextField *) sender
{
    float dist = [sender.text floatValue];
    if(dist >= 0 && dist <= 100) _shader.fogDistance = dist;
    else
    {
        _shader.fogDistance = 20;
        [sender setText:@"20"];
    }
}

//Update fog redness
- (void) fogColorRChange : (UITextField *) sender
{
    float r = [sender.text floatValue];
    if(r >= 0 && r <= 1) _shader.fogColorR = r;
    else
    {
        _shader.fogColorR = 1;
        [sender setText:@"1.0"];
    }
}

//Update fog greenness
- (void) fogColorGChange : (UITextField *) sender
{
    float g = [sender.text floatValue];
    if(g >= 0 && g <= 1) _shader.fogColorG = g;
    else
    {
        _shader.fogColorG = 1;
        [sender setText:@"1.0"];
    }
}

//Update fog blueness
- (void) fogColorBChange : (UITextField *) sender
{
    float b = [sender.text floatValue];
    if(b >= 0 && b <= 1) _shader.fogColorB = b;
    else
    {
        _shader.fogColorB = 1;
        [sender setText:@"1.0"];
    }
}

/**
        End Fog control handlers
 */

//Function to set up UI Elements, really just to keep them separate for cleanliness
- (void) setupUIElements
{
    //Button for toggling day/night
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame = CGRectMake(5,20,100,25);
    [lightButton setTitle:@"Day/Night" forState:UIControlStateNormal];
    [lightButton setBackgroundColor:[UIColor blackColor]];
    [lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lightButton addTarget:self action:@selector(dayNightSwap:) forControlEvents:UIControlEventTouchDown];
    [lightButton setEnabled:YES];
    [self.view addSubview:lightButton];
    
    //Setting initial image for day/night indicator
    dayNight = [[UIImageView alloc] initWithFrame:CGRectMake(105, 20, 25, 25)];
    dayNight.image = [UIImage imageNamed:@"sun"];
    [self.view addSubview:dayNight];
    
    //Button for toggling flashlight
    UIButton *flashlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashlightButton.frame = CGRectMake(5,50,100,25);
    [flashlightButton setTitle:@"Flashlight" forState:UIControlStateNormal];
    [flashlightButton setBackgroundColor:[UIColor blackColor]];
    [flashlightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashlightButton addTarget:self action:@selector(flashlight:) forControlEvents:UIControlEventTouchDown];
    [flashlightButton setEnabled:YES];
    [self.view addSubview:flashlightButton];
    
    //Setting initial image for day/night indicator
    flashlightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(105, 50, 25, 25)];
    flashlightIcon.image = [UIImage imageNamed:@"lightoff"];
    [self.view addSubview:flashlightIcon];
    
    //Button for toggling fog (foggling)
    UIButton *fogToggleakaFoggle = [UIButton buttonWithType:UIButtonTypeCustom];
    fogToggleakaFoggle.frame = CGRectMake(5,80,100,25);
    [fogToggleakaFoggle setTitle:@"Fog" forState:UIControlStateNormal];
    [fogToggleakaFoggle setBackgroundColor:[UIColor blackColor]];
    [fogToggleakaFoggle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fogToggleakaFoggle addTarget:self action:@selector(foggler:) forControlEvents:UIControlEventTouchDown];
    [fogToggleakaFoggle setEnabled:YES];
    [self.view addSubview:fogToggleakaFoggle];
    
    //Container for the fog controls
    fogOptionContainer = [[UIView alloc] initWithFrame:CGRectMake(5, 110, 100, 125)];
    [fogOptionContainer setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:fogOptionContainer];
    [fogOptionContainer setHidden:YES];
    
    //Labels for fog controls
    UILabel *fogDensityLabel = [[UILabel alloc] init];
    fogDensityLabel.frame = CGRectMake(0,0,70,25);
    [fogDensityLabel setText:@"Density"];
    [fogDensityLabel setTextColor:[UIColor whiteColor]];
    [fogOptionContainer addSubview:fogDensityLabel];
    
    //Labels for fog controls
    UILabel *fogDistanceLabel = [[UILabel alloc] init];
    fogDistanceLabel.frame = CGRectMake(0,25,70,25);
    [fogDistanceLabel setText:@"Distance"];
    [fogDistanceLabel setTextColor:[UIColor whiteColor]];
    [fogOptionContainer addSubview:fogDistanceLabel];
    
    //Text field for setting fog density
    UITextField *fogDensityField = [[UITextField alloc] initWithFrame:CGRectMake(70, 0, 30, 25)];
    [fogDensityField setText:@"6"];
    [fogDensityField setBackgroundColor:[UIColor whiteColor]];
    [fogDensityField setTextAlignment:NSTextAlignmentCenter];
    [fogDensityField addTarget:self action:@selector(fogDensityChange:) forControlEvents:UIControlEventEditingChanged];
    [fogOptionContainer addSubview:fogDensityField];
    
    //Text field for setting fog distance
    UITextField *fogDistanceField = [[UITextField alloc] initWithFrame:CGRectMake(70, 25, 30, 25)];
    [fogDistanceField setText:@"20"];
    [fogDistanceField setBackgroundColor:[UIColor whiteColor]];
    [fogDistanceField setTextAlignment:NSTextAlignmentCenter];
    [fogDistanceField addTarget:self action:@selector(fogDistanceChange:) forControlEvents:UIControlEventEditingChanged];
    [fogOptionContainer addSubview:fogDistanceField];
    
    //Labels for fog color controls
    UILabel *fogColorLabel = [[UILabel alloc] init];
    fogColorLabel.frame = CGRectMake(0,50,100,25);
    [fogColorLabel setText:@"Color"];
    [fogColorLabel setTextColor:[UIColor whiteColor]];
    [fogColorLabel setTextAlignment:NSTextAlignmentCenter];
    [fogOptionContainer addSubview:fogColorLabel];
    
    //Labels for fog color controls
    UILabel *fogColorRLabel = [[UILabel alloc] init];
    fogColorRLabel.frame = CGRectMake(0,75,33,25);
    [fogColorRLabel setText:@"R"];
    [fogColorRLabel setTextColor:[UIColor whiteColor]];
    [fogColorRLabel setTextAlignment:NSTextAlignmentCenter];
    [fogOptionContainer addSubview:fogColorRLabel];
    
    //Labels for fog color controls
    UILabel *fogColorGLabel = [[UILabel alloc] init];
    fogColorGLabel.frame = CGRectMake(33,75,33,25);
    [fogColorGLabel setText:@"G"];
    [fogColorGLabel setTextColor:[UIColor whiteColor]];
    [fogColorGLabel setTextAlignment:NSTextAlignmentCenter];
    [fogOptionContainer addSubview:fogColorGLabel];
    
    //Labels for fog color controls
    UILabel *fogColorBLabel = [[UILabel alloc] init];
    fogColorBLabel.frame = CGRectMake(66,75,33,25);
    [fogColorBLabel setText:@"B"];
    [fogColorBLabel setTextColor:[UIColor whiteColor]];
    [fogColorBLabel setTextAlignment:NSTextAlignmentCenter];
    [fogOptionContainer addSubview:fogColorBLabel];
    
    //Input for fog redness
    UITextField *fogColorR = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, 33, 25)];
    [fogColorR setText:@"1.0"];
    [fogColorR setBackgroundColor:[UIColor whiteColor]];
    [fogColorR setTextAlignment:NSTextAlignmentCenter];
    [fogColorR addTarget:self action:@selector(fogColorRChange:) forControlEvents:UIControlEventEditingChanged];
    [fogOptionContainer addSubview:fogColorR];
    
    //Input for fog greenness
    UITextField *fogColorG = [[UITextField alloc] initWithFrame:CGRectMake(33, 100, 33, 25)];
    [fogColorG setText:@"1.0"];
    [fogColorG setBackgroundColor:[UIColor whiteColor]];
    [fogColorG setTextAlignment:NSTextAlignmentCenter];
    [fogColorG addTarget:self action:@selector(fogColorGChange:) forControlEvents:UIControlEventEditingChanged];
    [fogOptionContainer addSubview:fogColorG];
    
    //Input for fog blueness
    UITextField *fogColorB = [[UITextField alloc] initWithFrame:CGRectMake(66, 100, 33, 25)];
    [fogColorB setText:@"1.0"];
    [fogColorB setBackgroundColor:[UIColor whiteColor]];
    [fogColorB setTextAlignment:NSTextAlignmentCenter];
    [fogColorB addTarget:self action:@selector(fogColorBChange:) forControlEvents:UIControlEventEditingChanged];
    [fogOptionContainer addSubview:fogColorB];
}

@end
