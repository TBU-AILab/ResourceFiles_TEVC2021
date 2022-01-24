################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../gcmaes/origcmaes.c 

CC_SRCS += \
../gcmaes/gcmaes.cc \
../gcmaes/main_gcmaes_soft.cc 

OBJS += \
./gcmaes/gcmaes.o \
./gcmaes/main_gcmaes_soft.o \
./gcmaes/origcmaes.o 

C_DEPS += \
./gcmaes/origcmaes.d 

CC_DEPS += \
./gcmaes/gcmaes.d \
./gcmaes/main_gcmaes_soft.d 


# Each subdirectory must supply rules for building sources it contributes
gcmaes/%.o: ../gcmaes/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

gcmaes/%.o: ../gcmaes/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


