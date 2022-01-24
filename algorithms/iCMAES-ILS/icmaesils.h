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

#ifndef ICMAESILS_H
#define ICMAESILS_H


#include "configuration.h"
using namespace std;
extern double tunec;

class ICMAESILS {

    protected:
    Configuration* config;

    public:

    ICMAESILS(Configuration* config);
	~ICMAESILS(void);

	unsigned runICMAESILS();
	vector<double> icmaes (double maxfevalsforicmaes, vector<double> mtsls1feedback);
	vector<double> ILSmtsls1(int maxmtsls1fevals, int maxiter, vector<double> icmaesfeedback);
	long double addPenalty(long double minr, long double maxr, double *psol, int dim, double getfunevals);
	bool inbound(long double min, long double max, double *ind, int num);
	double printcosttime();
	void  initialization();
	double minmaxrand();



};


#endif
