################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/Aruco/arucofidmarkers.cpp \
../src/Aruco/board.cpp \
../src/Aruco/boarddetector.cpp \
../src/Aruco/cameraparameters.cpp \
../src/Aruco/cvdrawingutils.cpp \
../src/Aruco/marker.cpp \
../src/Aruco/markerdetector.cpp 

OBJS += \
./src/Aruco/arucofidmarkers.o \
./src/Aruco/board.o \
./src/Aruco/boarddetector.o \
./src/Aruco/cameraparameters.o \
./src/Aruco/cvdrawingutils.o \
./src/Aruco/marker.o \
./src/Aruco/markerdetector.o 

CPP_DEPS += \
./src/Aruco/arucofidmarkers.d \
./src/Aruco/board.d \
./src/Aruco/boarddetector.d \
./src/Aruco/cameraparameters.d \
./src/Aruco/cvdrawingutils.d \
./src/Aruco/marker.d \
./src/Aruco/markerdetector.d 


# Each subdirectory must supply rules for building sources it contributes
src/Aruco/%.o: ../src/Aruco/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -I/usr/local/mysql/include -I/usr/local/include/opencv2 -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


