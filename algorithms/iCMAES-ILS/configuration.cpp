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

#include "configuration.h"
#include <tclap/CmdLine.h>
#include <string>

using namespace TCLAP;
using namespace std;

	Configuration::Configuration(int argc,char** argv){
		try {  

			CmdLine cmd("iCMAESILS", ' ', "1.0");

			//**************MOJE
			ValueArg<unsigned long> boundArg("","BOUND","Boundary type",true,0,"unsigned long");
			cmd.add(boundArg);
			//**************MOJE

			ValueArg<unsigned long> seedArg("","seed","RNG seed",true,0,"unsigned long");
			cmd.add(seedArg);

			ValueArg<unsigned int> pIDArg("","problemID","Problem ID",true,0,"unsigned int");
			cmd.add(pIDArg);

			//Required dimension value
			ValueArg<unsigned int> dimArg("","dimensions","Dimensionality",true,0,"unsigned int");
			cmd.add(dimArg);

			//Required minimum value of the search range
			ValueArg<long double> minRangeArg("","minrange","Minimum value of the search range",true,0,"long double");
			cmd.add(minRangeArg);

			//Required minimum value of the search range
			ValueArg<long double> maxRangeArg("","maxrange","Maximum value of the search range",true,0,"long double");
			cmd.add(maxRangeArg);
			
			// Required parameters of gcmaes
			ValueArg<double> tuneaArg("","ttunea","ttunea",true,0,"double");
			cmd.add(tuneaArg);

			// Required parameters of gcmaes
			ValueArg<double> tunebArg("","ttuneb","ttuneb",true,0,"double");
			cmd.add(tunebArg);

			// Required parameters of gcmaes
			ValueArg<double> tunecArg("","ttunec","ttunec",true,0,"double");
			cmd.add(tunecArg);

			// Required parameters of gcmaes
			ValueArg<double> tunedArg("","ttuned","ttuned",true,0,"double");
			cmd.add(tunedArg);

			// Required parameters of gcmaes
			ValueArg<double> tuneeArg("","ttunee","ttunee",true,0,"double");
			cmd.add(tuneeArg);

			// Required parameters of gcmaes
			ValueArg<double> tunefArg("","ttunef","ttunef",true,0,"double");
			cmd.add(tunefArg);

			// Required parameters of gcmaes
			ValueArg<double> tunegArg("","ttuneg","ttuneg",true,0,"double");
			cmd.add(tunegArg);

			// Required parameters of gcmaes
			ValueArg<double> mtsls1per_ratedimArg("","mtsls1per_ratedim","mtsls1per_ratedim",true,0,"double");
			cmd.add(mtsls1per_ratedimArg);

			// Required parameters of gcmaes
			ValueArg<double> mtsls1_initstep_rateArg("","mtsls1_initstep_rate","mtsls1_initstep_rate",true,0,"double");
			cmd.add(mtsls1_initstep_rateArg);

			// Required parameters of gcmaes
			ValueArg<double> mtsls1_iterbias_choiceArg("","mtsls1_iterbias_choice","mtsls1_iterbias_choice",true,0,"double");
			cmd.add(mtsls1_iterbias_choiceArg);

			// Required parameters of gcmaes
			ValueArg<double> learn_perbudgetArg("","learn_perbudget","learn_perbudget",true,0,"double");
			cmd.add(learn_perbudgetArg);


			cmd.parse( argc, argv );
                       

			bound = boundArg.getValue();
			rngSeed = seedArg.getValue();
			problemID = pIDArg.getValue();
			problemDimension = dimArg.getValue();
			minInitRange=minRangeArg.getValue();
			maxInitRange=maxRangeArg.getValue();

			ttunea= tuneaArg.getValue();
			ttuneb= tunebArg.getValue();
			ttunec= tunecArg.getValue();
			ttuned= tunedArg.getValue();
			ttunee= tuneeArg.getValue();
			ttunef= tunefArg.getValue();
			ttuneg= tunegArg.getValue();


			mtsls1per_ratedim=mtsls1per_ratedimArg.getValue();
			mtsls1_initstep_rate=mtsls1_initstep_rateArg.getValue();
			mtsls1_iterbias_choice=mtsls1_iterbias_choiceArg.getValue();
			learn_perbudget=learn_perbudgetArg.getValue();
						
		}catch (TCLAP::ArgException &e)  // catch any exceptions
		{ std::cerr << "error: " << e.error() << " for arg " << e.argId() << std::endl; }
	}

	Configuration::~Configuration(){}

	unsigned long Configuration::getRNGSeed(){
		return rngSeed;
	}

	unsigned long Configuration::getBound() {
		return bound;
	}

	 double Configuration::gettunea(){
		return ttunea;
	}
	 double Configuration::gettuneb(){
		return ttuneb;
	}
	 double Configuration::gettunec(){
		return ttunec;
	}
	 double Configuration::gettuned(){
		return ttuned;
	}
	 double Configuration::gettunee(){
		return ttunee;
	}
	 double Configuration::gettunef(){
		return ttunef;
	}
	 double Configuration::gettuneg(){
		return ttuneg;
	}
	double Configuration::getmtsls1per_ratedim(){
		return mtsls1per_ratedim;
	}
	 double Configuration::getmtsls1_initstep_rate(){
		return mtsls1_initstep_rate;
	}
	 double Configuration::getmtsls1_iterbias_choice(){
		return mtsls1_iterbias_choice;
	}
	 double Configuration::getlearn_perbudget(){
		return learn_perbudget;
	}

	unsigned int Configuration::getProblemID(){
		return problemID;
	}

	unsigned int Configuration::getProblemDimension(){
		return problemDimension;
	}
	long double Configuration::getMinInitRange(){
		return minInitRange;
	}
	long double Configuration::getMaxInitRange(){
	    return maxInitRange;
	}

	void Configuration::setStartTime(double stime){
		startTime = stime;
	}

	double Configuration::getStartTime(){
		return startTime;
	}


	void Configuration::print(){
		cout << "Parameters:" << endl;
		cout << endl;
		cout << "rngSeed = " << rngSeed << endl;
		cout << "ttunea = " << ttunea << endl;
		cout << "ttuneb = " << ttuneb << endl;
		cout << "ttunec = " << ttunec << endl;
		cout << "ttuned = " << ttuned << endl;
		cout << "ttunee = " << ttunee << endl;
		cout << "ttunef = " << ttunef << endl;
		cout << "ttuneg = " << ttuneg << endl;
		cout << "mtsls1per_ratedim = " << mtsls1per_ratedim << endl;
		cout << "mtsls1_initstep_rate = " << mtsls1_initstep_rate << endl;
		cout << "mtsls1_iterbias_choice = " << mtsls1_iterbias_choice << endl;
		cout << "learn_perbudget = " << learn_perbudget << endl;
		cout << "problemID = " << problemID << endl;
		cout << "problemDimension = " << problemDimension << endl;
		cout << "minInitRange = " << minInitRange << endl;
		cout << "maxInitRange = " << maxInitRange << endl;


	}
