#define cimg_display 0
#include "CImg.h"
#include <iostream>
#include <cstdlib>
using namespace cimg_library;
using namespace std;

//This will dump the contents of an image file to the screen
void print_image (unsigned char *in, int width, int height) {
	for (int i = 0; i < width*height*3; i++)
		cout << (unsigned int)in[i] << endl;
}

#ifdef prewitt_filter
extern "C" {
	void prewitt(unsigned char *in,unsigned char *out, int width, int height);
}
#else
#endif

#ifdef pastel_filter
extern "C" {
	void pastel(unsigned char *in,unsigned char *out, int width, int height);
}
#else
#endif

#ifdef watermark_filter
extern "C" {
	void watermark(unsigned char *in,unsigned char *out, int width, int height);
}
#else
#endif

void usage() {
	cout << "Error: this program needs to be called with a command line parameter indicating what file to open.\n";
	cout << "For example, a.out kyoto.jpg\n";
	exit(1);
}

int main(int argc, char **argv) {
	if (argc != 2) usage(); //Check command line parameters

	//PHASE 1 - Load the image
	clock_t start_time = clock();
	CImg<unsigned char> image(argv[1]);
	CImg<unsigned char> darkimage(image.width(),image.height(),1,3,0);
	clock_t end_time = clock();
	cerr << "Image load time: " << double(end_time - start_time)/CLOCKS_PER_SEC << " secs\n";
	start_time = clock();

//Apply filter if defined
#ifdef prewitt_filter
	start_time = clock();
	prewitt(image,darkimage,image.width(),image.height());
	end_time = clock();
	cerr << "Prewitt Kernel Edge Detection Time: " << double(end_time - start_time)/CLOCKS_PER_SEC << " secs\n";
	image = darkimage;
#else
#endif

//Apply filter if defined
#ifdef pastel_filter
	start_time = clock();
	pastel(image,darkimage,image.width(),image.height());
	end_time = clock();
	cerr << "Pastel Time: " << double(end_time - start_time)/CLOCKS_PER_SEC << " secs\n";
	image = darkimage;
#else
#endif

//Apply filter if defined
#ifdef watermark_filter
	start_time = clock();
	watermark(image,darkimage,image.width(),image.height());
	end_time = clock();
	cerr << "Watermark Time: " << double(end_time - start_time)/CLOCKS_PER_SEC << " secs\n";
	image = darkimage;
#else
#endif

	//Image write time
	start_time = clock();
	
	//Save image as JPG or PNG, at 100%
	darkimage.save_jpeg("output.jpg",100);

	//Print image write time
	cerr << "Image write time: " << double(clock() - start_time)/CLOCKS_PER_SEC << " secs\n";
}
