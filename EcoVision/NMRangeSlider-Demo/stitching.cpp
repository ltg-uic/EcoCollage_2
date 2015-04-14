/*M///////////////////////////////////////////////////////////////////////////////////////
//
//  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
//
//  By downloading, copying, installing or using the software you agree to this license.
//  If you do not agree to this license, do not download, install,
//  copy or use the software.
//
//
//                          License Agreement
//                For Open Source Computer Vision Library
//
// Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
// Copyright (C) 2009, Willow Garage Inc., all rights reserved.
// Third party copyrights are property of their respective owners.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//   * Redistribution's of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//   * Redistribution's in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//   * The name of the copyright holders may not be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// This software is provided by the copyright holders and contributors "as is" and
// any express or implied warranties, including, but not limited to, the implied
// warranties of merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the Intel Corporation or contributors be liable for any direct,
// indirect, incidental, special, exemplary, or consequential damages
// (including, but not limited to, procurement of substitute goods or services;
// loss of use, data, or profits; or business interruption) however caused
// and on any theory of liability, whether in contract, strict liability,
// or tort (including negligence or otherwise) arising in any way out of
// the use of this software, even if advised of the possibility of such damage.
//
//
 
 // this is simple_stitcher.cpp sample distributed with openCV source.
 //adapted by Washe/Foundry for iOS
 // most of the code is redundant, retained for reference only
 M*/


//  EcoCollage 2015
//  Ryan Fogarty
//  Salvador Ariza

struct COORDS {
    int x;
    int y;
};


#include "stitching.h"
#include <iostream>
#include <fstream>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/stitching/stitcher.hpp"
#include <stdio.h>


using namespace std;
using namespace cv;

bool try_use_gpu = false;
vector<Mat> imgs;
string result_name = "result.jpg";

//int h[] = {10, 50, 50, 80, 200, 255, 80, 140, 100, 175, 255, 255, 90, 40, 120, 110, 100, 225, 0, 30, 50, 15, 220, 210, 15, 35, 35, 90, 200, 130};

int hsv[] = {10, 80, 50, 200, 50, 255, 80, 175, 140, 255, 100, 255, 90, 110, 40, 100, 120, 225, 0, 15, 30, 220, 50, 210, 15, 90, 35, 200, 35, 130};


#define TL_MARKER 818
#define TR_MARKER 839
#define BL_MARKER 4
#define BR_MARKER 339



void getHSV_Values(int input[]) {
    int i;
    
    for(i = 0; i < 30; i++) {
        input[i] = hsv[i];
    }
}

void setHSV_Values(int input[]) {
    int i;
    
    for(i = 0; i < 30; i++) {
        hsv[i] = input[i];
    }
}


void warp (cv::Mat src, cv::Mat dst, CvPoint corners[4]) {
    
    // Input Quadilateral or Image plane coordinates
    Point2f inputPoints[4];
    // Output Quadilateral or World plane coordinates
    Point2f outputPoints[4];
    
    
    // Lambda Matrix
    Mat lambda( 2, 4, CV_32FC1 );
    
    // Set the lambda matrix the same type and size as input
    lambda = Mat::zeros( src.rows, src.cols, src.type() );
    
    
    // The 4 points of the map, starting from top left corner and moving clockwise
    inputPoints[0] = Point2f( corners[0].x, corners[0].y);
    inputPoints[1] = Point2f( corners[1].x, corners[1].y);
    inputPoints[2] = Point2f( corners[2].x, corners[2].y);
    inputPoints[3] = Point2f( corners[3].x, corners[3].y);
    // The 4 points where the mapping is to be done , from top-left in clockwise order
    outputPoints[0] = Point2f( 0, 0 );
    outputPoints[1] = Point2f( dst.cols-1, 0);
    outputPoints[2] = Point2f( dst.cols-1, dst.rows-1);
    outputPoints[3] = Point2f( 0, dst.rows-1  );
    
    
    // Get the Perspective Transform Matrix i.e. lambda
    lambda = getPerspectiveTransform( inputPoints, outputPoints );
    // Apply the Perspective Transform just found to the src image
    cv::warpPerspective(src,dst,lambda,dst.size() );

}

COORDS coords[200];
int coordCount = 0;
int resultCount = 0;
static int stringCount = 0;

//added two boolean parameters and added a int return statement to return the number of each piece
int DetectAndDrawQuads(IplImage * img, IplImage * original, int frameNumber, int colorCase, bool writeToFile, int calibrate,char results[])
{
    CvSeq * contours;
    CvSeq * result;
    CvMemStorage * storage = cvCreateMemStorage(0);
    IplImage * temp = cvCloneImage(img);
    IplImage * oriTemp = cvCloneImage(original);
    

    
    //	symbolList[frameNumber].clear();
    int count = 0;
    int numPieces = 0;
    if(colorCase == 0) {
        resetResults(results);
    }
    cvFindContours(temp, storage, &contours, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0));
    while(contours)
    {
        
        result = cvApproxPoly(contours, sizeof(CvContour), storage, CV_POLY_APPROX_DP, cvContourPerimeter(contours) * 0.02, 0);
        if(result->total>=4 && fabs(cvContourArea(result, CV_WHOLE_SEQ)) > 10)
        {
            
            CvPoint * pt[result->total];
            for(int i=0;i < result->total; i++)
                pt[i] = (CvPoint * )cvGetSeqElem(result, i);
            int minX = temp->width;
            int minY = temp->height;
            int maxX = 0;
            int maxY = 0;
            for(int j = 0; j < result->total; j++){
                if(pt[j]->x < minX) minX = pt[j]->x;
                if(pt[j]->x > maxX) maxX = pt[j]->x;
                if(pt[j]->y < minY) minY = pt[j]->y;
                if(pt[j]->y > maxY) maxY = pt[j]->y;
            }
            
            int w = abs(maxX-minX);
            int h = abs(maxY-minY);
            if( w > 10 & h > 10){
                cvResetImageROI(img);
                char *windowName = new char[20];
                sprintf(windowName, "Detected Object %d - %d ", colorCase, count);
                
                cvResetImageROI(oriTemp);
                
                count++;
                cvSetImageROI(oriTemp, cvRect(minX, minY, w, h));
                
                float xVal= ((maxX+minX) / 2.0) * (23.0/temp->width);
                float yVal = ((maxY+ minY)/ 2.0) * (25.0/temp->height);
                int x = ceil((maxX+minX) / 2.0) * (23.0/temp->width);
                int y = ceil((maxY+ minY)/ 2.0) * (25.0/temp->height);
                
                
                
                bool coordRepeat = 0;
                
                // check for repeats of coordinates to prevent logging the same piece twice
                int i;
                for(i = 0; i < coordCount; i++) {
                    if(coords[i].x == x && coords[i].y == y) {
                        coordRepeat = 1;
                    }
                }

                coords[coordCount].x = x;
                coords[coordCount].y = y;
                coordCount++;

                
                if(coordRepeat == 0) {
                    numPieces++;
                    if(calibrate == 1){
                        //cvDestroyWindow(windowName);
                        //cvNamedWindow(windowName);
                        //cvShowImage(windowName, oriTemp);
                        
                        printf("%d %f %f\n", colorCase, xVal, yVal);
                        printf("%d %d \n", x, y);
                    }
                    
                    /*
                    if((x>= 0 && x <= 22) && (y>=0 && y<= 24)){
                        if(writeToFile)
                            fprintf(outputRecord, "%d %d %d\n", colorCase, x, 24-y);
                    }
                     */
                    //fprintf(trialFile, "%d %d %d\n", colorCase, x, 24-y);
                    
                    
                    
                    char str[] = "%d %d %d ";
                    char temp[2000];
                    sprintf(temp, str, colorCase, x, 24-y);
                    
                    
                    int i = 0;
                    for(i = 0; temp[i] != '\0'; i++) {
                        results[stringCount] = temp[i];
                        stringCount++;
                    }
                    
                    // printf("%d\n", stringCount);
                    
                    // print output to console
                    // printf("%d %d %d\n", colorCase, x, 24-y);
                }
                
               //printf("%d %d\n", coords[coordCount-1].x, coords[coordCount-1].y);
            }
            
        }
        contours = contours -> h_next;
    }
    
    cvReleaseImage(&temp);
    cvReleaseMemStorage(&storage);
    return numPieces;
}

void resetResults(char results[]) {
    int i = 0;
    while (results[i] != '\0') {
        results[i++] = '\0';
    }
    stringCount = 0;
}

void resetCoords() {
    int i;
    for(i = 0; i < coordCount; i++) {
        coords[i].x = 0;
        coords[i].y = 0;
    }
    
    coordCount = 0;
}


IplImage* thresh(IplImage* img,int colorCase){
    
    //Convert the image into an HSV image
    IplImage * imgHSV = cvCreateImage(cvGetSize(img), 8, 3);
    cvCvtColor(img, imgHSV, CV_BGR2HSV);
    
    
    //New image that will hold the thresholded image
    IplImage * imgThreshed = cvCreateImage(cvGetSize(img), 8, 1);
    
    
    //*******************************Projector On***************************************//
    //**	white
    //		cvInRangeS(imgHSV, cvScalar(0, 0, 0), cvScalar(20, 55, 255), imgThreshed);
    //**	white on black
    //		cvInRangeS(imgHSV, cvScalar(0, 0, 200), cvScalar(360, 40, 255), imgThreshed);
    //**	red
    //		cvInRangeS(imgHSV, cvScalar(0, 100, 50), cvScalar(15, 200, 150), imgThreshed);
    //**	orange
    //		cvInRangeS(imgHSV, cvScalar(10, 100, 0), cvScalar(30, 250, 175), imgThreshed);
    //**	green
    //		cvInRangeS(imgHSV, cvScalar(30, 50, 50), cvScalar(90, 200, 130), imgThreshed);
    //**	wood
    //		cvInRangeS(imgHSV, cvScalar(10, 50, 120), cvScalar(30, 100, 165), imgThreshed);
    //**	blue
    //		cvInRangeS(imgHSV, cvScalar(90, 0, 40), cvScalar(150, 90, 130), imgThreshed);
    //**	black
    //		cvInRangeS(imgHSV, cvScalar(0, 0, 0), cvScalar(180, 190, 90), imgThreshed);
    
    
    //*******************************Projector Off***************************************//
    //**	black on white
    //		cvInRangeS(imgHSV, cvScalar(0, 0, 0), cvScalar(20, 55, 255), imgThreshed);
    //**	red
    //		cvInRangeS(imgHSV, cvScalar(0, 100, 50), cvScalar(15, 255, 130), imgThreshed);
    //**	orange
    //		cvInRangeS(imgHSV, cvScalar(5, 100, 60), cvScalar(30, 225, 130), imgThreshed);
    //**	green
    //		cvInRangeS(imgHSV, cvScalar(40, 75, 50), cvScalar(90, 255, 150), imgThreshed);
    //**	wood
    //		cvInRangeS(imgHSV, cvScalar(15, 60, 90), cvScalar(60, 200, 200), imgThreshed);
    //**	blue
    //		cvInRangeS(imgHSV, cvScalar(90, 90, 20), cvScalar(150, 200, 90), imgThreshed);
    //**	black
    //		cvInRangeS(imgHSV, cvScalar(0, 0, 0), cvScalar(100, 200, 30), imgThreshed);
    //**	silicon blue
    //		cvInRangeS(imgHSV, cvScalar(90, 100, 50), cvScalar(150, 220, 120), imgThreshed);
    
    //*************NEW******************Projector Off*********************COLORS******************//
    //**	red
    //		cvInRangeS(imgHSV, cvScalar(0, 60, 60), cvScalar(15, 200, 255), imgThreshed);
    //**	blue
    //      cvInRangeS(imgHSV, cvScalar(90, 40, 50), cvScalar(150, 255, 200), imgThreshed);
    //**	orange
    //		cvInRangeS(imgHSV, cvScalar(0, 60, 50), cvScalar(30, 190, 150), imgThreshed);
    //**	green
    //		cvInRangeS(imgHSV, cvScalar(40, 75, 50), cvScalar(90, 255, 150), imgThreshed);
    //**	Yellow
    //		cvInRangeS(imgHSV, cvScalar(5, 40, 60), cvScalar(40, 225, 225), imgThreshed);
    //**	gray
    //		cvInRangeS(imgHSV, cvScalar(90, 50, 0), cvScalar(100, 255, 255), imgThreshed);
    

    switch(colorCase){
        case 0: // green
            cvInRangeS(imgHSV, cvScalar(hsv[0], hsv[2], hsv[4]), cvScalar(hsv[1], hsv[3], hsv[5]), imgThreshed);
            break;
        case 1: // red
            cvInRangeS(imgHSV, cvScalar(hsv[6], hsv[8], hsv[10]), cvScalar(hsv[7], hsv[9], hsv[11]), imgThreshed);
            break;
        case 2: // brown/wood
            cvInRangeS(imgHSV, cvScalar(hsv[12], hsv[14], hsv[16]), cvScalar(hsv[13], hsv[15], hsv[17]), imgThreshed);
            break;
        case 3: // blue
            cvInRangeS(imgHSV, cvScalar(hsv[18], hsv[20], hsv[22]), cvScalar(hsv[19], hsv[21], hsv[23]), imgThreshed);
            break;
        case 4: // dark green (corner markers)
            cvInRangeS(imgHSV, cvScalar(hsv[24], hsv[26], hsv[28]), cvScalar(hsv[25], hsv[27], hsv[29]), imgThreshed);
            break;
        default:
            break;
    }
    
    
    //Release the temp HSV image and return this thresholded image
    cvReleaseImage(&imgHSV);
    return imgThreshed;
}


int getCorners(IplImage * img, IplImage * original, CvPoint pts[], int frameNumber, int colorCase, bool writeToFile)
{
    CvSeq * contours;
    CvSeq * result;
    CvMemStorage * storage = cvCreateMemStorage(0);
    IplImage * temp = cvCloneImage(img);

    // keeping track of current index in CvPoint* pts[]
    int ptsIndex = 0;
    cvFindContours(temp, storage, &contours, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0));
    
    while(contours)
    {
        
        result = cvApproxPoly(contours, sizeof(CvContour), storage, CV_POLY_APPROX_DP, cvContourPerimeter(contours) * 0.02, 0);
        
        if(result->total>=3 && fabs(cvContourArea(result, CV_WHOLE_SEQ)) > 40)
        {
            
            CvPoint * pt[result->total];
            for(int i=0;i < result->total; i++) {
                pt[i] = (CvPoint * )cvGetSeqElem(result, i);
                CvPoint tempPoint;
                tempPoint.x = pt[i]->x;
                tempPoint.y = pt[i]->y;
                pts[ptsIndex] = tempPoint;
                ptsIndex++;
            }
        }
        contours = contours -> h_next;
    }
    
    cvReleaseImage(&temp);
    cvReleaseMemStorage(&storage);
    return ptsIndex;
}

