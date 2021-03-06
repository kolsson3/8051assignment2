#import "InterfaceEffect.h"
#import "Vertex.h"

@implementation InterfaceEffect {
    GLuint _programHandle;
    GLuint _modelViewMatrixUniform;
    GLuint _texUniform;
}

//Function for compiling a shader file
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    //Check that the shader exists
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString)
    {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    //Construct the shader to be compiled
    GLuint shaderHandle = glCreateShader(shaderType);
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
  
    //Compile shader with OpenGL and check for errors.
    glCompileShader(shaderHandle);
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}

//Compile vertex and fragments shaders that were input.
- (void)compileVertexShader:(NSString *)vertexShader
             fragmentShader:(NSString *)fragmentShader
{
    //Compile each shader
    GLuint vertexShaderName = [self compileShader:vertexShader
                                       withType:GL_VERTEX_SHADER];
    GLuint fragmentShaderName = [self compileShader:fragmentShader
                                         withType:GL_FRAGMENT_SHADER];
    
    //Program for holding data to send to GPU
    _programHandle = glCreateProgram();
    
    //Attach shaders
    glAttachShader(_programHandle, vertexShaderName);
    glAttachShader(_programHandle, fragmentShaderName);
    
    //Bind vertex attributes
    glBindAttribLocation(_programHandle, VertexAttribPosition, "a_Position");
    glBindAttribLocation(_programHandle, VertexAttribColor, "a_Color");
    glBindAttribLocation(_programHandle, VertexAttribTexCoord, "a_TexCoord");
    glBindAttribLocation(_programHandle, VertexAttribNormal, "a_Normal");
    
    glLinkProgram(_programHandle);
    
    //Set uniforms from shader data
    self.modelViewMatrix = GLKMatrix4Identity;
    _modelViewMatrixUniform = glGetUniformLocation(_programHandle, "u_ModelViewMatrix");
    _texUniform = glGetUniformLocation(_programHandle, "u_Texture");
    
    //Link program, check for errors.
    GLint linkSuccess;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetProgramInfoLog(_programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
}

//Sets up the matrices and values for the shaders and lighting.
- (void)prepareToDraw
{
    //Set the camera transform matrix and model transform matrix
    glUseProgram(_programHandle);
    glUniformMatrix4fv(_modelViewMatrixUniform, 1, 0, self.modelViewMatrix.m);
    
    //Bind texture
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glUniform1i(_texUniform, 1);
}

//Call when setting up to choose the shaders to use.
- (instancetype)initWithVertexShader:(NSString *)vertexShader
                      fragmentShader:(NSString *)fragmentShader
{
    if (self = [super init])
    {
        [self compileVertexShader:vertexShader fragmentShader:fragmentShader];
    }
    return self;
}

@end 
