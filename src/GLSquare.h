//
//  GLSquare.h
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

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLSquare : NSObject
{
    
    @private
    GLuint _program;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _textureBuffer;
    GLuint mColorHandle;
    GLuint mTextureUniformHandle;
    GLuint mTextureCoordinateHandle;
    GLuint _indexBuffer;
    
}

-(id)init: (float) width : (float) height;

-(GLuint)findAndCompileShader: (NSString *) shaderName : (GLenum) shaderType;

-(void)drawWithTexture: (GLuint) texture withMatrix: (GLKMatrix4) mvpMatrix withNormal: (GLKMatrix3) normalMatrix;

-(void)drawWithTexture: (GLuint) texture withMatrix: (GLKMatrix4) mvpMatrix withNormal: (GLKMatrix3) normalMatrix withR: (float) R withG: (float) G withB: (float) B withA: (float) alpha;

-(void)startOPX : (GLuint) texture;

-(void)modifyTexture : (GLuint) texture;

-(void)drawOPXwithMatrix:(GLKMatrix4)mvpMatrix withNormal:(GLKMatrix3)normalMatrix;

-(void)startOPXwithTexture:(GLuint)texture withRed: (float) reD withGreen: (float) greeN withBlue: (float) bluE andAlpha: (float) alphA;

-(void)modifyTexture: (GLuint) texture withRed: (float) reD withGreen: (float) greeN withBlue: (float) bluE andAlpha: (float) alphA;

@end
