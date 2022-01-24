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
#include "icmaesils.h"
#include <sys/time.h>
#include <sys/resource.h>
#include <iostream>

using namespace std;

int main( int argc, char** argv) {
	double stime;
	static struct timeval tp;

	Configuration* config = new Configuration(argc,argv);
	RNG::initializeRNG(config->getRNGSeed());

	gettimeofday( &tp, NULL );
   	stime =(double) tp.tv_sec + (double) tp.tv_usec/1000000.0;
	config->setStartTime(stime);

	ICMAESILS* icmaesils=new ICMAESILS(config);
    icmaesils->runICMAESILS(); /* runICMAESILS */

	//printf("DOSTAL JSEM SE AZ SEM\n");

	//Memory release
	RNG::deallocateRNG();
	delete icmaesils;
	delete config;
	return 0;
}
