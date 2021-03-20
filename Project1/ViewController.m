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
    bool canRotate;
    float originalPoint;
    UIImageView *dayNight;
    UIImageView *playerIcon;
    GLKVector4 skycolor;
    GLKVector4 daycolor;
    GLKVector4 nightcolor;
    GLKVector3 camPos;
    GLKVector3 camForward;
    UIView *minimapContainer;
    UIView *fogOptionContainer;
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
    
    //Add player icon to minimap. Has to be done after scene setup so it's not hidden by map tiles
    canRotate = true;
    originalPoint = 2.0f;
    playerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 25, 25)];
    playerIcon.image = [UIImage imageNamed:@"Player.png"];
    playerIcon.transform = CGAffineTransformMakeRotation(M_PI);
    [minimapContainer addSubview:playerIcon];
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
    
    //Some variables used by movement that isnt working
    rotationAngle = M_PI;
    camForward = GLKVector3Make(0, 0, -1);
    camPos = GLKVector3Make(0, 0, 2);
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
    
    //Update player icon not fully working
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
    if(canRotate == true)
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
            
            //CGPoint translation = [sender translationInView:sender.view];
            CGPoint velocity = [sender velocityInView:sender.view];

            //float tY = translation.y/sender.view.frame.size.width;
            float fX = velocity.x/sender.view.frame.size.width;
            
            rotationAngle += fX;
        }
    } else
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
            
            float fX = velocity.x/sender.view.frame.size.width;
            float tY = translation.y/sender.view.frame.size.width;
            
            if (translation.y < 0)
            {
                originalPoint -= 0.1f;
            }
            else
            {
                originalPoint += 0.1f;
            }
            
            
            camPos = GLKVector3Make(0.0f, 0.0f, originalPoint);
        }
        
    }
    
        /*
        GLKVector3 forward = GLKVector3Make(sinf(rotationAngle), 0, cosf(rotationAngle));
        
        if(tY != vInit)
        {
            camPos = GLKVector3Add(camPos, GLKVector3MultiplyScalar(forward, tY));
            vInit = tY;
        }*/

        
        
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


//Button handler for switching between night and day
- (void) dayNightSwap : (id) sender
{
    bool day = _shader.ambientLight == 0.75 ? true : false; //Is it day?
    //If its day, change to night. Else change to day.
    _shader.ambientLight = day ? 0.1 : 0.75;
    dayNight.image = day ? [UIImage imageNamed:@"moon.png"] : [UIImage imageNamed:@"sun.png"];
    skycolor = day ? nightcolor : daycolor;
}

//Button handler to stop camera from rotating when player moves
- (void) toggleRotate : (id) sender
{
    canRotate = !canRotate;
}

//Tap handler for showing/hiding the minimap
- (void) minimapHandler : (id) sender
{
    [minimapContainer setHidden:!minimapContainer.hidden];
}

//Tap handler for reseting player location
- (void) playerReset : (id) sender
{
    if(![sender isKindOfClass:[UIButton class]])
    {
        rotationAngle = M_PI;
        camForward = GLKVector3Make(0, 0, -1);
        camPos = GLKVector3Make(0, 0, 2);
        originalPoint = 2.0f;
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
    
    //Button for toggling rotating camera
    UIButton *rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rotateButton.frame = CGRectMake(5,80,100,25);
    [rotateButton setTitle:@"Rotate" forState:UIControlStateNormal];
    [rotateButton setBackgroundColor:[UIColor blackColor]];
    [rotateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rotateButton addTarget:self action:@selector(toggleRotate:) forControlEvents:UIControlEventTouchDown];
    [rotateButton setEnabled:YES];
    [self.view addSubview:rotateButton];
    
    //Button for toggling fog (foggling)
    UIButton *fogToggleakaFoggle = [UIButton buttonWithType:UIButtonTypeCustom];
    fogToggleakaFoggle.frame = CGRectMake(5,50,100,25);
    [fogToggleakaFoggle setTitle:@"Fog" forState:UIControlStateNormal];
    [fogToggleakaFoggle setBackgroundColor:[UIColor blackColor]];
    [fogToggleakaFoggle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fogToggleakaFoggle addTarget:self action:@selector(foggler:) forControlEvents:UIControlEventTouchDown];
    [fogToggleakaFoggle setEnabled:YES];
    [self.view addSubview:fogToggleakaFoggle];
    
    //Container for the fog controls
    fogOptionContainer = [[UIView alloc] initWithFrame:CGRectMake(5, 75, 100, 125)];
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
}

@end
