/*
 * (c) Copyright 1993, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED 
 * Permission to use, copy, modify, and distribute this software for 
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that 
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission. 
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * OpenGL(TM) is a trademark of Silicon Graphics, Inc.
 */
/*  texgen.c
 *  This program draws a texture mapped teapot with 
 *  automatically generated texture coordinates.  The
 *  texture is rendered as stripes on the teapot.
 *
 * NEXTSTEP output provided by Pascal Thibaudeau 
 * pthibaud@frbdx11.cribx1.u-bordeaux.fr
 */
#import <dpsclient/wraps.h>
#import <appkit/Application.h>
#import <appkit/Window.h>
#import <appkit/Menu.h>
#import <appkit/View.h>
#import <appkit/color.h>
#import <appkit/NXBitmapImageRep.h>

#include <GL/gl.h>
#include <GL/glu.h>
#include <stdlib.h>
#include "GL/osmesa.h"

#define WIDTH 400
#define HEIGHT 400

#define	stripeImageWidth 16
GLubyte stripeImage[3*stripeImageWidth];

void makeStripeImage(void)
{
    int j;
    
    for (j = 0; j < stripeImageWidth; j++) {
	    stripeImage[3*j] = (j<=4) ? 255 : 0;
	    stripeImage[3*j+1] = (j>4) ? 255 : 0;
	    stripeImage[3*j+2] = 0;
    }
}

/* glTexGen stuff: */

GLfloat sgenparams[] = {1.0, 1.0, 1.0, 0.0};

static void render_image(void)
{
    glViewport(0, 0, WIDTH, HEIGHT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    if (WIDTH <= HEIGHT)
	glOrtho (-3.5, 3.5, -3.5*(GLfloat)HEIGHT/(GLfloat)WIDTH, 
	    3.5*(GLfloat)HEIGHT/(GLfloat)WIDTH, -3.5, 3.5);
    else
	glOrtho (-3.5*(GLfloat)WIDTH/(GLfloat)HEIGHT, 
	    3.5*(GLfloat)WIDTH/(GLfloat)HEIGHT, -3.5, 3.5, -3.5, 3.5);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
 
    glClearColor (0.0, 0.0, 0.0, 0.0);

    makeStripeImage();
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage1D(GL_TEXTURE_1D, 0, 3, stripeImageWidth, 0,
		 GL_RGB, GL_UNSIGNED_BYTE, stripeImage);

    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
    glTexGenfv(GL_S, GL_OBJECT_PLANE, sgenparams);

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_1D);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);
    glFrontFace(GL_CW);
    glCullFace(GL_BACK);
    glMaterialf (GL_FRONT, GL_SHININESS, 64.0);
 
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glPushMatrix ();
    glRotatef(-45.0, -180.0, -40.0, 1.0);
    auxSolidTeapot(3.0);
    glPopMatrix ();
    glFlush();
}

/*  Main Loop
 *  Open window with initial window size, title bar, 
 *  RGBA display mode, and handle input events.
 */
int main(int argc, char** argv)
{
   OSMesaContext ctx;
   void *buffer;
   id myWindow, myView, myMenu, image;
   char name[50];
   NXRect GR;
   NXPoint position;
   NXApp=[Application new];

   /* Create an RGBA-mode context */
   ctx = OSMesaCreateContext( GL_RGBA, NULL );

   /* Allocate the image buffer */
   buffer = malloc( WIDTH * HEIGHT * 4 );
   
   /* Bind the buffer to the context and make it current */
   OSMesaMakeCurrent( ctx, buffer, GL_UNSIGNED_BYTE, WIDTH, HEIGHT );

  image = [ [ NXBitmapImageRep alloc] 
		initData: buffer
		pixelsWide: WIDTH
		pixelsHigh: HEIGHT
		bitsPerSample: 8
		samplesPerPixel: 4
		hasAlpha: YES
		isPlanar: NO
		colorSpace: 2
		bytesPerRow: WIDTH*4
		bitsPerPixel: 32]; 

  NXSetRect(&GR,100,100,WIDTH,HEIGHT);

  myWindow = [ [ Window alloc]
			initContent: &GR
			style: NX_TITLEDSTYLE
			backing: NX_BUFFERED
			buttonMask: NX_MINIATURIZEBUTTONMASK
			defer: NO];

  sprintf(name, "OpenGL Graphic Rectangle %d", getpid());

   myView = [ [ View alloc] initFrame:&GR];
   [myView  setOpaque: NO];
   [myView setDrawOrigin: -WIDTH: -HEIGHT];
   [myView rotate: 180.0];

   myMenu = [ [ Menu alloc] initTitle: "NeXT-Mesa"];
   [myMenu addItem: "Quit" action: @selector(terminate:) keyEquivalent: 'q'];
   [myMenu sizeToFit];

   [myWindow setTitle: name];
   [myWindow display];
   [myWindow setContentView: myView];
   [myWindow makeKeyAndOrderFront: nil];

   [NXApp setMainMenu: myMenu];

   [myView lockFocus];

   /* here is the Mesa call */
   render_image();

   [image draw];
   [image free];

   [myWindow flushWindow];
   [myView unlockFocus];

   /* free the image buffer */
   free( buffer );
 
   /* destroy the context */
   OSMesaDestroyContext( ctx );

   [NXApp run];
   [NXApp free];

   return 0;

      }



