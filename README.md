Tex Shack
===================================
Bitmap Text Glyph Package


Tex Shack is a simple text glyph package.

Included:


•glyphs folder containing all .png's for each individual character currently supported

•src folder contains:


	-GLSquare class for drawing textured squares (glyphs)
	
	-TexShack class for converting string data into corresponding bitmap glyphs
	
	
•OpenGLTester.zip is a compressed Xcode project demonstrating how to implement TexShack, as well as it's features


	-All pertinant code for implementation can be found in the class 'ViewLe'

------------
 HOW TO USE
------------
1.Place both the GLSquare and TexShack class files in your project root.

2.Place all the .png's contained within glyphs/supportingFiles/ into (you guessed) your project's supportingFiles folder.
NOTE: This can make your supportingFiles folder quite, messy. Feel free to set up a subfolder instead, but you must make sure to
change the pathnames for each image loaded in TexShack.m as well as setting it up properly in your project.

3.Refer to the OpenGLTester project for proper implementation. It's fairly straightforward,
and this way I can demonstrate by example.

-If you're curious the OpenGLTester project is a modified version of the 'OpenGL Game' template available in Xcode (my Xcode is version 5.0.2).


---------------------
That's it!
Be aware this is not a final product, this is just something I've put together out of necessity, but figured it'd be worth sharing nonetheless.
If you're interested this code can be seen at work in the iOS app 'Bit Shooter'.


Also there is a small to do list consisting of:

	-Setting up draw call batching
	
	-Setting up a texture atlas (that is an awful lot of textures and images to be loading seperately)

When I get time I'll take care of these, however if you have experience with either of these techniques and are willing to lend a hand, contact me.

If you have any questions you can email me at mxb.atria@gmail.com.

Enjoy!