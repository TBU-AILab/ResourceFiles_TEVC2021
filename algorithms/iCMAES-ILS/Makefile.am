bin_PROGRAMS = icmaesils
icmaesils_SOURCES = rng.cpp \
		      configuration.cpp \
			  icmaesils.cc\
			  cmaes.c\
			  test_func.cpp\
			  main.cpp 		
			
icmaesils_CPPFLAGS = -I. -I tclap-1.1.0/include 
icmaesils_LDADD = -lm -lgsl -lgslcblas
