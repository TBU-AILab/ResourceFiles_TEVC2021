################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../gcmaes/cma/cmaes.c \
../gcmaes/cma/example1.c \
../gcmaes/cma/example2.c 

OBJS += \
./gcmaes/cma/cmaes.o \
./gcmaes/cma/example1.o \
./gcmaes/cma/example2.o 

C_DEPS += \
./gcmaes/cma/cmaes.d \
./gcmaes/cma/example1.d \
./gcmaes/cma/example2.d 


# Each subdirectory must supply rules for building sources it contributes
gcmaes/cma/%.o: ../gcmaes/cma/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


