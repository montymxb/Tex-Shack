//
//  GLSquare.h
//  Bit Shooter
//
//  Created by Benjamin Friedman on 1/31/14.
//  Copyright (c) 2014 -MXB0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLSquare : NSObject
{
    
    @private
    GLuint _program;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _textureArray;
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
