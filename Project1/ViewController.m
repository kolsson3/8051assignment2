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
    int rotationAngle;
    int xrotation;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set OpenGL view
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    //Setup for Gesture listeners
    UIPanGestureRecognizer *panSingleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePanGesture: )];
    panSingleGesture.maximumNumberOfTouches = 1;
    panSingleGesture.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panSingleGesture];
    
    //Light button
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame = CGRectMake(0,75,100,25);
    [lightButton setTitle:@"Day/Night" forState:UIControlStateNormal];
    [lightButton setBackgroundColor:[UIColor grayColor]];
    [lightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lightButton addTarget:self action:@selector(dayNightSwap:) forControlEvents:UIControlEventTouchDown];
    [lightButton setEnabled:YES];
    [self.view addSubview:lightButton];
    
    [EAGLContext setCurrentContext:view.context];
    [self setupScene];
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
    
    rotationAngle = 0;
    xrotation  = 0;
    
    _cube = [[CubeModel alloc] initWithShader:_shader];
    _cube.scale = 0.2;
    _cube.position = GLKVector3Make(0, 0, 0.5);
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //Set background color
    glClearColor(0/255.0, 180.0/255.0, 180.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Enable some rendering options
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //Set camera perspective
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -1);
    viewMatrix = GLKMatrix4Rotate(viewMatrix, GLKMathDegreesToRadians(xrotation), 1, 0, 0);
    viewMatrix = GLKMatrix4Rotate(viewMatrix, GLKMathDegreesToRadians(180), 0, 1, 0);
    
    for(id wall in _walls)
    {
        [wall renderWithParentModelViewMatrix:viewMatrix];
    }
    
    [_cube renderWithParentModelViewMatrix:viewMatrix];
}

//Open GL update function
- (void) update
{
    [_cube updateWithDelta:[self timeSinceLastUpdate]];
}

//Pan handler for rotating the ship
- (void) handleSinglePanGesture:(UIPanGestureRecognizer *) sender
{
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [sender velocityInView:sender.view];
        float x = velocity.x/sender.view.frame.size.width;
        float y = velocity.y/sender.view.frame.size.height;
        xrotation += y;
        rotationAngle += x;
    }
}

- (void) dayNightSwap : (id) sender
{
    _shader.ambientLight = _shader.ambientLight == 0.75 ? 0.1 : 0.75;
}

@end
