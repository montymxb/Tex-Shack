//
//  TexShack.m
//
//  Created by Benjamin Friedman (aka -mxb-) on 2/11/14.
//
//  This code is unlicensed and hereby for use at your disgression
//  You do not have to attribute any rights of this code to me, as i hold none.
//  However any notice as to the source of this code would not go unappreciated!
//  If you are interested in seeing this code in a running situation it is implemented
//  in the app 'Bit Shooter' for iOS (it is free).
//
//

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

-(void)drawCharactersCentered: (NSString *) c withX: (float) xx withY: (float) yy red: (float) red green: (float) green blue: (float) blue alpha: (float) alpha scale: (float) scalE matrix4: (GLKMatrix4) mvpMatrix matrixNormal: (GLKMatrix3) normalMatrix;

@end
