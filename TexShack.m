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

#import "TexShack.h"
#define COUNT 94

@implementation TexShack


const char supportedChars[] =
{
    '`', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    
    '0', '-', '=', '~', '!', '@', '#', '$', '^', '&',
    
    '*', '(', ')', '_', '+', 'q', 'w', 'e', 'r', 't',
    
    'y', 'u', 'i', 'o', 'p', '[', ']', '\\', 'Q', 'W',
    
    'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}',
    
    '|', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
    
    ';', '\'', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K',
    
    'L', ':', '"', 'z', 'x', 'c', 'v', 'b', 'n', 'm',
    
    ',', '.', '/', 'Z', 'X', 'C', 'V', 'B', 'N', 'M',
    
    '<', '>', '?', '%'
};

//cheap extra character storage
static NSArray *extraChars;
float extraCharsXShift[] =
{
    0.5, //§
    0.5  //ø
};

float extraCharsYShift[] =
{
    0, //§
    0  //ø
};

float extraCharsCompression[] =
{
    1, //§
    1  //ø
};

//97 , we are supporting ' ' space shift
// X SHIFT CORDS
float charXShift[] =
{
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5, 0.5, 0.5, 0.5, 0.5, 0.5,
    0.5//blank space shift
};

float charYShift[] =
{
    //0, 0.5, 1.7, 1.1, //1.3
    //1.4, 0.45, 0, 0,
    //0, -1, -1, -1,
    //-1, -1, -1, -1,
    //-1, -1
    
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0
};

float charCompression[] =
{
    //1, 0.8, 0.7, 0.76,
    //0.8, 0.9, 1, 1,
    //1, 1, 1, 1,
    //1, 1, 1, 1,
    //1, 1
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1
};

-(id)initWithScale: (float) scale screenWidth: (float) screenWidth screenHeight: (float) screenHeight
{
    self = [super init];
    if(self)
    {
        extraChars = [[NSArray alloc] initWithObjects: @"§", @"ø",nil];
        
        texSquare = [[GLSquare alloc] init: 0.03 : 0.03];
        curScale = scale;
        width = screenWidth;
        height = screenHeight;
        halfWidth = screenWidth * 0.5;
        halfHeight = screenHeight * 0.5;
        
        //set spacing relative to screen size
        short daReg = COUNT + 3;
        
        float scaleFactor = width * 0.04;
        genericSpacingRatio = 0.35 * scaleFactor;
        
        //set charXShift spacing
        charXShift[0] = 0.35;
        charXShift[1] = 0.35;
        charXShift[2] = 0.35;
        charXShift[3] = 0.35;
        charXShift[4] = 0.35;
        charXShift[5] = 0.35;
        charXShift[6] = 0.35;
        charXShift[7] = 0.35;
        charXShift[8] = 0.35;
        charXShift[9] = 0.35;
        
        charXShift[10] = 0.35;
        charXShift[11] = 0.35;
        charXShift[12] = 0.35;
        charXShift[13] = 0.35;
        charXShift[14] = 0.35;
        charXShift[15] = 0.35;
        charXShift[16] = 0.35;
        charXShift[17] = 0.35;
        charXShift[18] = 0.35;
        charXShift[19] = 0.35;
        
        charXShift[20] = 0.35;
        charXShift[21] = 0.35;
        charXShift[22] = 0.35;
        charXShift[23] = 0.35;
        charXShift[24] = 0.35;
        charXShift[25] = 0.35;
        charXShift[26] = 0.35;
        charXShift[27] = 0.35;
        charXShift[28] = 0.27;
        charXShift[29] = 0.27;
        
        charXShift[30] = 0.35;
        charXShift[31] = 0.35;
        charXShift[32] = 0.35;
        charXShift[33] = 0.35;
        charXShift[34] = 0.35;
        charXShift[35] = 0.35;
        charXShift[36] = 0.35;
        charXShift[37] = 0.35;
        charXShift[38] = 0.35;
        charXShift[39] = 0.35;
        
        charXShift[40] = 0.35;
        charXShift[41] = 0.35;
        charXShift[42] = 0.35;
        charXShift[43] = 0.35;
        charXShift[44] = 0.35;
        charXShift[45] = 0.35;
        charXShift[46] = 0.35;
        charXShift[47] = 0.35;
        charXShift[48] = 0.35;
        charXShift[49] = 0.35;
        
        charXShift[50] = 0.35;
        charXShift[51] = 0.35;
        charXShift[52] = 0.35;
        charXShift[53] = 0.35;
        charXShift[54] = 0.35;
        charXShift[55] = 0.35;
        charXShift[56] = 0.35;
        charXShift[57] = 0.35;
        charXShift[58] = 0.35;
        charXShift[59] = 0.35;
        
        charXShift[60] = 0.35;
        charXShift[61] = 0.35;
        charXShift[62] = 0.35;
        charXShift[63] = 0.35;
        charXShift[64] = 0.35;
        charXShift[65] = 0.35;
        charXShift[66] = 0.35;
        charXShift[67] = 0.35;
        charXShift[68] = 0.35;
        charXShift[69] = 0.35;
        
        charXShift[70] = 0.35;
        charXShift[71] = 0.35;
        charXShift[72] = 0.35;
        charXShift[73] = 0.35;
        charXShift[74] = 0.35;
        charXShift[75] = 0.35;
        charXShift[76] = 0.35;
        charXShift[77] = 0.35;
        charXShift[78] = 0.35;
        charXShift[79] = 0.35;
        
        charXShift[80] = 0.35;
        charXShift[81] = 0.35;
        charXShift[82] = 0.35;
        charXShift[83] = 0.35;
        charXShift[84] = 0.35;
        charXShift[85] = 0.35;
        charXShift[86] = 0.35;
        charXShift[87] = 0.35;
        charXShift[88] = 0.35;
        charXShift[89] = 0.35;
        
        charXShift[90] = 0.35;
        charXShift[91] = 0.35;
        charXShift[92] = 0.35;
        charXShift[93] = 0.35;
        charXShift[94] = 0.35;
        charXShift[95] = 0.35;
        charXShift[96] = 0.35;
        
        //set extra spacing
        extraCharsXShift[0] = 0.35;
        extraCharsXShift[1] = 0.35;
        
        for(short x = 0; x < daReg; x++)
        {
            //apply
            charXShift[x]*=scaleFactor;
        }
        
        short count = [extraChars count];
        for(char x = 0; x < count; x++)
        {
            //apply
            extraCharsXShift[x]*=scaleFactor;
        }
        
        texIds = (GLuint *)malloc((COUNT + 2) * sizeof(GLuint));
        
        isIPad = false;
        isRetina = false;
        
        
        //Test for iPad or iPhone
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            isIPad = true;
        else
            isIPad = false;
        
        //Test for Retina display or standard
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0))
            isRetina = true;
        else
            isRetina = false;
        
        CGImageRef img1 = [self createCGImageRef: @"grave.png"];
        CGImageRef img2 = [self createCGImageRef: @"1.png"];
        CGImageRef img3 = [self createCGImageRef: @"2.png"];
        CGImageRef img4 = [self createCGImageRef: @"3.png"];
        CGImageRef img5 = [self createCGImageRef: @"4.png"];
        CGImageRef img6 = [self createCGImageRef: @"5.png"];
        CGImageRef img7 = [self createCGImageRef: @"6.png"];
        CGImageRef img8 = [self createCGImageRef: @"7.png"];
        CGImageRef img9 = [self createCGImageRef: @"8.png"];
        CGImageRef img10 = [self createCGImageRef: @"9.png"];
        CGImageRef img11 = [self createCGImageRef: @"0.png"];
        CGImageRef img12 = [self createCGImageRef: @"-.png"];
        CGImageRef img13 = [self createCGImageRef: @"equals.png"];
        CGImageRef img14 = [self createCGImageRef: @"tilde.png"];
        CGImageRef img15 = [self createCGImageRef: @"!.png"];
        CGImageRef img16 = [self createCGImageRef: @"at.png"];
        CGImageRef img17 = [self createCGImageRef: @"pound.png"];
        CGImageRef img18 = [self createCGImageRef: @"$.png"];
        CGImageRef img19 = [self createCGImageRef: @"^.png"];
        CGImageRef img20 = [self createCGImageRef: @"and.png"];
        CGImageRef img21 = [self createCGImageRef: @"str.png"];
        CGImageRef img22 = [self createCGImageRef: @"ob.png"];
        CGImageRef img23 = [self createCGImageRef: @"cb.png"];
        CGImageRef img24 = [self createCGImageRef: @"_.png"];
        CGImageRef img25 = [self createCGImageRef: @"+.png"];
        CGImageRef img26 = [self createCGImageRef: @"q.png"];
        CGImageRef img27 = [self createCGImageRef: @"w.png"];
        CGImageRef img28 = [self createCGImageRef: @"e.png"];
        CGImageRef img29 = [self createCGImageRef: @"r.png"];
        CGImageRef img30 = [self createCGImageRef: @"t.png"];
        CGImageRef img31 = [self createCGImageRef: @"y.png"];
        CGImageRef img32 = [self createCGImageRef: @"u.png"];
        CGImageRef img33 = [self createCGImageRef: @"i.png"];
        CGImageRef img34 = [self createCGImageRef: @"o.png"];
        CGImageRef img35 = [self createCGImageRef: @"p.png"];
        CGImageRef img36 = [self createCGImageRef: @"sqrB.png"];
        CGImageRef img37 = [self createCGImageRef: @"sqrC.png"];
        CGImageRef img38 = [self createCGImageRef: @"slsh.png"];
        CGImageRef img39 = [self createCGImageRef: @"Qh.png"];
        CGImageRef img40 = [self createCGImageRef: @"Wh.png"];
        CGImageRef img41 = [self createCGImageRef: @"Eh.png"];
        CGImageRef img42 = [self createCGImageRef: @"Rh.png"];
        CGImageRef img43 = [self createCGImageRef: @"Th.png"];
        CGImageRef img44 = [self createCGImageRef: @"Yh.png"];
        CGImageRef img45 = [self createCGImageRef: @"Uh.png"];
        CGImageRef img46 = [self createCGImageRef: @"Ih.png"];
        CGImageRef img47 = [self createCGImageRef: @"Oh.png"];
        CGImageRef img48 = [self createCGImageRef: @"Ph.png"];
        CGImageRef img49 = [self createCGImageRef: @"crlA.png"];
        CGImageRef img50 = [self createCGImageRef: @"crlB.png"];
        CGImageRef img51 = [self createCGImageRef: @"pipe.png"];
        CGImageRef img52 = [self createCGImageRef: @"a.png"];
        CGImageRef img53 = [self createCGImageRef: @"s.png"];
        CGImageRef img54 = [self createCGImageRef: @"d.png"];
        CGImageRef img55 = [self createCGImageRef: @"f.png"];
        CGImageRef img56 = [self createCGImageRef: @"g.png"];
        CGImageRef img57 = [self createCGImageRef: @"h.png"];
        CGImageRef img58 = [self createCGImageRef: @"j.png"];
        CGImageRef img59 = [self createCGImageRef: @"k.png"];
        CGImageRef img60 = [self createCGImageRef: @"l.png"];
        CGImageRef img61 = [self createCGImageRef: @";.png"]; //<----LOOK HERE FOR ERRORS
        CGImageRef img62 = [self createCGImageRef: @"'.png"];
        CGImageRef img63 = [self createCGImageRef: @"Ah.png"];
        CGImageRef img64 = [self createCGImageRef: @"Sh.png"];
        CGImageRef img65 = [self createCGImageRef: @"Dh.png"];
        CGImageRef img66 = [self createCGImageRef: @"Fh.png"];
        CGImageRef img67 = [self createCGImageRef: @"Gh.png"];
        CGImageRef img68 = [self createCGImageRef: @"Hh.png"];
        CGImageRef img69 = [self createCGImageRef: @"Jh.png"];
        CGImageRef img70 = [self createCGImageRef: @"Kh.png"];
        CGImageRef img71 = [self createCGImageRef: @"Lh.png"];
        CGImageRef img72 = [self createCGImageRef: @"colon.png"];
        CGImageRef img73 = [self createCGImageRef: @"dq.png"];
        CGImageRef img74 = [self createCGImageRef: @"z.png"];
        CGImageRef img75 = [self createCGImageRef: @"x.png"];
        CGImageRef img76 = [self createCGImageRef: @"c.png"];
        CGImageRef img77 = [self createCGImageRef: @"v.png"];
        CGImageRef img78 = [self createCGImageRef: @"b.png"];
        CGImageRef img79 = [self createCGImageRef: @"n.png"];
        CGImageRef img80 = [self createCGImageRef: @"m.png"];
        CGImageRef img81 = [self createCGImageRef: @"comma.png"];
        CGImageRef img82 = [self createCGImageRef: @"dot.png"];
        CGImageRef img83 = [self createCGImageRef: @"fslsh.png"];
        CGImageRef img84 = [self createCGImageRef: @"Zh.png"];
        CGImageRef img85 = [self createCGImageRef: @"Xh.png"];
        CGImageRef img86 = [self createCGImageRef: @"Ch.png"];
        CGImageRef img87 = [self createCGImageRef: @"Vh.png"];
        CGImageRef img88 = [self createCGImageRef: @"Bh.png"];
        CGImageRef img89 = [self createCGImageRef: @"Nh.png"];
        CGImageRef img90 = [self createCGImageRef: @"Mh.png"];
        CGImageRef img91 = [self createCGImageRef: @"less.png"];
        CGImageRef img92 = [self createCGImageRef: @"grt.png"];
        CGImageRef img93 = [self createCGImageRef: @"quent.png"];
        CGImageRef img94 = [self createCGImageRef: @"prcnt.png"];
        CGImageRef extra1 = [self createCGImageRef: @"§.png"];
        CGImageRef extra2 = [self createCGImageRef: @"ø.png"];
        
        texIds[0] = [self generateTexture: img1];
        texIds[1] = [self generateTexture: img2];
        texIds[2] = [self generateTexture: img3];
        texIds[3] = [self generateTexture: img4];
        texIds[4] = [self generateTexture: img5];
        texIds[5] = [self generateTexture: img6];
        texIds[6] = [self generateTexture: img7];
        texIds[7] = [self generateTexture: img8];
        texIds[8] = [self generateTexture: img9];
        texIds[9] = [self generateTexture: img10];
        texIds[10] = [self generateTexture: img11];
        texIds[11] = [self generateTexture: img12];
        texIds[12] = [self generateTexture: img13];
        texIds[13] = [self generateTexture: img14];
        texIds[14] = [self generateTexture: img15];
        texIds[15] = [self generateTexture: img16];
        texIds[16] = [self generateTexture: img17];
        texIds[17] = [self generateTexture: img18];
        texIds[18] = [self generateTexture: img19];
        texIds[19] = [self generateTexture: img20];
        texIds[20] = [self generateTexture: img21];
        texIds[21] = [self generateTexture: img22];
        texIds[22] = [self generateTexture: img23];
        texIds[23] = [self generateTexture: img24];
        texIds[24] = [self generateTexture: img25];
        texIds[25] = [self generateTexture: img26];
        texIds[26] = [self generateTexture: img27];
        texIds[27] = [self generateTexture: img28];
        texIds[28] = [self generateTexture: img29];
        texIds[29] = [self generateTexture: img30];
        texIds[30] = [self generateTexture: img31];
        texIds[31] = [self generateTexture: img32];
        texIds[32] = [self generateTexture: img33];
        texIds[33] = [self generateTexture: img34];
        texIds[34] = [self generateTexture: img35];
        texIds[35] = [self generateTexture: img36];
        texIds[36] = [self generateTexture: img37];
        texIds[37] = [self generateTexture: img38];
        texIds[38] = [self generateTexture: img39];
        texIds[39] = [self generateTexture: img40];
        texIds[40] = [self generateTexture: img41];
        texIds[41] = [self generateTexture: img42];
        texIds[42] = [self generateTexture: img43];
        texIds[43] = [self generateTexture: img44];
        texIds[44] = [self generateTexture: img45];
        texIds[45] = [self generateTexture: img46];
        texIds[46] = [self generateTexture: img47];
        texIds[47] = [self generateTexture: img48];
        texIds[48] = [self generateTexture: img49];
        texIds[49] = [self generateTexture: img50];
        texIds[50] = [self generateTexture: img51];
        texIds[51] = [self generateTexture: img52];
        texIds[52] = [self generateTexture: img53];
        texIds[53] = [self generateTexture: img54];
        texIds[54] = [self generateTexture: img55];
        texIds[55] = [self generateTexture: img56];
        texIds[56] = [self generateTexture: img57];
        texIds[57] = [self generateTexture: img58];
        texIds[58] = [self generateTexture: img59];
        texIds[59] = [self generateTexture: img60];
        texIds[60] = [self generateTexture: img61];
        texIds[61] = [self generateTexture: img62];
        texIds[62] = [self generateTexture: img63];
        texIds[63] = [self generateTexture: img64];
        texIds[64] = [self generateTexture: img65];
        texIds[65] = [self generateTexture: img66];
        texIds[66] = [self generateTexture: img67];
        texIds[67] = [self generateTexture: img68];
        texIds[68] = [self generateTexture: img69];
        texIds[69] = [self generateTexture: img70];
        texIds[70] = [self generateTexture: img71];
        texIds[71] = [self generateTexture: img72];
        texIds[72] = [self generateTexture: img73];
        texIds[73] = [self generateTexture: img74];
        texIds[74] = [self generateTexture: img75];
        texIds[75] = [self generateTexture: img76];
        texIds[76] = [self generateTexture: img77];
        texIds[77] = [self generateTexture: img78];
        texIds[78] = [self generateTexture: img79];
        texIds[79] = [self generateTexture: img80];
        texIds[80] = [self generateTexture: img81];
        texIds[81] = [self generateTexture: img82];
        texIds[82] = [self generateTexture: img83];
        texIds[83] = [self generateTexture: img84];
        texIds[84] = [self generateTexture: img85];
        texIds[85] = [self generateTexture: img86];
        texIds[86] = [self generateTexture: img87];
        texIds[87] = [self generateTexture: img88];
        texIds[88] = [self generateTexture: img89];
        texIds[89] = [self generateTexture: img90];
        texIds[90] = [self generateTexture: img91];
        texIds[91] = [self generateTexture: img92];
        texIds[92] = [self generateTexture: img93];
        texIds[93] = [self generateTexture: img94];
        texIds[94] = [self generateTexture: extra1];
        texIds[95] = [self generateTexture: extra2];
        
        
        CGImageRelease(img1);
        CGImageRelease(img2);
        CGImageRelease(img3);
        CGImageRelease(img4);
        CGImageRelease(img5);
        CGImageRelease(img6);
        CGImageRelease(img7);
        CGImageRelease(img8);
        CGImageRelease(img9);
        CGImageRelease(img10);
        CGImageRelease(img11);
        CGImageRelease(img12);
        CGImageRelease(img13);
        CGImageRelease(img14);
        CGImageRelease(img15);
        CGImageRelease(img16);
        CGImageRelease(img17);
        CGImageRelease(img18);
        CGImageRelease(img19);
        CGImageRelease(img20);
        CGImageRelease(img21);
        CGImageRelease(img22);
        CGImageRelease(img23);
        CGImageRelease(img24);
        CGImageRelease(img25);
        CGImageRelease(img26);
        CGImageRelease(img27);
        CGImageRelease(img28);
        CGImageRelease(img29);
        CGImageRelease(img30);
        CGImageRelease(img31);
        CGImageRelease(img32);
        CGImageRelease(img33);
        CGImageRelease(img34);
        CGImageRelease(img35);
        CGImageRelease(img36);
        CGImageRelease(img37);
        CGImageRelease(img38);
        CGImageRelease(img39);
        CGImageRelease(img40);
        CGImageRelease(img41);
        CGImageRelease(img42);
        CGImageRelease(img43);
        CGImageRelease(img44);
        CGImageRelease(img45);
        CGImageRelease(img46);
        CGImageRelease(img47);
        CGImageRelease(img48);
        CGImageRelease(img49);
        CGImageRelease(img50);
        CGImageRelease(img51);
        CGImageRelease(img52);
        CGImageRelease(img53);
        CGImageRelease(img54);
        CGImageRelease(img55);
        CGImageRelease(img56);
        CGImageRelease(img57);
        CGImageRelease(img58);
        CGImageRelease(img59);
        CGImageRelease(img60);
        CGImageRelease(img61);
        CGImageRelease(img62);
        CGImageRelease(img63);
        CGImageRelease(img64);
        CGImageRelease(img65);
        CGImageRelease(img66);
        CGImageRelease(img67);
        CGImageRelease(img68);
        CGImageRelease(img69);
        CGImageRelease(img70);
        CGImageRelease(img71);
        CGImageRelease(img72);
        CGImageRelease(img73);
        CGImageRelease(img74);
        CGImageRelease(img75);
        CGImageRelease(img76);
        CGImageRelease(img77);
        CGImageRelease(img78);
        CGImageRelease(img79);
        CGImageRelease(img80);
        CGImageRelease(img81);
        CGImageRelease(img82);
        CGImageRelease(img83);
        CGImageRelease(img84);
        CGImageRelease(img85);
        CGImageRelease(img86);
        CGImageRelease(img87);
        CGImageRelease(img88);
        CGImageRelease(img89);
        CGImageRelease(img90);
        CGImageRelease(img91);
        CGImageRelease(img92);
        CGImageRelease(img93);
        CGImageRelease(img94);
        CGImageRelease(extra1);
        CGImageRelease(extra2);
        
    }
    return self;
}

-(GLuint)generateTexture:(CGImageRef)daImg
{
    GLKTextureInfo *aTexture = [GLKTextureLoader textureWithCGImage: daImg options: nil error: NULL];
    
    if(aTexture == nil)
        NSLog(@"aTexture has failed");
    
    return aTexture.name;
}

//convenience method for generating mass images here
-(CGImageRef)createCGImageRef:(NSString *)inputFile
{
    
    NSString *imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: inputFile];
    
    CGDataProviderRef provider = CGDataProviderCreateWithFilename( [imageFileName UTF8String] );
    
    CGImageRef img;
    
    //if RETINA display and IPAD we need to manually compress our image in order to represent the same screen size
    if( isRetina && isIPad )
    {
        
        CGImageRef tmpImg = CGImageCreateWithPNGDataProvider( provider, NULL , kCGInterpolationHigh , kCGRenderingIntentDefault);
        
        size_t halfWidth2 = CGImageGetWidth( tmpImg ) * 0.5;
        size_t halfHeight2 = CGImageGetHeight( tmpImg ) * 0.5;
        
        CGSize outputSize = CGSizeMake( halfWidth2, halfHeight2);
        
        CGContextRef outputContext = [self makeContextWithSize: outputSize];
        
        CGRect outputRect = CGRectMake( 0.0, 0.0,  halfWidth2, halfHeight2);
        
        CGContextDrawImage( outputContext, outputRect, tmpImg);
        
        CGImageRelease(tmpImg);
        
        img = CGBitmapContextCreateImage( outputContext);
        
        if( outputContext != NULL )
        {
            free(outputContext), outputContext = NULL;
        }
        
    }
    else
        img = CGImageCreateWithPNGDataProvider( provider, NULL , kCGInterpolationHigh , kCGRenderingIntentDefault);
    
    if( img == nil )
        NSLog(@"error thrown:%@", inputFile);
    
    CGDataProviderRelease(provider);
    
    //UIImage* sourceImage = [UIImage imageNamed: inputFile];
    //UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
    //                                            scale:sourceImage.scale orientation: UIImageOrientationUpMirrored];
    
    return img;
}

-(CGContextRef)makeContextWithSize:(CGSize)inSize
{
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    NULL,
                                                    inSize.width,
                                                    inSize.height,
                                                    8,
                                                    0,
                                                    CGColorSpaceCreateDeviceRGB(),
                                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    return contextRef;
}

-(GLuint)retrieveTextureWithCharacter:(char)c
{
    for(short x = 0; x < COUNT; x++)
        if( c == supportedChars[x])
            return texIds[x];
    
    return 0;
}

/*
-(void)drawCharacter: (char) c withX: (float) xx withY: (float) yy red: (float) red green: (float) green blue: (float) blue alpha: (float) alpha scale: (float) scalE matrix4: (GLKMatrix4) mvpMatrix matrixNormal: (GLKMatrix3) normalMatrix
{
    if(c != ' ')
    {
        BOOL isSupported = false;
        for(short x = 0; x < COUNT; x++)
            if( c == supportedChars[x])
            {
                isSupported = true;
                [texSquare startOPXwithTexture: texIds[0] withRed: red withGreen: green withBlue: blue andAlpha: alpha];
                [self drawSquare: texSquare atX: xx atY: yy + charYShift[x] withScale: scalE * charCompression[x] andMVP: mvpMatrix andNormal: normalMatrix];
                //[self drawSquare: texSquare withTexture: texIds[x] atX: xx atY: yy + charYShift[x] withR: red withG: green withB: blue withA: alpha withScale: scalE * charCompression[x] andMVP: mvpMatrix andNormal: normalMatrix];
                break;
            }
        
        if(!isSupported)
            [NSException raise:@"Unsupported char error" format:@"--->>char '%d' is not supported", c];
    }
}
*/

-(void)drawCharactersCentered:(NSString *)c withX:(float)xx withY:(float)yy red:(float)red green:(float)green blue:(float)blue alpha:(float)alpha scale:(float)scalE matrix4:(GLKMatrix4)mvpMatrix matrixNormal:(GLKMatrix3)normalMatrix
{
    short ourSize = [c length] - 1;
    xx+=(ourSize * genericSpacingRatio);
    
    [self drawCharacters: c withX: xx withY: yy red: red green: green blue: blue alpha: alpha scale: scalE matrix4: mvpMatrix matrixNormal:normalMatrix];
}

-(void)drawCharacters: (NSString *) c withX: (float) xx withY: (float) yy red: (float) red green: (float) green blue: (float) blue alpha: (float) alpha scale: (float) scalE matrix4: (GLKMatrix4) mvpMatrix matrixNormal: (GLKMatrix3) normalMatrix
{
    float printLocation = 0.0;
    short ourSize = [c length];
    short lastMark = 0;
    
    [texSquare startOPXwithTexture: texIds[0] withRed: red withGreen: green withBlue: blue andAlpha: alpha];
    
    NSString *tmp = @"";
    for(short x = 0; x < ourSize; x++)
    {
        tmp = [c substringWithRange: NSMakeRange( x, 1)];
        
        BOOL shouldGo = false;
        
        for(NSString *str in extraChars)
        {
            if([str isEqualToString: tmp])
            {
                shouldGo = true;
                break;
            }
        }
        
        if(shouldGo)
        {
            
            //prepare to do an inner loop
            NSString *inTmp = [c substringWithRange: NSMakeRange( lastMark, x - lastMark)];
            
            ////////
            BOOL canGo = true;
            
            for(NSString *str in extraChars)
            {
                if([str isEqualToString: inTmp])
                {
                    canGo = false;
                    break;
                }
            }
            
            if(canGo)
            {
                unichar *ourCharacters = (unichar *)malloc((x - lastMark) * sizeof(unichar));
                [inTmp getCharacters: ourCharacters];
                
                short xlm = x - lastMark;
                
                for(short xmark = 0; xmark < xlm; xmark++)
                {
                    BOOL isSupported = false;
                    for(short y = 0; y < COUNT; y++)
                    {
                        //check if blank and space accordingly
                        if( ourCharacters[xmark] == supportedChars[y])
                        {
                            isSupported = true;
                            [texSquare modifyTexture: texIds[y] withRed: -1 withGreen: -1 withBlue: -1 andAlpha: -1];
                            [self drawSquare: texSquare atX: xx - printLocation atY: yy + charYShift[y] * scalE withScale: scalE * charCompression[y] andMVP: mvpMatrix andNormal: normalMatrix];
                            //[self drawSquare: texSquare withTexture: texIds[y] atX: xx - printLocation atY: yy + charYShift[y] * scalE withR: red withG: green withB: blue withA: alpha withScale: scalE * charCompression[y] andMVP: mvpMatrix andNormal: normalMatrix];
                            printLocation+=(charXShift[y] * scalE);
                            break;
                        }
                        if( ourCharacters[xmark] == ' ')
                        {
                            isSupported = true;
                            printLocation+=charXShift[10];
                            break;
                        }
                    }
                    if(!isSupported)
                        [NSException raise:@"Unsupported char error" format:@"--->>char '%d' is not supported", ourCharacters[x]];
                }
                free(ourCharacters), ourCharacters = NULL;
                ////////
            }
            
            //update our permamarker
            lastMark = x + 1;
            
            //draw our 'special' character
            short nine4or5 = 0;
            short realnine5or4 = 94;
            
            for(NSString *str in extraChars)
            {
                if([str isEqualToString: tmp])
                    break;
                
                nine4or5++;
            }
            [texSquare modifyTexture: texIds[nine4or5 + realnine5or4] withRed: -1 withGreen: -1 withBlue: -1 andAlpha: -1];
            [self drawSquare: texSquare atX: xx - printLocation atY: yy + extraCharsYShift[nine4or5] * scalE withScale: scalE * extraCharsCompression[nine4or5] andMVP: mvpMatrix andNormal: normalMatrix];
            //[self drawSquare: texSquare withTexture: texIds[nine4or5 + realnine5or4] atX: xx - printLocation atY: yy + extraCharsYShift[nine4or5] * scalE withR: red withG: green withB: blue withA: alpha withScale: scalE * extraCharsCompression[nine4or5] andMVP: mvpMatrix andNormal: normalMatrix];
            
            printLocation+=(extraCharsXShift[nine4or5] * scalE);
        }
    }
    
    ourSize-=lastMark;
    
    if(lastMark > 0)
        c = [c substringWithRange: NSMakeRange( lastMark, [c length] - lastMark)];
    
    if(lastMark < [c length])
    {
        unichar *ourCharacters = (unichar *)malloc(ourSize * sizeof(unichar));
        [c getCharacters: ourCharacters];
        
        for(short x = 0; x < ourSize; x++)
        {
            BOOL isSupported = false;
            for(short y = 0; y < COUNT; y++)
            {
                //check if blank and space accordingly
                if( ourCharacters[x] == supportedChars[y])
                {
                    isSupported = true;
                    //[self drawSquare: texSquare withTexture: texIds[y] atX: xx - printLocation atY: yy + charYShift[y] * scalE withR: red withG: green withB: blue withA: alpha withScale: scalE * charCompression[y] andMVP: mvpMatrix andNormal: normalMatrix];
                    [texSquare modifyTexture: texIds[y] withRed: -1 withGreen: -1 withBlue: -1 andAlpha: -1];
                    [self drawSquare: texSquare atX: xx - printLocation atY: yy + charYShift[y] * scalE withScale: scalE * charCompression[y] andMVP: mvpMatrix andNormal: normalMatrix];
                    printLocation+=(charXShift[y] * scalE);
                    break;
                }
                if( ourCharacters[x] == ' ')
                {
                    isSupported = true;
                    printLocation+=charXShift[10];
                    break;
                }
            }

            if(!isSupported)
                [NSException raise:@"Unsupported char error" format:@"--->>char '%d' is not supported", ourCharacters[x]];
        }
        free(ourCharacters), ourCharacters = NULL;
    }
}

-(void)drawSquare:(GLSquare *)someSquare atX:(float)xCord atY:(float)yCord withScale: (float) scalE andMVP: (GLKMatrix4) mvpMatrix andNormal: (GLKMatrix3) normalMatrix
{
    
    float resultX = -(xCord - halfWidth) * 2.0;
    float resultY = -(yCord - halfHeight) * 2.0;
    
    if(scalE != 1)
    {
        GLKMatrix4 scaleMatrixF = GLKMatrix4MakeScale( scalE, scalE, 1);
        mvpMatrix = GLKMatrix4Multiply( scaleMatrixF, mvpMatrix);
        //resultX*=scalE;
        //resultY*=scalE;
    }
    
    GLKMatrix4 baseTransForward = GLKMatrix4MakeTranslation( resultX / width, resultY / height, 0.0f);
    mvpMatrix = GLKMatrix4Multiply( baseTransForward,  mvpMatrix);
    
    
    
    //[someSquare drawWithTexture: textureID withMatrix: mvpMatrix withNormal: normalMatrix withR: reD withG: greeN withB: bluE withA: alphA];
    [someSquare drawOPXwithMatrix: mvpMatrix withNormal: normalMatrix];
    
    
    GLKMatrix4 baseTransBack = GLKMatrix4MakeTranslation( -resultX / width, -resultY / height, 0.0f);
    mvpMatrix = GLKMatrix4Multiply( baseTransBack,  mvpMatrix);
    
    if(scalE != 1)
    {
        GLKMatrix4 scaleMatrixB = GLKMatrix4MakeScale( 1/scalE, 1/scalE, 1);
        mvpMatrix = GLKMatrix4Multiply( scaleMatrixB, mvpMatrix);
        //resultX/=scalE;
        //resultY/=scalE;
    }
}

-(void)dealloc
{
    if(extraChars != nil)
        [extraChars release];
    
    for(short x = 0; x <= COUNT + 2; x++)
        glDeleteTextures( 1, &texIds[x]);
    
    free(texIds), texIds = NULL;
    [texSquare release];
    [super dealloc];
}

@end
