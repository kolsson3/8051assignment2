#import "BaseEffect.h"
#import "Vertex.h"

@implementation BaseEffect {
    GLuint _programHandle;
    GLuint _modelViewMatrixUniform;
    GLuint _projectionMatrixUniform;
    GLuint _texUniform;
    GLuint _lightColorUniform;
    GLuint _lightAmbientIntensityUniform;
    GLuint _lightDiffuseIntensityUniform;
    GLuint _lightDirectionUniform;
    GLuint _matSpecularIntensityUniform;
    GLuint _shininessUniform;
    GLuint _fogDistanceUniform;
    GLuint _fogColorUniform;
    GLuint _fogDensityUniform;
    GLuint _fogIsActiveUniform;
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
    _projectionMatrixUniform = glGetUniformLocation(_programHandle, "u_ProjectionMatrix");
    _texUniform = glGetUniformLocation(_programHandle, "u_Texture");
    _lightColorUniform = glGetUniformLocation(_programHandle, "u_Light.Color");
    _lightAmbientIntensityUniform = glGetUniformLocation(_programHandle, "u_Light.AmbientIntensity");
    _lightDiffuseIntensityUniform = glGetUniformLocation(_programHandle, "u_Light.DiffuseIntensity");
    _lightDirectionUniform = glGetUniformLocation(_programHandle, "u_Light.Direction");
    _matSpecularIntensityUniform = glGetUniformLocation(_programHandle, "u_MatSpecularIntensity");
    _shininessUniform = glGetUniformLocation(_programHandle, "u_Shininess");
    _fogColorUniform = glGetUniformLocation(_programHandle, "u_Fog.FogColor");
    _fogDensityUniform = glGetUniformLocation(_programHandle, "u_Fog.FogDensity");
    _fogDistanceUniform = glGetUniformLocation(_programHandle, "u_Fog.FogDistance");
    _fogIsActiveUniform = glGetUniformLocation(_programHandle, "u_Fog.FogIsActive");
    
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
    glUniformMatrix4fv(_projectionMatrixUniform, 1, 0, self.projectionMatrix.m);
    
    //Bind texture
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texture);
    glUniform1i(_texUniform, 1);
    
    //Ambient lighting values.
    glUniform3f(_lightColorUniform, 1, 1, 1);
    glUniform1f(_lightAmbientIntensityUniform, _ambientLight);
    
    //Diffuse lighting values.
    GLKVector3 lightDirection = GLKVector3Normalize(GLKVector3Make(0, 1, -1));
    glUniform3f(_lightDirectionUniform, lightDirection.x, lightDirection.y, lightDirection.z);
    glUniform1f(_lightDiffuseIntensityUniform, 0.7);
    
    //Specular lighting values.
    glUniform1f(_matSpecularIntensityUniform, 1.0);
    glUniform1f(_shininessUniform, 1.0);
    
    //Set fog values
    glUniform4f(_fogColorUniform, _fogColorR, _fogColorG, _fogColorB, 1);
    glUniform1f(_fogDistanceUniform, _fogDistance);
    glUniform1f(_fogDensityUniform, _fogDensity);
    glUniform1f(_fogIsActiveUniform, _fogIsActive);
}

//Call when setting up to choose the shaders to use.
- (instancetype)initWithVertexShader:(NSString *)vertexShader
                      fragmentShader:(NSString *)fragmentShader
{
    if (self = [super init])
    {
        [self compileVertexShader:vertexShader fragmentShader:fragmentShader];
        _ambientLight = 0.75;
        _fogColorR = 1.0;
        _fogColorG = 1.0;
        _fogColorB = 1.0;
        _fogDensity = 6.0;
        _fogDistance = 20.0;
        _fogIsActive = false;
    }
    return self;
}

@end 
