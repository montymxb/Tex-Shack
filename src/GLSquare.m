//
//  GLSquare.m
//  Bit Shooter
//
//
//Copyright (c) 2014 Benjamin Wilson Friedman
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "GLSquare.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GLSquare

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

GLfloat colorsTex[4] = { 1, 1, 1, 1};

const GLubyte textureCords[] =
{
    1, 1,
    1, 0,
    0, 0,
    0, 1
};

const GLubyte indicesWHO[] =
{
    1, 0, 2, 3
};

-(id)init : (float) width : (float) height
{
    self = [super init];
    
    if(self)
    {
        GLfloat doubleFaceVertexTex[] =
        {
            1, -1, 0,
            1, 1, 0,
            -1, 1, 0,
            -1, -1, 0
        };
        
        //height = width;
        /**/
        doubleFaceVertexTex[0]*=width;
        doubleFaceVertexTex[1]*=height;
        
        doubleFaceVertexTex[3]*=width;
        doubleFaceVertexTex[4]*=height;
        
        doubleFaceVertexTex[6]*=width;
        doubleFaceVertexTex[7]*=height;
        
        doubleFaceVertexTex[9]*=width;
        doubleFaceVertexTex[10]*=height;
        /* */
        
        //Find and link shaders
        GLuint vertexShader = [self findAndCompileShader:
                               @"\
                               attribute vec4 position;\
                               uniform mat4 modelViewProjectionMatrix;\
                               uniform mat3 normalMatrix;\
                               attribute vec2 a_TexCoordinate;\
                               varying vec2 v_TexCoordinate;\
                               \
                               void main()\
                               {\
                                   gl_Position = modelViewProjectionMatrix * position;\
                                   v_TexCoordinate = a_TexCoordinate;\
                               }"
                                                        : GL_VERTEX_SHADER];
        
        GLuint fragmentShader = [self findAndCompileShader:
                                 @"\
                                 precision mediump float;\
                                 uniform vec4 vColor;\
                                 uniform sampler2D u_Texture;\
                                 varying vec2 v_TexCoordinate;\
                                 \
                                 void main()\
                                 {\
                                     gl_FragColor = vColor * texture2D( u_Texture, v_TexCoordinate);\
                                 }"
                                                          : GL_FRAGMENT_SHADER];
        
        //create and link program
        _program = glCreateProgram();
        glAttachShader( _program, vertexShader);
        glAttachShader( _program, fragmentShader);
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        glBindAttribLocation( _program, GLKVertexAttribPosition, "position");
        glBindAttribLocation( _program, GLKVertexAttribTexCoord0, "a_TexCoordinate");
        
        glLinkProgram( _program);
        
        //check for final errors
        GLint linkSuccess;
        glGetProgramiv( _program, GL_LINK_STATUS, &linkSuccess);
        
        if( linkSuccess == GL_FALSE)
        {
            GLchar messages[256];
            glGetProgramInfoLog( _program, sizeof(messages), 0, &messages[0]);
            NSString *msgString = [NSString stringWithUTF8String: messages];
            NSLog(@"Error in final Program: %@", msgString);
        }
        
        // Get uniform locations.
        uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
        uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
        mColorHandle = glGetUniformLocation( _program, "vColor");
        mTextureUniformHandle = glGetUniformLocation( _program, "u_Texture");
        mTextureCoordinateHandle = glGetAttribLocation( _program, "a_TexCoordinate");
        
        //gen vertex arrays
        glGenVertexArraysOES( 1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        //setup vertex arrays
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(doubleFaceVertexTex), doubleFaceVertexTex, GL_STATIC_DRAW);
        //enable vertex buffer array
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, 0);
        
        //generate index buffer
        glGenBuffers( 1, &_indexBuffer);
        glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(indicesWHO), indicesWHO, GL_STATIC_DRAW);
        
        
        //generate texture buffer
        glGenBuffers( 1, &_textureBuffer);
        glBindBuffer( GL_ARRAY_BUFFER, _textureBuffer);
        glBufferData( GL_ARRAY_BUFFER, sizeof(textureCords), textureCords, GL_STATIC_DRAW);
        //enable texture stuff
        glEnableVertexAttribArray(mTextureCoordinateHandle);
        glVertexAttribPointer( mTextureCoordinateHandle, 2, GL_UNSIGNED_BYTE, GL_FALSE, 0, 0);
        
        glBindVertexArrayOES(0);
    }
    return self;
}

-(GLuint)findAndCompileShader:(NSString *)shaderName :(GLenum)shaderType
{
    
    NSString *shaderContent = shaderName;
    
    if(!shaderContent)
    {
        NSLog(@"-->Error loading shader: ");
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderContent UTF8String];
    int shaderStringLength = (int)[shaderContent length];
    
    glShaderSource( shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv( shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    if(compileSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetShaderInfoLog( shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *mesgString = [NSString stringWithUTF8String: messages];
        NSLog(@"Error in Shader Compiling: %@", mesgString);
    }
    
    //gets the SHADER HANDLE out of it
    return shaderHandle;
}

-(void)drawWithTexture:(GLuint)texture withMatrix:(GLKMatrix4)mvpMatrix withNormal:(GLKMatrix3)normalMatrix
{
    glBindVertexArrayOES(_vertexArray);
    
    //Add program to OpenGL ES Environment
    glUseProgram(_program);
    
    if(colorsTex[3] != 1 || colorsTex[0] != 1 || colorsTex[1] != 1 || colorsTex[2] != 1)
    {
        colorsTex[0] = 1;
        colorsTex[1] = 1;
        colorsTex[2] = 1;
        colorsTex[3] = 1;
    }
    
    //glActiveTexture( GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D, texture);
    glUniform1i( mTextureUniformHandle, 0);
    
    //set color for drawing this triangle
    glUniform4fv( mColorHandle, 1, colorsTex);
    
    glUniformMatrix4fv( uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvpMatrix.m);
    glUniformMatrix3fv( uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4);
}

-(void)startOPX:(GLuint)texture
{
    glBindVertexArrayOES(_vertexArray);
    
    //Add program to OpenGL ES Environment
    glUseProgram(_program);
    
    if(colorsTex[3] != 1 || colorsTex[0] != 1 || colorsTex[1] != 1 || colorsTex[2] != 1)
    {
        colorsTex[0] = 1;
        colorsTex[1] = 1;
        colorsTex[2] = 1;
        colorsTex[3] = 1;
    }
    
    glBindTexture( GL_TEXTURE_2D, texture);
    glUniform1i( mTextureUniformHandle, 0);
    
    //set color for drawing this triangle
    glUniform4fv( mColorHandle, 1, colorsTex);
}

-(void)modifyTexture:(GLuint)texture
{
    glBindTexture( GL_TEXTURE_2D, texture);
    glUniform1i( mTextureUniformHandle, 0);
}

-(void)drawOPXwithMatrix:(GLKMatrix4)mvpMatrix withNormal:(GLKMatrix3)normalMatrix
{
    
    glUniformMatrix4fv( uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvpMatrix.m);
    glUniformMatrix3fv( uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4);
}

-(void)startOPXwithTexture:(GLuint)texture withRed: (float) reD withGreen: (float) greeN withBlue: (float) bluE andAlpha: (float) alphA
{
    glBindVertexArrayOES(_vertexArray);
    
    //Add program to OpenGL ES Environment
    glUseProgram(_program);
    
    colorsTex[0] = reD;
    colorsTex[1] = greeN;
    colorsTex[2] = bluE;
    colorsTex[3] = alphA;
    
    glBindTexture( GL_TEXTURE_2D, texture);
    glUniform1i( mTextureUniformHandle, 0);
    
    glUniform4fv( mColorHandle, 1, colorsTex);
}

-(void)modifyTexture: (GLuint) texture withRed: (float) reD withGreen: (float) greeN withBlue: (float) bluE andAlpha: (float) alphA
{
    //our personal 'escape' number
    if(texture != -1)
    {
        glBindTexture( GL_TEXTURE_2D, texture);
        glUniform1i( mTextureUniformHandle, 0);
    }
    
    if(reD != -1)
        colorsTex[0] = reD;
    if(greeN != -1)
        colorsTex[1] = greeN;
    if(bluE != -1)
        colorsTex[2] = bluE;
    if(alphA != -1)
    colorsTex[3] = alphA;
    
    if( reD != -1 || greeN != -1 || bluE != -1 || alphA != -1)
        glUniform4fv( mColorHandle, 1, colorsTex);
}

-(void)drawWithTexture: (GLuint) texture withMatrix: (GLKMatrix4) mvpMatrix withNormal: (GLKMatrix3) normalMatrix withR: (float) R withG: (float) G withB: (float) B withA: (float) alpha
{
    glBindVertexArrayOES(_vertexArray);
    
    //Add program to OpenGL ES Environment
    glUseProgram(_program);
    
    colorsTex[0] = R;
    colorsTex[1] = G;
    colorsTex[2] = B;
    colorsTex[3] = alpha;
    
    //set color for drawing this triangle
    glUniform4fv( mColorHandle, 1, colorsTex);
    
    //glActiveTexture( GL_TEXTURE0); redundant, always texture 0
    glBindTexture( GL_TEXTURE_2D, texture);
    glUniform1i( mTextureUniformHandle, 0);
    
    //set color for drawing this triangle
    glUniform4fv( mColorHandle, 1, colorsTex);
    
    glUniformMatrix4fv( uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvpMatrix.m);
    glUniformMatrix3fv( uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
    glDrawArrays( GL_TRIANGLE_FAN, 0, 4);
    
    //set color tex BACK, this addresses a rather irritating flicker that happens when this is called
    colorsTex[0] = 1;
    colorsTex[1] = 1;
    colorsTex[2] = 1;
    colorsTex[3] = 1;
}

@end
