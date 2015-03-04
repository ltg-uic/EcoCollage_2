/*
 * EcoCollage.cpp
 *
 *  Created on: June 3, 2013
 *    Author: Brianna
 */
#include <iostream>
#include <unistd.h>
#include <unistd.h>
#include <cstdio>
#include <cstdlib>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <fstream>
#include <cv.h>
#include <highgui.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>

//include aruco libs
#include "Aruco/cvdrawingutils.h"
#include "Aruco/aruco.h"

// For MySQL Connection
#include <mysql.h>

using namespace std;

FILE 			*outputRecord;
char            *filename = "Results.txt";

FILE *trialFile;
char *trialName = new char [100];

int             conditionTrial = 0;
int				studyNum = -50;		//change this number before each study
int				calibrate = 0;

//also change these if you want to test the markers and if the board is not ready
bool testMarkers = true;
bool ready = true;

//change these depending on the size of the board and markers
const int boardLength = 32;			//this corresponds to the number of squares INCLUDING the markers
const int boardHeight = 33;
const int sizeOfMarker = 3;			//this corresponds to the length of the marker relative to the board squares

////Variables for marker tracking and for image transformation and crop
////Indices for the markers array
//int iBR = 1;
//int iTR = 3;
//int iBL = 0;
//int iTL = 2;

//marker cordinates
cv::Point2f topLeftM;
cv::Point2f topRightM;
cv::Point2f bottomLeftM;
cv::Point2f bottomRightM;

double ratio = (double) boardHeight / boardLength;

// Defining Constant Variables for accessing the database
#define SERVER "localhost"
#define USER "root"
#define PASSWORD ""
#define DATABASE "flag"

//Define marker IDS
#define TL_MARKER 818
#define TR_MARKER 839
#define BL_MARKER 4
#define BR_MARKER 339

//define cost of each piece
#define RED_COST 1000
#define BLUE_COST 1000
#define GREEN_COST 1000
#define BROWN_COST 1000


//added two boolean parameters and added a int return statement to return the number of each piece
int DetectAndDrawQuads(IplImage * img, IplImage * original, int frameNumber, int colorCase, bool simulate)
{
	CvSeq * contours;
	CvSeq * result;
	CvMemStorage * storage = cvCreateMemStorage(0);
	IplImage * ret = cvCreateImage(cvGetSize(img), 8, 3);
	IplImage * temp = cvCloneImage(img);
	IplImage * oriTemp = cvCloneImage(original);

	//	symbolList[frameNumber].clear();
	int count = 0;
	int numPieces = 0;
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

			int w = abs(maxX-minX);
			int h = abs(maxY-minY);
			if( w > 10 & h > 10){
				cvResetImageROI(img);
				char *windowName = new char[20];
				sprintf(windowName, "Detected Object %d - %d ", colorCase, count);
				cvResetImageROI(oriTemp);

				count++;
				cvSetImageROI(oriTemp, cvRect(minX, minY, w, h));

				float xVal= ((maxX+minX) / 2.0) * (21.0/temp->width);
				float yVal = ((maxY+ minY)/ 2.0) * (25.0/temp->height);
				int x = ceil((maxX+minX) / 2.0) * (21.0/temp->width) + 1;
				int y = ceil((maxY+ minY)/ 2.0) * (25.0/temp->height);

				if(calibrate == 1){
					//cvDestroyWindow(windowName);
					//cvNamedWindow(windowName);
					//cvShowImage(windowName, oriTemp);
					printf("%d %f %f\n", colorCase, xVal, yVal);
					printf("%d %d \n", x, y);
				}
				if((x>= 0 && x <= 22) && (y>=0 && y<= 24)){
					if(simulate)
						fprintf(outputRecord, "%d %d %d\n", colorCase, x, 24-y);
					numPieces++;
				}
				fprintf(trialFile, "%d %d %d\n", colorCase, x, 24-y);

				printf("%d %d %d\n", colorCase, x, 24-y);
			}

		}
		contours = contours -> h_next;
	}

	cvReleaseImage(&temp);
	cvReleaseMemStorage(&storage);
	return numPieces;
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
	//g		ƒcvInRangeS(imgHSV, cvScalar(0, 100, 50), cvScalar(15, 200, 150), imgThreshed);
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
		cvInRangeS(imgHSV, cvScalar(0, 100, 90), cvScalar(20, 220, 255), imgThreshed);
		break;
		//**	blue
	case 3:
		cvInRangeS(imgHSV, cvScalar(90, 50, 40), cvScalar(150, 200, 200), imgThreshed);
		break;
		//**	green
	case 0:
		cvInRangeS(imgHSV, cvScalar(40, 35, 40), cvScalar(90, 255, 115), imgThreshed);
		break;
		//**	wood
	case 2:
		cvInRangeS(imgHSV, cvScalar(15, 60, 90), cvScalar(40, 200, 200), imgThreshed);
		break;
        //**    black
    case 4:
        cvInRangeS(imgHSV, cvScalar(0, 0, 0), cvScalar(255, 255, 40), imgThreshed);
            break;
    }

	//Release the temp HSV image and return this thresholded image
	cvReleaseImage(&imgHSV);
	return imgThreshed;
}

//checks the status of the flag
int flagStatus(MYSQL *connect){
	 MYSQL_RES *res_set;
	 MYSQL_ROW row;
	 int status = 0;

	 //input query here
	 mysql_query (connect,"SELECT status FROM button WHERE id = 1");

	 unsigned int i=0;
	 res_set=mysql_store_result(connect);
	 unsigned int numrows = mysql_num_rows(res_set);

	 //not the best way to do this, will make it better later
	 while (((row=mysql_fetch_row(res_set)) !=NULL))
	 {
		 //set flag to true
		 if(*row[i] == '0'){
			 cout << "its false\n";
			 status = 0;
		 }
		 else if(*row[i] == '1'){
			 cout<<"its cost check\n";
			 status = 1;
		 }
		 else if(*row[i] == '2'){
			 cout<<"write to file\n";
			 status = 2;
		 }
		 else
			 status = 0;
		 break;
	 }

	 delete(res_set);
	 //delete(*row);

	 return status;
}

//Sets the flag to status
void setFlag(bool status, MYSQL *connect){
	if(status)
		mysql_query (connect,"UPDATE `flag`.`button` SET `status`=1 WHERE `id`='1'");
	else
		mysql_query (connect,"UPDATE `flag`.`button` SET `status`=0 WHERE `id`='1'");
}

int getMarkerCoordinates(vector<aruco::Marker> &markers, cv::Mat &cameraMat){
	int count =0;
	for(int x =0; x< markers.size(); x++){
		switch(markers[x].id){
			case TL_MARKER:
				topLeftM = markers[x].getCenter();
				count++;
				break;
			case TR_MARKER:
				topRightM = markers[x].getCenter();
				count++;
				break;
			case BL_MARKER:
				bottomLeftM = markers[x].getCenter();
				count++;
				break;
			case BR_MARKER:
				bottomRightM = markers[x].getCenter();
				count++;
				break;
			default:
				break;
		}
	}

	//MARKERS TESTING
	if(testMarkers){
		for (unsigned int i=0;i<markers.size();i++) {
			markers[i].draw(cameraMat, cv::Scalar(255,0,0), 2, true);
			cv::circle(cameraMat, markers[i].getCenter(), markers[i].getPerimeter()/8, cv::Scalar(255,0 ,0), 3);

			cout << "marker ID[" << markers[i].id << "] has index [" << i<< "]\n";
			cv::circle(cameraMat, markers[i].getCenter(), 5, cv::Scalar(0,0 ,255), 1);
		}
	}

	return count;
}

int main()
{
	//MySQL database stuff
    MYSQL *connect;
    connect = mysql_init(NULL);
    if (!connect)
    {
    	cout << "Mysql Initialization Failed";
        return 1;
    }

    connect = mysql_real_connect(connect, SERVER, USER, PASSWORD, DATABASE, 0,NULL,0);
    if (connect)
    	cout << "Connection Succeeded\n";
    else{
    	cout << "Connection Failed\n";
    	return -1;
    }

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

	//Mats used for marker tracking and transformations
	cv::Mat betterCrop;
	cv::Mat cameraMat;
	//cameraMat = frame;

	//aruco marker tracking vars
	aruco::MarkerDetector marker;
	aruco::MarkerDetector Mtags;
	aruco::CameraParameters camPars;
	aruco::MarkerDetector detector;
	vector<aruco::Marker> markers;

	//Get the 4 marker locations
	topLeftM.x = -1;
	topRightM.x = -1;
	bottomLeftM.x = -1;
	bottomRightM.x = -1;
	while(1){

		if(topLeftM.x != -1 && topRightM.x != -1 && bottomLeftM.x != -1 && bottomRightM.x != -1 )
			break;
		else{
			frame = cvQueryFrame(capture);
			cameraMat = frame;
			Mtags.detect(cameraMat, markers, camPars);
			getMarkerCoordinates(markers, cameraMat);
			cv::imshow("Original Mat", cameraMat);
			cv::waitKey(100);
		}
	}

	int redPieces = 0;
	int bluePieces = 0;
	int greenPieces = 0;
	int brownPieces = 0;

	bool writeToFile = false;
	bool getCost = false;
	bool gotCroppedImg = false;

	//press esc to escape
	char key = 'a';
	while (key != 27){

		key = cvWaitKey(1000);
		int iPadButtonResult = flagStatus(connect);

		if (iPadButtonResult == 1)
			getCost = true;
		if (iPadButtonResult == 2)
			writeToFile = true;

		if(iPadButtonResult != 0){
			frame = cvQueryFrame(capture);
			//If we couldn't grab a frame... quit
			if(!frame){
				cout << "Yo I couldn't get a frame!";
				break;
			}

			cameraMat = frame;
			Mtags.detect(cameraMat, markers, camPars);

			//Get image and crop it if at least 3 of the markers are detected
			if(ready) {
				while(1){
					frame = cvQueryFrame(capture);
					cameraMat = frame;
					Mtags.detect(cameraMat, markers, camPars);
					int numMarkers = getMarkerCoordinates(markers, cameraMat);
					cv::imshow("Original Mat", cameraMat);
					cv::waitKey(100);

					if(numMarkers == 4)
						break;
					else if (numMarkers == 3){
						cout<< "only three are being detected\n";
						break;
					}
				}
				//draw lines
				cv::line(cameraMat, bottomRightM, bottomLeftM, cv::Scalar(0,0,255), 2, 1);
				cv::line(cameraMat, bottomLeftM, topLeftM, cv::Scalar(0,0,255), 2, 1);
				cv::line(cameraMat, topLeftM, topRightM, cv::Scalar(0,0,255), 2, 1);
				cv::line(cameraMat, topRightM, bottomRightM, cv::Scalar(0,0,255), 2, 1);

				//////////////transformation stuff///////////////////////////////////////////////////////////////////////////
				//Code based on a tutorial on http://bikramhanjra.blogspot.com/2013/06/perspective-transformation-opencv.html
				cv::Point2f inputPoints[4], outputPoints[4];
				cv::Mat transformedImg;
				cv::Mat lambda(2, 4, CV_32FC1);

				int cropLength = topRightM.x - topRightM.y;
				lambda = cv::Mat::zeros(cropLength, cropLength*ratio, cameraMat.type());

				//Now using the four points from the markers we can transform the image
				//points to crop and transform
				inputPoints[0] = topLeftM;
				inputPoints[1] = topRightM;
				inputPoints[2] = bottomRightM;
				inputPoints[3] = bottomLeftM;

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
			cv::imshow("Original Mat", cameraMat);
			setFlag(false, connect);
		}

		//get treshholds and write information to file
		if( iPadButtonResult != 0){
			// Will hold a frame captured from the camera

			IplImage copy = betterCrop;
			IplImage *toTresh = &copy;

			if(writeToFile){
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
			}

			//Holds the yellow thresholded image
			for(int i=0; i < 4; i++){

				IplImage * imgGreenThresh = GetThresholdedImage(toTresh, i);
				if(calibrate){
				char *windowName = new char[20];
				sprintf(windowName, "Threshholded Image for color %d ", i);
				cvDestroyWindow(windowName);
				cvNamedWindow(windowName);
				cvShowImage(windowName, imgGreenThresh);
				}
				//cvResizeWindow(windowName , imgGreenThresh->width/2, imgGreenThresh->height/2);
				int result = DetectAndDrawQuads(imgGreenThresh, frame, 0, i, writeToFile);

				switch(i){
					case 0:
						greenPieces = result;
						break;
					case 1:
						redPieces = result;
						break;
					case 2:
						brownPieces = result;
						break;
					case 3:
						bluePieces = result;
						break;
				}
			}

			if(writeToFile){
				fprintf(outputRecord, "]\n");
				fflush(outputRecord);
				fclose(outputRecord);
				fclose(trialFile);
				conditionTrial++;
			}
//			int keyEscape = 0;
//			while (keyEscape != 32) keyEscape = cvWaitKey(100);
		}

		if(getCost){
			//to do, get the cost and put it in the date base
		}

		 writeToFile = false;
		 getCost = false;
	}

	mysql_close (connect);
	return 0;
}


//scared i will break something so i just commented it all out...

//int main()
//{
//	// Initialize capturing live feed from the camera
//	CvCapture * capture = 0;
//	capture = cvCaptureFromCAM(1);
//
//	// Couldn't get a device? Throw an error and quit
//	if(!capture)
//	{
//		printf("Could not initialize capturing...\n");
//		return -1;
//	}
//
//	IplImage * frame = 0;
//	frame = cvQueryFrame(capture);
//	//cvNamedWindow("original", CV_WINDOW_NORMAL);
//	//cvResizeWindow("original", frame->width/2, frame->height/2);
//
//	//Mats used for marker tracking and transformations
//	cv::Mat betterCrop;
//	cv::Mat cameraMat;
//	cameraMat = frame;
//
//	//aruco marker tracking vars
//	aruco::MarkerDetector marker;
//	aruco::MarkerDetector Mtags;
//	aruco::CameraParameters camPars;
//	aruco::MarkerDetector detector;
//	vector<aruco::Marker> markers;
//
//	char key = 'a';
//	bool gotCroppedImg = false;
//	//press esc to escape
//	while (key != 27){
//		key = cvWaitKey(100);
//
//		frame = cvQueryFrame(capture);
//		//If we couldn't grab a frame... quit
//		if(!frame){
//			cout << "Yo I couldn't get a frame!";
//			break;
//		}
//		cameraMat = frame;
//		Mtags.detect(cameraMat, markers, camPars);
//		//cvShowImage("original", frame);
//
//		//MARKERS TESTING
//		if(testMarkers){
//			for (unsigned int i=0;i<markers.size();i++) {
//				markers[i].draw(cameraMat, cv::Scalar(255,0,0), 2, true);
//			    cv::circle(cameraMat, markers[i].getCenter(), markers[i].getPerimeter()/8, cv::Scalar(255,0 ,0), 3);
//
//			  	cout << "marker ID[" << markers[i].id << "] has index [" << i<< "]\n";
//			    cv::circle(cameraMat, markers[i].getCenter(), 5, cv::Scalar(0,0 ,255), 1);
//			}
//		}
//
//		//Get image and crop it if all 4 of the markers are detected
//		if(markers.size() == 4 && ready) {
//			//get the four points
//			//Bottom right
//			cv::Point2f BR = markers[iBR].getCenter();
//			//Top right
//			cv::Point2f TR = markers[iTR].getCenter();
//			//Bottom left
//			cv::Point2f BL = markers[iBL].getCenter();
//			//Top left
//			cv::Point2f TL = markers[iTL].getCenter();
//
//			//draw lines
//			cv::line(cameraMat, BR, BL, cv::Scalar(0,0,255), 2, 1);
//			cv::line(cameraMat, BL, TL, cv::Scalar(0,0,255), 2, 1);
//			cv::line(cameraMat, TL, TR, cv::Scalar(0,0,255), 2, 1);
//			cv::line(cameraMat, TR, BR, cv::Scalar(0,0,255), 2, 1);
//
//			//////////////transformation stuff///////////////////////////////////////////////////////////////////////////
//			//Code based on a tutorial on http://bikramhanjra.blogspot.com/2013/06/perspective-transformation-opencv.html
//			cv::Point2f inputPoints[4], outputPoints[4];
//			cv::Mat transformedImg;
//			cv::Mat lambda(2, 4, CV_32FC1);
//
//			int cropLength = TR.x - TR.y;
//			lambda = cv::Mat::zeros(cropLength, cropLength*ratio, cameraMat.type());
//
//			//Now using the four points from the markers we can transform the image
//			//points to crop and transform
//			inputPoints[0] = TL;
//			inputPoints[1] = TR;
//			inputPoints[2] = BR;
//			inputPoints[3] = BL;
//
//			//destination of those points
//			outputPoints[0] = cv::Point2f(0,0);
//			outputPoints[1] = cv::Point2f(cropLength - 1, 0);
//			outputPoints[2] = cv::Point2f(cropLength - 1, cropLength*ratio - 1);
//			outputPoints[3] = cv::Point2f(0, cropLength*ratio - 1);
//			lambda = cv::getPerspectiveTransform(inputPoints, outputPoints);
//
//			//Create transformed image with the correct ratios
//			cv::warpPerspective(cameraMat, transformedImg, lambda, cv::Size2i(cropLength, cropLength*ratio));
//
//		    //crop extra border of stuff
//		    int offSetH = (double) transformedImg.rows/(boardHeight- sizeOfMarker) * ((double)sizeOfMarker/2);
//		    int offSetL = (double) transformedImg.cols/(boardLength- sizeOfMarker) * ((double)sizeOfMarker/2);
//		    cv::Rect theArea (offSetL, offSetH, transformedImg.cols - offSetL*2, transformedImg.rows - offSetH*2);
//		    betterCrop = transformedImg(theArea);
//			cv::imshow("Cropped", betterCrop);
//
//			//update bool
//			gotCroppedImg = true;
//		}
//
//		if( key == 32 && gotCroppedImg){
//			printf("spacebar pressed\n");
//			// Will hold a frame captured from the camera
//
//		    IplImage copy = betterCrop;
//		    IplImage *toTresh = &copy;
//
//
//		    sprintf(trialName, "e_%d_t_%d.txt", studyNum, conditionTrial);
//		    trialFile = fopen(trialName, "w+");
//		    if (trialFile == NULL){
//		    	printf("Recording file trial open error.");
//	 	        exit(0);
//		    }
//		    time_t stamp;
//		    struct tm *Tm;
//		    stamp = time(NULL);
//		    Tm = localtime(&stamp);
//		    fprintf(trialFile,"\n%d %d %d %d %d %d\n", Tm->tm_year+1900, Tm->tm_mday ,Tm->tm_mon+1, Tm->tm_hour, Tm->tm_min, Tm->tm_sec);
//		    fprintf(trialFile, "experiment %d\ntrial %d\n\n", studyNum, conditionTrial);
//
//			outputRecord = fopen(filename, "w+");
//			if (outputRecord == NULL){
//		        printf("Recording file open error.");
//		        exit(0);
//			}
//
//			fprintf(outputRecord, "[\n");
//			fprintf(outputRecord, "%d %d\n",  studyNum, conditionTrial);
//
//			//Holds the yellow thresholded image
//			for(int i=0; i < 4; i++){
//
//				IplImage * imgGreenThresh = GetThresholdedImage(toTresh, i);
//				if(calibrate){
//				char *windowName = new char[20];
//				sprintf(windowName, "Threshholded Image for color %d ", i);
//				cvDestroyWindow(windowName);
//				cvNamedWindow(windowName);
//				cvShowImage(windowName, imgGreenThresh);
//				}
//				//cvResizeWindow(windowName, imgGreenThresh->width/2, imgGreenThresh->height/2);
//				DetectAndDrawQuads(imgGreenThresh, frame, 0, i);
//			}
//
//			fprintf(outputRecord, "]\n");
//			fflush(outputRecord);
//			fclose(outputRecord);
//			fclose(trialFile);
//
//			conditionTrial++;
//			int keyEscape = 0;
//			while (keyEscape != 32) keyEscape = cvWaitKey(100);
//		}
//		cv::imshow("Original Mat", cameraMat);
//	}
//
//	return 0;
//}
