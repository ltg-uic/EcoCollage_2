/*
 * EcoCollage.cpp
 *
 *  Created on: June 3, 2013
 *    Author: Brianna
 */
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <fstream>
#include <cv.h>
#include <highgui.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include "Aruco/cvdrawingutils.h"
#include "Aruco/aruco.h"

using namespace std;

FILE 			*outputRecord;
char            *filename = "Results.txt";

FILE *trialFile;
char *trialName = new char [100];

int             conditionTrial = 0;
//change this number before each study
int				studyNum = 42;
int				calibrate = 1;

//also change these if you want to test the markers and if the board is not ready
bool testMarkers = false;
bool ready = true;

//change these depending on the size of the board and markers
const int boardLength = 32;			//this corresponds to the number of squares INCLUDING the markers
const int boardHeight = 33;
const int sizeOfMarker = 3;			//this corresponds to the length of the marker relative to the board

//Variables for marker tracking and for image transformation and crop
//Indices for the markers array
int iBR = 1;
int iTR = 3;
int iBL = 0;
int iTL = 2;

double ratio = (double) boardHeight / boardLength;

void DetectAndDrawQuads(IplImage * img, IplImage * original, int frameNumber, int colorCase)
{
	CvSeq * contours;
	CvSeq * result;
	CvMemStorage * storage = cvCreateMemStorage(0);
	IplImage * ret = cvCreateImage(cvGetSize(img), 8, 3);
	IplImage * temp = cvCloneImage(img);
	IplImage * oriTemp = cvCloneImage(original);

	//	symbolList[frameNumber].clear();
	int count = 0;
	cvFindContours(temp, storage, &contours, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0));
	while(contours)
	{

		result = cvApproxPoly(contours, sizeof(CvContour), storage, CV_POLY_APPROX_DP, cvContourPerimeter(contours) * 0.02, 0);
		if(result->total>=4 && fabs(cvContourArea(result, CV_WHOLE_SEQ)) > 20)
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

//			int x = 0;
//			if (pt[2]->x< pt[0]->x)
//			{
//				x = pt[2]->x;
//			}else{
//				x = pt[0]->x;
//			}
//			int y = pt[0]->y;

			int w = abs(maxX-minX);
			int h = abs(maxY-minY);
			if( w > 16 & h > 16){
			cvResetImageROI(img);
			char *windowName = new char[20];
			sprintf(windowName, "Detected Object %d - %d ", colorCase, count);
			cvResetImageROI(oriTemp);

				count++;
				cvSetImageROI(oriTemp, cvRect(minX, minY, w, h));

				float xVal= ((maxX+minX) / 2.0) * (23.0/temp->width);
				float yVal = ((maxY+ minY)/ 2.0) * (27.0/temp->height);
				int x = ceil((maxX+minX) / 2.0) * (23.0/temp->width) + 1;
				int y = ceil((maxY+ minY)/ 2.0) * (27.0/temp->height) + 1;

				if(calibrate == 1){
					//cvDestroyWindow(windowName);
					//cvNamedWindow(windowName);
					//cvShowImage(windowName, oriTemp);
					printf("%d %f %f\n", colorCase, xVal, yVal);
					printf("%d %d \n", x, y);
				}
				if((x>= 0 && x <= 23) && (y>=0 && y<= 27))
				fprintf(outputRecord, "%d %d %d\n", colorCase, x, y);
				fprintf(trialFile, "%d %d %d\n", colorCase, x, y);
			}

		}
		contours = contours -> h_next;
	}

	cvReleaseImage(&temp);
	cvReleaseMemStorage(&storage);
}

//Thresholding function
IplImage * GetThresholdedImage(IplImage * img, int colorCase)
{
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

	switch(colorCase){
	//**	red
	case 1 :
		cvInRangeS(imgHSV, cvScalar(0, 100, 90), cvScalar(20, 200, 255), imgThreshed);
		break;
		//**	blue
	case 3:
		cvInRangeS(imgHSV, cvScalar(90, 40, 50), cvScalar(150, 255, 200), imgThreshed);
		break;
		//**	green
	case 0:
		cvInRangeS(imgHSV, cvScalar(40, 35, 40), cvScalar(90, 255, 115), imgThreshed);
		break;
		//**	wood
	case 2:
		cvInRangeS(imgHSV, cvScalar(15, 60, 90), cvScalar(40, 200, 200), imgThreshed);
		break;
	}

	//Release the temp HSV image and return this thresholded image
	cvReleaseImage(&imgHSV);
	return imgThreshed;
}

int main()
{
	// Initialize capturing live feed from the camera
	CvCapture * capture = 0;
	capture = cvCaptureFromCAM(1);

	// Couldn't get a device? Throw an error and quit
	if(!capture)
	{
		printf("Could not initialize capturing...\n");
		return -1;
	}

	IplImage * frame = 0;
	frame = cvQueryFrame(capture);
	//cvNamedWindow("original", CV_WINDOW_NORMAL);
	//cvResizeWindow("original", frame->width/2, frame->height/2);

	//Mats used for marker tracking and transformations
	cv::Mat betterCrop;
	cv::Mat cameraMat;
	cameraMat = frame;

	//aruco marker tracking vars
	aruco::MarkerDetector marker;
	aruco::MarkerDetector Mtags;
	aruco::CameraParameters camPars;
	aruco::MarkerDetector detector;
	vector<aruco::Marker> markers;

	char key = 'a';
	bool gotCroppedImg = false;
	//press esc to escape
	while (key != 27){
		key = cvWaitKey(100);

		frame = cvQueryFrame(capture);
		//If we couldn't grab a frame... quit
		if(!frame){
			cout << "Yo I couldn't get a frame!";
			break;
		}
		cameraMat = frame;
		Mtags.detect(cameraMat, markers, camPars);
		//cvShowImage("original", frame);

		//MARKERS TESTING
		if(testMarkers){
			for (unsigned int i=0;i<markers.size();i++) {
				markers[i].draw(cameraMat, cv::Scalar(255,0,0), 2, true);
			    cv::circle(cameraMat, markers[i].getCenter(), markers[i].getPerimeter()/8, cv::Scalar(255,0 ,0), 3);

			  	cout << "marker ID[" << markers[i].id << "] has index [" << i<< "]\n";
			    cv::circle(cameraMat, markers[i].getCenter(), 5, cv::Scalar(0,0 ,255), 1);
			}
		}

		//Get image and crop it if all 4 of the markers are detected
		if(markers.size() == 4 && ready) {
			//get the four points
			//Bottom right
			cv::Point2f BR = markers[iBR].getCenter();
			//Top right
			cv::Point2f TR = markers[iTR].getCenter();
			//Bottom left
			cv::Point2f BL = markers[iBL].getCenter();
			//Top left
			cv::Point2f TL = markers[iTL].getCenter();

			//draw lines
			cv::line(cameraMat, BR, BL, cv::Scalar(0,0,255), 2, 1);
			cv::line(cameraMat, BL, TL, cv::Scalar(0,0,255), 2, 1);
			cv::line(cameraMat, TL, TR, cv::Scalar(0,0,255), 2, 1);
			cv::line(cameraMat, TR, BR, cv::Scalar(0,0,255), 2, 1);

			//////////////transformation stuff///////////////////////////////////////////////////////////////////////////
			//Code based on a tutorial on http://bikramhanjra.blogspot.com/2013/06/perspective-transformation-opencv.html
			cv::Point2f inputPoints[4], outputPoints[4];
			cv::Mat transformedImg;
			cv::Mat lambda(2, 4, CV_32FC1);

			int cropLength = TR.x - TR.y;
			lambda = cv::Mat::zeros(cropLength, cropLength*ratio, cameraMat.type());

			//Now using the four points from the markers we can transform the image
			//points to crop and transform
			inputPoints[0] = TL;
			inputPoints[1] = TR;
			inputPoints[2] = BR;
			inputPoints[3] = BL;

			//destination of those points
			outputPoints[0] = cv::Point2f(0,0);
			outputPoints[1] = cv::Point2f(cropLength - 1, 0);
			outputPoints[2] = cv::Point2f(cropLength - 1, cropLength*ratio - 1);
			outputPoints[3] = cv::Point2f(0, cropLength*ratio - 1);
			lambda = cv::getPerspectiveTransform(inputPoints, outputPoints);

			//Create transformed image with the correct ratios
			cv::warpPerspective(cameraMat, transformedImg, lambda, cv::Size2i(cropLength, cropLength*ratio));

		    //crop extra border of stuff
		    int offSetH = (double) transformedImg.rows/(boardHeight- sizeOfMarker) * ((double)sizeOfMarker/2);
		    int offSetL = (double) transformedImg.cols/(boardLength- sizeOfMarker) * ((double)sizeOfMarker/2);
		    cv::Rect theArea (offSetL, offSetH, transformedImg.cols - offSetL*2, transformedImg.rows - offSetH*2);
		    betterCrop = transformedImg(theArea);
			cv::imshow("Cropped", betterCrop);

			//update bool
			gotCroppedImg = true;
		}

		if( key == 32 && gotCroppedImg){
			printf("spacebar pressed\n");
			// Will hold a frame captured from the camera

		    IplImage copy = betterCrop;
		    IplImage *toTresh = &copy;


		    sprintf(trialName, "e_%d_t_%d.txt", studyNum, conditionTrial);
		    trialFile = fopen(trialName, "w+");
		    if (trialFile == NULL){
		    	printf("Recording file trial open error.");
	 	        exit(0);
		    }
		    time_t stamp;
		    struct tm *Tm;
		    stamp = time(NULL);
		    Tm = localtime(&stamp);
		    fprintf(trialFile,"\n%d %d %d %d %d %d\n", Tm->tm_year+1900, Tm->tm_mday ,Tm->tm_mon+1, Tm->tm_hour, Tm->tm_min, Tm->tm_sec);
		    fprintf(trialFile, "experiment %d\ntrial %d\n\n", studyNum, conditionTrial);

			outputRecord = fopen(filename, "w+");
			if (outputRecord == NULL){
		        printf("Recording file open error.");
		        exit(0);
			}

			fprintf(outputRecord, "[\n");
			fprintf(outputRecord, "%d %d\n",  studyNum, conditionTrial);

			//Holds the yellow thresholded image
			for(int i=0; i < 4; i++){

				IplImage * imgGreenThresh = GetThresholdedImage(toTresh, i);

				char *windowName = new char[20];
				sprintf(windowName, "Threshholded Image for color %d ", i);
				cvDestroyWindow(windowName);
				cvNamedWindow(windowName);
				cvShowImage(windowName, imgGreenThresh);
				//cvResizeWindow(windowName, imgGreenThresh->width/2, imgGreenThresh->height/2);
				DetectAndDrawQuads(imgGreenThresh, frame, 0, i);
			}

			fprintf(outputRecord, "]\n");
			fflush(outputRecord);
			fclose(outputRecord);
			fclose(trialFile);

			conditionTrial++;
			int keyEscape = 0;
			while (keyEscape != 32) keyEscape = cvWaitKey(100);
		}
		cv::imshow("Original Mat", cameraMat);
	}

	return 0;
}
