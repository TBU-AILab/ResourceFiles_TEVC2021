################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
O_SRCS += \
../icmaesils-configuration.o \
../icmaesils-gcmaes.o \
../icmaesils-main.o \
../icmaesils-origcmaes.o \
../icmaesils-rng.o \
../icmaesils-test_func.o 

CPP_SRCS += \
../acor.cpp \
../configuration.cpp \
../csd.cpp \
../main.cpp \
../problem.cpp \
../rng.cpp \
../test_func.cpp \
../test_func0117.cpp \
../utilities.cpp 

C_SRCS += \
../origcmaes.c 

CC_SRCS += \
../gcmaes.cc 

OBJS += \
./acor.o \
./configuration.o \
./csd.o \
./gcmaes.o \
./main.o \
./origcmaes.o \
./problem.o \
./rng.o \
./test_func.o \
./test_func0117.o \
./utilities.o 

C_DEPS += \
./origcmaes.d 

CC_DEPS += \
./gcmaes.d 

CPP_DEPS += \
./acor.d \
./configuration.d \
./csd.d \
./main.d \
./problem.d \
./rng.d \
./test_func.d \
./test_func0117.d \
./utilities.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

%.o: ../%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

%.o: ../%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


