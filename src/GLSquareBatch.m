//
//  GLSquare.m
//  Bit Shooter
//
//  Created by Benjamin Friedman on 1/31/14.

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

#import "GLSquareBatch.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define PHAT_CORDS 3
#define PHAT_TEX 2
#define PHAT_MXCORD 1
#define INDEX_STRIDE_SIZE 6

#define PHAT_STRIDE 6

#define MAX_BATCH_SIZE 20

@implementation GLSquareBatch

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

GLfloat colorsTex[4] = { 1, 1, 1, 1};

typedef struct
{
    GLfloat glCords[PHAT_CORDS];
    GLfloat glTexCord[PHAT_TEX];
    GLfloat glMxId[PHAT_MXCORD];
}PhatVertex;

/*
const GLubyte textureCords[] =
{
    1, 1,
    1, 0,
    0, 0,
    0, 1
};
 */

/*
const GLubyte indices[] =
{
    1, 0, 2, 3
};
 */
static GLubyte indices[MAX_BATCH_SIZE * INDEX_STRIDE_SIZE];
static GLfloat *matrixBuffer;

static int storeIndex;
static int numSprites;
static int lastTexture;
static float lastRed;
static float lastGreen;
static float lastBlue;
static float lastAlpha;
static int a_MVPMatrixIndexHandle;

-(id)init : (float) width : (float) height
{
    self = [super init];
    
    if(self)
    {
        numSprites = 0;
        storeIndex = 0;
        lastTexture = -1;
        
        matrixBuffer = (GLfloat *)malloc(sizeof(GLfloat) * (16 * MAX_BATCH_SIZE));
        
        PhatVertex phatVertex[MAX_BATCH_SIZE * 4];
        
        short trueX = 0;
        short indexMarker = 0;
        for(char x = 0; x < MAX_BATCH_SIZE * 4; x+=4)
        {
            phatVertex[x].glCords[0]=width;
            phatVertex[x].glCords[1]=-height;
            phatVertex[x].glCords[2]=0;
            phatVertex[x].glTexCord[0]=1;
            phatVertex[x].glTexCord[1]=1;
            phatVertex[x].glMxId[0]=trueX;
            
            phatVertex[x+1].glCords[0]=width;
            phatVertex[x+1].glCords[1]=height;
            phatVertex[x+1].glCords[2]=0;
            phatVertex[x+1].glTexCord[0]=1;
            phatVertex[x+1].glTexCord[1]=0;
            phatVertex[x+1].glMxId[0]=trueX;
            
            phatVertex[x+2].glCords[0]=-width;
            phatVertex[x+2].glCords[1]=height;
            phatVertex[x+2].glCords[2]=0;
            phatVertex[x+2].glTexCord[0]=0;
            phatVertex[x+2].glTexCord[1]=0;
            phatVertex[x+2].glMxId[0]=trueX;
            
            phatVertex[x+3].glCords[0]=-width;
            phatVertex[x+3].glCords[1]=-height;
            phatVertex[x+3].glCords[2]=0;
            phatVertex[x+3].glTexCord[0]=0;
            phatVertex[x+3].glTexCord[1]=1;
            phatVertex[x+3].glMxId[0]=trueX;
            
            //seperate item, but same progression
            /*
            indices[indexMarker++]=1+x;
            indices[indexMarker++]=0+x;
            indices[indexMarker++]=2+x;
            indices[indexMarker++]=3+x;
             */
            indices[indexMarker++]=0+x;
            indices[indexMarker++]=1+x;
            indices[indexMarker++]=2+x;
            indices[indexMarker++]=0+x;
            indices[indexMarker++]=2+x;
            indices[indexMarker++]=3+x;
            
            trueX++;
        }
        
        NSString *str = [NSString stringWithFormat: @"\
                         attribute vec4 position;\
                         uniform mat4 modelViewProjectionMatrix[%d];\
                         attribute float a_MVPMatrixIndex;\
                         uniform mat3 normalMatrix;\
                         attribute vec2 a_TexCoordinate;\
                         varying vec2 v_TexCoordinate;\
                         \
                         void main()\
                         {\
                            int mvpMatrixIndex = int(a_MVPMatrixIndex);\
                            gl_Position = modelViewProjectionMatrix[mvpMatrixIndex] * position;\
                            v_TexCoordinate = a_TexCoordinate;\
                         }", MAX_BATCH_SIZE];
        
        //Find and link shaders
        GLuint vertexShader = [self findAndCompileShader: str: GL_VERTEX_SHADER];
        
        NSString *str2 = [NSString stringWithFormat:
                          @"\
                          precision mediump float;\
                          uniform vec4 vColor;\
                          uniform sampler2D u_Texture;\
                          varying vec2 v_TexCoordinate;\
                          \
                          void main()\
                          {\
                            gl_FragColor = vColor * texture2D( u_Texture, v_TexCoordinate);\
                          }"];
        
        GLuint fragmentShader = [self findAndCompileShader: str2: GL_FRAGMENT_SHADER];
        
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
        
        a_MVPMatrixIndexHandle = glGetAttribLocation( _program, "a_MVPMatrixIndex");
        
        //gen vertex arrays
        glGenVertexArraysOES( 1, &_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        //setup vertex arrays
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(phatVertex), phatVertex, GL_STATIC_DRAW);
        
        //setup vertex cords
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, PHAT_STRIDE * sizeof(GLfloat), 0);
        
        //setup texture cords
        glEnableVertexAttribArray(mTextureCoordinateHandle);
        glVertexAttribPointer( mTextureCoordinateHandle, 2, GL_FLOAT, GL_FALSE, PHAT_STRIDE * sizeof(GLfloat), (GLvoid *)(PHAT_CORDS * sizeof(GLfloat)));
        
        //setup MatrixThingy
        glEnableVertexAttribArray( a_MVPMatrixIndexHandle);
        glVertexAttribPointer( a_MVPMatrixIndexHandle, 1, GL_FLOAT, GL_FALSE, PHAT_STRIDE * sizeof(GLfloat), (GLvoid *)((PHAT_CORDS + PHAT_TEX) * sizeof(GLfloat)));
        
        //setup texture ids
        /*
        glEnableVertexAttribArray( a_TextureIndexHandle);
        glVertexAttribPointer( a_TextureIndexHandle, 1, GL_FLOAT, GL_FALSE, PHAT_STRIDE * sizeof(GLfloat), (GLvoid *)((PHAT_CORDS + PHAT_TEX + PHAT_MXCORD) * sizeof(GLfloat)));
         */
        
        //generate index buffer
        glGenBuffers( 1, &_indexBuffer);
        glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
        
        
        //generate texture buffer
        /*
        glGenBuffers( 1, &_textureBuffer);
        glBindBuffer( GL_ARRAY_BUFFER, _textureBuffer);
        glBufferData( GL_ARRAY_BUFFER, sizeof(textureCords), textureCords, GL_STATIC_DRAW);
         */
        //enable texture stuff
        //glEnableVertexAttribArray(mTextureCoordinateHandle);
        //glVertexAttribPointer( mTextureCoordinateHandle, 2, GL_UNSIGNED_BYTE, GL_FALSE, 0, 0);
        
        glBindVertexArrayOES(0);
    }
    return self;
}

-(GLuint)findAndCompileShader:(NSString *)shaderName :(GLenum)shaderType
{
    
    NSString *shaderContent = shaderName;
    
    /*
    if(!shaderContent)
    {
        NSLog(@"-->Error loading shader: ");
    }
     */
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderContent UTF8String];
    GLint shaderStringLength = (GLint)[shaderContent length];
    
    glShaderSource( shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv( shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    /*
    if(compileSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetShaderInfoLog( shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *mesgString = [NSString stringWithUTF8String: messages];
        NSLog(@"Error in Shader Compiling: %@", mesgString);
    }
     */
    
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
    
    glUniformMatrix4fv( uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], numSprites, 0, mvpMatrix.m);
    //glUniformMatrix3fv( uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
    //glDrawArrays( GL_TRIANGLE_FAN, 0, 4);
    glDrawElements( GL_TRIANGLE_STRIP,  sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
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


//UNUSED IN THIS CASE
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

-(void)startBatchWithTex: (GLuint) texture
{
    [self startBatchWithTex: texture withR: 1 withG: 1 withB: 1 withA: 1];
}

-(void)startBatchWithTex: (GLuint) texture withR: (float) Red withG: (float) Green withB: (float) Blue withA: (float) Alpha
{
    numSprites = 0;
    lastTexture = texture;
    lastRed = Red;
    lastGreen = Green;
    lastBlue = Blue;
    lastAlpha = Alpha;
}

-(void)addToBatchTex: (GLuint) texture withMatrix: (GLKMatrix4)mvpMatrix
{
    [self addToBatchTex: texture withMatrix: mvpMatrix withR: 1 withG: 1 withB: 1 withA: 1];
}

-(void)addToBatchTex: (GLuint) textureThing withMatrix: (GLKMatrix4)mvpMatrix withR: (float) Red withG: (float) Green withB: (float) Blue withA: (float) Alpha
{
    
    if(lastTexture != textureThing || lastRed != Red || lastGreen != Green || lastBlue != Blue || lastAlpha != Alpha)
    {
        [self finishBatch: lastTexture];
        lastTexture = textureThing;
        lastRed = Red;
        lastGreen = Green;
        lastBlue = Blue;
        lastAlpha = Alpha;
    }
    
    char mvpCounter = 0;
    
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter++];
    matrixBuffer[storeIndex++] = mvpMatrix.m[mvpCounter];
    
    numSprites++;
    
    if(numSprites >= MAX_BATCH_SIZE)
        [self finishBatch: textureThing];
}

-(void)finishBatch
{
    [self finishBatch: lastTexture];
}

-(void)finishBatch: (GLuint) texture
{
    if(numSprites > 0)
    {
        //glBindVertexArrayOES(_vertexArray);
        glBindVertexArrayOES(_vertexArray);
        
        //Add program to OpenGL ES Environment
        glUseProgram(_program);
        
        colorsTex[0] = lastRed;
        colorsTex[1] = lastGreen;
        colorsTex[2] = lastBlue;
        colorsTex[3] = lastAlpha;
        
        glBindTexture( GL_TEXTURE_2D, texture);
        glUniform1i( mTextureUniformHandle, 0);
        
        glUniform4fv( mColorHandle, 1, colorsTex);
        
        glUniformMatrix4fv( uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], numSprites, 0, matrixBuffer);
        //glUniformMatrix3fv( uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
        
        //glDrawArrays( GL_TRIANGLE_FAN, 0, 4);
        //glDrawElements( GL_TRIANGLE_STRIP,  sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
        glDrawElements( GL_TRIANGLES, INDEX_STRIDE_SIZE * numSprites * sizeof(GLubyte), GL_UNSIGNED_BYTE, 0);
        
        numSprites = 0;
        storeIndex = 0;
    }
}


-(void)dealloc
{
    [super dealloc];
}

@end
