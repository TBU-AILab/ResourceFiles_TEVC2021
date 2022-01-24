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

#ifndef RNG_H
#define RNG_H

#include <gsl/gsl_rng.h>
#include <gsl/gsl_permutation.h>

class RNG{
public:
static gsl_rng* R;
static gsl_permutation* P;
static void initializeRNG( unsigned long int rngSeed );
static double randVal(double min,double max);
static void deallocateRNG();
static void deallocatePermutation();
};

#endif
