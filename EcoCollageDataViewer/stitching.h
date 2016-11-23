//
//  stitching.h
//  CVOpenTemplate
//
//  Created by Washe on 05/01/2013.
//  Copyright (c) 2013 Foundry. All rights reserved.
//


//  EcoCollage 2015
//  Ryan Fogarty
//  Salvador Ariza

#ifndef CVOpenTemplate_Header_h
#define CVOpenTemplate_Header_h

#define MAX_POINTS 50000

void warp (cv::Mat src, cv::Mat dst, CvPoint corners[4]);

IplImage* thresh(IplImage* img, int colorCase);

int getCorners(IplImage * img, IplImage * original, CvPoint pts[],  int frameNumber, int colorCase, bool writeToFile);

int DetectAndDrawQuads(IplImage * img, IplImage * original, int frameNumber, int colorCase, bool writeToFile, int calibrate,char results[]);

void resetCoords();

void resetResults(char results[]);

void getHSV_Values(int input[]);

void setHSV_Values(int input[]);

int* getCoords();
int getCoordCount();

#endif
