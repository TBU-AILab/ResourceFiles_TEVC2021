/*
    Copyright 2013 Tianjun Liao and Thomas Stuetzle

    This file is part of iCMAESILS.

    iCMAESILS is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    iCMAESILS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with iCMAESILS.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef CONFIGURATION_H
#define CONFIGURATION_H


#include <vector>
#include <cmath>
#include "rng.h"



//#define PI acos(-1) 
//#define E exp(1.0)
//#define E 2.7182818284590452353602874713526624977572470937L



class Configuration {
	
    private:
	unsigned long rngSeed;
	unsigned long bound;
	
	// icmaes parameters
	double ttunea;
	double ttuneb;
	double ttunec;
	double ttuned;
	double ttunee;
	double ttunef;
	double ttuneg;

	// ils(mtsls1) parameters
	double mtsls1per_ratedim;
	double mtsls1_initstep_rate;
	double mtsls1_iterbias_choice;

	
	// hybrid parameters
	double learn_perbudget;

   // problem
	unsigned int problemID;
	unsigned int problemDimension;
	long double minInitRange;
	long double maxInitRange;
	double startTime;

    public:

	Configuration(int argc,char** argv);
	~Configuration();
	
	unsigned long getBound();
	unsigned long getRNGSeed();
	double gettunea();
	double gettuneb();
	double gettunec();
	double gettuned();
	double gettunee();
	double gettunef();
	double gettuneg();
	
	double getmtsls1per_ratedim();
	double getlearn_perbudget();
	double getmtsls1_initstep_rate();
	double getmtsls1_iterbias_choice();

	unsigned int getProblemID();
	unsigned int getProblemDimension();
	long double getMinInitRange();
	long double getMaxInitRange();

	void setStartTime(double stime);
	double getStartTime();

	void print();	

};

#endif
