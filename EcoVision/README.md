EcoVision was developed by Ryan Fogarty and Salvador Ariza for use in the research of computer vision and tangible user interfaces (TUIs). 

This project utilizes the open source project NMRANGESLIDER (https://github.com/muZZkat/NMRangeSlider) and the open source library openCV.


What needs work:
    1) CVWrapper.mm -> detectContours() -> CvPoint pts[MAX_POINTS]; 
very bad implementation for storing contour points. This should be a stack or linked list so that it can be dynamic. Right now the fixed size is large enough that it will never cause BAD_ACCESS or seg fault for this map; however, it is still prone to causing app crashes if for some reason the amount of contour points is larger than MAX_POINTS

