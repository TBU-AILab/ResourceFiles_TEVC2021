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

#include "rng.h"
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>

using namespace std;

gsl_rng* RNG::R = gsl_rng_alloc(gsl_rng_env_setup());
gsl_permutation* RNG::P = gsl_permutation_alloc(1);

void RNG::initializeRNG(unsigned long int rngSeed){	
    gsl_rng_set(RNG::R, rngSeed);   
}

double RNG::randVal(double min,double max){
	return gsl_ran_flat( RNG::R, min, max);
}

void RNG::deallocateRNG(){
	 gsl_rng_free( RNG::R );
}

void RNG::deallocatePermutation(){
	 gsl_permutation_free( RNG::P );
}
