/*
 * EcoCollage.cpp
 *
 *  Created on: June 3, 2013
 *    Author: Brianna
 */
#include <iostream>
using namespace std;
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <cv.h>
#include <highgui.h>

FILE 			*outputRecord;
char            *filename = "Results.txt";
int             conditionTrial = 0;

//change this number before each study
int				studyNum = 42;
int				calibrate = 1;

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
			if( w > 20 & h > 20){
			cvResetImageROI(img);
			char *windowName = new char[20];
			sprintf(windowName, "Detected Object %d - %d ", colorCase, count);
			cvResetImageROI(oriTemp);

				count++;
				cvSetImageROI(oriTemp, cvRect(minX, minY, w, h));

				float xVal= (maxX+minX) / 2.0 * 25.0 / 1153;
				float yVal = (maxY+ minY)/2.0 * 15.0 / 1116;
				int x = floor( (maxX+minX) / 2.0 * 25.0 / 1153 - 9);
				int y = floor( (maxY+ minY)/2.0 * 25.0 / 1116 - 15.73);
				 if( (maxY+ minY)/2.0 * 25.0 / 1116 - 15.69 > 9 && x <= 11 ) y--;
				if(calibrate == 1 && colorCase == 0){
					//cvDestroyWindow(windowName);
					//cvNamedWindow(windowName);
					//cvShowImage(windowName, oriTemp);
					printf("%f %f\n", yVal, xVal);
					printf("%d %d \n", y, x);
				}
				if((x>= 0 && x <= 25) && (y>=0 && y<= 25))
				fprintf(outputRecord, "%d %d %d\n", colorCase, y, x);
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
		cvInRangeS(imgHSV, cvScalar(0, 100, 60), cvScalar(15, 200, 255), imgThreshed);
		break;
		//**	blue
	case 3:
		cvInRangeS(imgHSV, cvScalar(90, 40, 50), cvScalar(150, 255, 200), imgThreshed);
		break;
		//**	green
	case 0:
		cvInRangeS(imgHSV, cvScalar(40, 35, 50), cvScalar(90, 255, 225), imgThreshed);
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

	char key = 'a';

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
	cvNamedWindow("original", CV_WINDOW_NORMAL);
	//cvResizeWindow("original", frame->width/2, frame->height/2);
	while (key != 27)
	{
		int key = cvWaitKey(100);
		frame = cvQueryFrame(capture);

		cvShowImage("original", frame);

		//If we couldn't grab a frame... quit
		if(!frame)
			break;

		if( key == 32){
			printf("spacebar pressed\n");
			// Will hold a frame captured from the camera

			outputRecord = fopen(filename, "w+");
			if (outputRecord == NULL){
			        printf("Recording file open error.");
			        exit(0);
			    }
			fprintf(outputRecord, "[\n");
			fprintf(outputRecord, "%d %d\n",  studyNum, conditionTrial);
			//Holds the yellow thresholded image
			for(int i=0; i < 4; i++){
				IplImage * imgGreenThresh = GetThresholdedImage(frame, i);
				char *windowName = new char[20];
				sprintf(windowName, "Threshholded Image for color %d ", i);
				cvDestroyWindow(windowName);
				cvNamedWindow(windowName);
				cvShowImage(windowName, imgGreenThresh);
				cvResizeWindow(windowName, imgGreenThresh->width/2, imgGreenThresh->height/2);
				DetectAndDrawQuads(imgGreenThresh, frame, 0, i);
			}
			fprintf(outputRecord, "]\n");
			fflush(outputRecord);
			fclose(outputRecord);
			conditionTrial++;
			int keyEscape = 0;
			while (keyEscape != 32) keyEscape = cvWaitKey(100);
		}
	}

	return 0;
}
