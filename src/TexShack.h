//
//  TexShack.h
//  Bit Shooter
//  Created by Benjamin Wilson Friedman (-mxb-) from www.UphouseWorks.com
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
#import "GLSquare.h"

@interface TexShack : NSObject
{
    @private
    GLuint *texIds;
    BOOL isRetina;
    BOOL isIPad;
    float curScale;
    float width;
    float height;
    float halfWidth;
    float halfHeight;
    GLSquare *texSquare;
    float genericSpacingRatio;
}

-(id)initWithScale: (float) scale screenWidth: (float) screenWidth screenHeight: (float) screenHeight;

-(CGImageRef)createCGImageRef:(NSString *)inputFile;

-(CGContextRef)makeContextWithSize:(CGSize)inSize;

-(GLuint)generateTexture: (CGImageRef) daImg;

-(GLuint)retrieveTextureWithCharacter: (char) c;

//-(void)drawCharacter: (char) c withX: (float) xx withY: (float) yy red: (float) red green: (float) green blue: (float) blue alpha: (float) alpha scale: (float) scalE matrix4: (GLKMatrix4) mvpMatrix matrixNormal: (GLKMatrix3) normalMatrix;

-(void)drawCharacters: (NSString *) c withX: (float) xx withY: (float) yy red: (float) red green: (float) green blue: (float) blue alpha: (float) alpha scale: (float) scalE matrix4: (GLKMatrix4) mvpMatrix matrixNormal: (GLKMatrix3) normalMatrix;

-(void)drawSquare:(GLSquare *)someSquare atX:(float)xCord atY:(float)yCord withScale: (float) scalE andMVP: (GLKMatrix4) mvpMatrix andNormal: (GLKMatrix3) normalMatrix ;

-(void)drawCharactersReverseAlign: (NSString *) c withX: (float) xx withY: (float) yy red: (float) red green: (float) green blue: (float) blue alpha: (float) alpha scale: (float) scalE matrix4: (GLKMatrix4) mvpMatrix matrixNormal: (GLKMatrix3) normalMatrix;

-(void)adjustXSpaceScale: (float) newXScale;

@end
