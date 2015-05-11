//
//  CVWrapper.m
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//


//  EcoCollage 2015
//  Ryan Fogarty
//  Salvador Ariza

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
#import "stitching.h"
#import <math.h>



using namespace cv;

int segIndex = 0;
UIImage* currentImage = nil;
UIImage* currentThreshedImage = nil;
int a[8];

@implementation CVWrapper


+ (void) setSegmentIndex:(int)index {
    segIndex = index;
}

+ (int) getSegmentIndex {
    return segIndex;
}

+ (UIImage*) getCurrentThreshedImage {
    return currentThreshedImage;
}

+ (void) setCurrentThreshedImage:(UIImage*) img {
    currentThreshedImage = img;
}

+ (UIImage*) getCurrentImage {
    return currentImage;
}

+ (void) setCurrentImage:(UIImage*) img{
    currentImage = img;
}

+ (void) getHSV_Values:(int [])input {
    getHSV_Values(input);
}

+ (void) setHSV_Values:(int [])input {
    setHSV_Values(input);
}


+ (int) detectContours:(UIImage *)src corners:(int[]) cornersGlobal
{
    
    // needed to make new image because next comment was causing conversion error
    UIImage *new_src = nil;
    CGSize targetSize = src.size;
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [src drawInRect:thumbnailRect];
    
    
    new_src = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    // needed to make new image (new_src) because this was causing a conversion error
    cv::Mat mat_src = [new_src CVMat3];
    
    IplImage copy_src = mat_src;
    IplImage* ipl_src = &copy_src;
    
    
    
    // convert to black and white image for cvFindContours
    // used in stitching.cpp function getCorners
    
    cv::Mat bwImage;
    cv::cvtColor(mat_src, bwImage, CV_RGB2GRAY);
    
    
    copy_src = bwImage;
    ipl_src = &copy_src;
    
    IplImage* ipl_dst = ipl_src;

    // potential error for memory / seg fault
    CvPoint pts[MAX_POINTS];
    
    
    
    int ptsNumber = getCorners(ipl_src, ipl_dst, pts, 5, 4, 0);
    
    printf("Number of CvPoints detected: %d\n", ptsNumber);
    
    int i = 0;
    
    /*
    //ERRORS OCCURRING
    //pts WITHOUT X OR Y VALUES FROM getCorners
    //EVEN THOUGH EACH PT SHOULD HAVE BEEN POPULATED WITHIN THE FUNCTION
    while(i < ptsNumber) {
        int x = pts[i].x;
        int y = pts[i].y;
        printf("x: %d y: %d\n", x, y);
        i++;
    }
    */
    
    int src_width = src.size.width - 1;
    int src_height = src.size.height - 1;
    
    
    // 0 1
    // 3 2
    CvPoint corners[4];
    corners[0] = cvPoint(0, 0);
    corners[1] = cvPoint(src_width, 0);
    corners[2] = cvPoint(src_width, src_height);
    corners[3] = cvPoint(0, src_height);
    
    // 0 1
    // 3 2
    CvPoint boardCorners[4];
    boardCorners[0] = cvPoint(src_width, src_height);
    boardCorners[1] = cvPoint(0, src_height);
    boardCorners[2] = cvPoint(0, 0);
    boardCorners[3] = cvPoint(src_width, 0);
    
    
    double curr_dist0 = 10000;
    double curr_dist1 = 10000;
    double curr_dist2 = 10000;
    double curr_dist3 = 10000;
    
    
    // description of the following code (until the end of this function):
    // find amongst all the points within the contours the points closest to each corner of the image
    // these points are the corners of the board and will be used in the perspective warp
    // the following is how corners are set up. 0 is top left and then it moves clockwise
    // 0-------1
    // |       |
    // |       |
    // |       |
    // |       |
    // 3-------2
    //
    for(i = 0; i < ptsNumber; i++) {
        //if (pts[i].x > 20 && pts[i].y > 20 && pts[i].x < (src_width - 20) && pts[i].y < (src_height - 20)) {
        
            double dx0 = (double)(abs(corners[0].x - pts[i].x));
            double dy0 = (double)(abs(corners[0].y - pts[i].y));
            double dx1 = (double)(abs(corners[1].x - pts[i].x));
            double dy1 = (double)(abs(corners[1].y - pts[i].y));
            double dx2 = (double)(abs(corners[2].x - pts[i].x));
            double dy2 = (double)(abs(corners[2].y - pts[i].y));
            double dx3 = (double)(abs(corners[3].x - pts[i].x));
            double dy3 = (double)(abs(corners[3].y - pts[i].y));
            
            double dist0 = sqrt((dx0 * dx0) + (dy0 * dy0));
            double dist1 = sqrt((dx1 * dx1) + (dy1 * dy1));
            double dist2 = sqrt((dx2 * dx2) + (dy2 * dy2));
            double dist3 = sqrt((dx3 * dx3) + (dy3 * dy3));
            
            
            if(dist0 < curr_dist0) {
                boardCorners[0] = pts[i];
                curr_dist0 = dist0;
            }
            if(dist1 < curr_dist1) {
                boardCorners[1] = pts[i];
                curr_dist1 = dist1;
            }
            if(dist2 < curr_dist2) {
                boardCorners[2] = pts[i];
                curr_dist2 = dist2;
            }
            if(dist3 < curr_dist3) {
                boardCorners[3] = pts[i];
                curr_dist3 = dist3;
            }
        //}
    }
    

    // following code tries to force a crop of only the map
    // (get rid of borders such as corner markers)
    // length between top left and top right corners
    int xBetween0_1 = abs(boardCorners[1].x - boardCorners[0].x);
    // length between bottom left and bottom right corners
    int xBetween2_3 = abs(boardCorners[2].x - boardCorners[3].x);
    // length between top left and bottom left corners
    int yBetween0_3 = abs(boardCorners[3].y - boardCorners[0].y);
    // length between bottom right and top right corners
    int yBetween1_2 = abs(boardCorners[2].y - boardCorners[1].y);
    
    
    // original divisors: 24, 24, 40, 40
    int xCrop0_1 = xBetween0_1 / 14;
    int xCrop2_3 = xBetween2_3 / 9;
    int yCrop0_3 = yBetween0_3 / 8;
    int yCrop1_2 = yBetween1_2 / 8;
    
    // crop out the corner markers from the image of the map
    boardCorners[0].x += xCrop0_1;
    boardCorners[0].y += yCrop0_3 / 3;
    boardCorners[1].x -= xCrop0_1;
    boardCorners[1].y += yCrop1_2 / 3;
    boardCorners[2].x -= xCrop2_3;
    boardCorners[2].y -= yCrop1_2;
    boardCorners[3].x += xCrop2_3;
    boardCorners[3].y -= yCrop0_3;
    

    /*
    // extend crop 10 pixels above top left corner
    if(boardCorners[0].y > 10 ) {
        boardCorners[0].y -= 10;
    }
    */
    
    a[0] = boardCorners[0].x;
    a[1] = boardCorners[0].y;
    a[2] = boardCorners[1].x;
    a[3] = boardCorners[1].y;
    a[4] = boardCorners[2].x;
    a[5] = boardCorners[2].y;
    a[6] = boardCorners[3].x;
    a[7] = boardCorners[3].y;
    
    
    
    cornersGlobal[0] = boardCorners[0].x;
    cornersGlobal[1] = boardCorners[0].y;
    cornersGlobal[2] = boardCorners[1].x;
    cornersGlobal[3] = boardCorners[1].y;
    cornersGlobal[4] = boardCorners[2].x;
    cornersGlobal[5] = boardCorners[2].y;
    cornersGlobal[6] = boardCorners[3].x;
    cornersGlobal[7] = boardCorners[3].y;
    

    
    // 0  1
    // 3  2
    
    // width between bottom two corners
    int width = boardCorners[2].x - boardCorners[3].x;
    
    for (i = 0; i < 4; i++) {
        printf("Point %d: x: %d y:%d\n", i, boardCorners[i].x, boardCorners[i].y);
    }
    
    printf("width: %d\n", width);
    return width;
}


+(int) analysis:(UIImage *)src studyNumber:(int)studyNumber trialNumber:(int) trialNumber results:(char *)results{
    
    // Defining Constant Variables for accessing the database
    #define SERVER "localhost"
    #define USER "root"
    #define PASSWORD ""
    #define DATABASE "flag"
    

    printf("Study Number %d\nTrial Number %d\n", studyNumber, trialNumber);
    
    
    int				calibrate = 0;

    
    int redPieces = 0;
    int bluePieces = 0;
    int greenPieces = 0;
    int brownPieces = 0;
    
    bool writeToFile = false;
    

    // making mat and ipl images out of src (UIImage)
    cv::Mat mat_src = [src CVMat3];
    IplImage copy = mat_src;
    IplImage *ipl_src = &copy;
    
    printf("---- PRINTING THE MARKER LOCATIONS ----\n");
    printf("---- FORMAT: colorCase, x, y ----\n"); // actual printing takes place in stitching.cpp -> DetectAndDrawQuads
    
    for(int i=0; i < 4; i++){
        
        IplImage * imgThresh = thresh(ipl_src, i);
        if(calibrate){
            char *windowName = new char[20];
            sprintf(windowName, "Threshholded Image for color %d ", i);
            cvDestroyWindow(windowName);
            cvNamedWindow(windowName);
            cvShowImage(windowName, imgThresh);
        }
        //cvResizeWindow(windowName , imgGreenThresh->width/2, imgGreenThresh->height/2);
        int result = DetectAndDrawQuads(imgThresh, ipl_src, 0, i, writeToFile, calibrate, results);
        
        switch(i){
            case 0:
                greenPieces = result;
                printf("Processed green pieces: %d\n", greenPieces);
                break;
            case 1:
                redPieces = result;
                printf("Processed red pieces: %d\n", redPieces);
                break;
            case 2:
                brownPieces = result;
                printf("Processed brown pieces: %d\n", brownPieces);
                break;
            case 3:
                bluePieces = result;
                printf("Processed blue pieces: %d\n", bluePieces);
                break;
        }
    }
    
    resetCoords();
    

    if (greenPieces > 0 || redPieces > 0 || brownPieces > 0 || bluePieces > 0) return 1;

    
    return 0;
}


 + (UIImage*) warp:(UIImage *)input destination_image:(UIImage *)output
{
    // convert input and output to cv::Mat
    cv::Mat src = [input CVMat3];
    cv::Mat dst = [output CVMat3];
    
    CvPoint corners[4];
    
    // put x,y coords of 4 corners into a CvPoint array for warping
    corners[0].x = a[0];
    corners[0].y = a[1];
    corners[1].x = a[2];
    corners[1].y = a[3];
    corners[2].x = a[4];
    corners[2].y = a[5];
    corners[3].x = a[6];
    corners[3].y = a[7];
    
    // warp function in stitching.cpp
    warp(src, dst, corners);
    
    
    // convert cv::Mat to UIImage
    UIImage* result = [UIImage imageWithCVMat:dst];
    
    return result;
}



+ (UIImage*) thresh:(UIImage*) src colorCase:(int)colorCase
{
    // UIImage to cv::Mat
    cv::Mat matted = [src CVMat3];
    
    
    // cv::Mat to IplImage
    IplImage copy = matted;
    IplImage* ret = &copy;
 
    
    // call thresh function in stitching.cpp
    ret = thresh(ret, colorCase);
    
    // IplImage to cv::Mat
    matted = cvarrToMat(ret);

    // cv::Mat to UIImage
    UIImage* thr = [UIImage imageWithCVMat:matted];
    
    
    //return UIImage
    return thr;
    
    
}




@end
