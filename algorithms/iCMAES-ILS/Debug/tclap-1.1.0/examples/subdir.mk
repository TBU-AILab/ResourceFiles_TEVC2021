################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../tclap-1.1.0/examples/test1.cpp \
../tclap-1.1.0/examples/test2.cpp \
../tclap-1.1.0/examples/test3.cpp \
../tclap-1.1.0/examples/test4.cpp \
../tclap-1.1.0/examples/test5.cpp \
../tclap-1.1.0/examples/test6.cpp \
../tclap-1.1.0/examples/test7.cpp \
../tclap-1.1.0/examples/test8.cpp \
../tclap-1.1.0/examples/test9.cpp 

OBJS += \
./tclap-1.1.0/examples/test1.o \
./tclap-1.1.0/examples/test2.o \
./tclap-1.1.0/examples/test3.o \
./tclap-1.1.0/examples/test4.o \
./tclap-1.1.0/examples/test5.o \
./tclap-1.1.0/examples/test6.o \
./tclap-1.1.0/examples/test7.o \
./tclap-1.1.0/examples/test8.o \
./tclap-1.1.0/examples/test9.o 

CPP_DEPS += \
./tclap-1.1.0/examples/test1.d \
./tclap-1.1.0/examples/test2.d \
./tclap-1.1.0/examples/test3.d \
./tclap-1.1.0/examples/test4.d \
./tclap-1.1.0/examples/test5.d \
./tclap-1.1.0/examples/test6.d \
./tclap-1.1.0/examples/test7.d \
./tclap-1.1.0/examples/test8.d \
./tclap-1.1.0/examples/test9.d 


# Each subdirectory must supply rules for building sources it contributes
tclap-1.1.0/examples/%.o: ../tclap-1.1.0/examples/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


