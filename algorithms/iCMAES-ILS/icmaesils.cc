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
#include "icmaesils.h"
#include "configuration.h"
#include <string>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <algorithm>
#include <iostream>
#include <vector>
#include <gsl/gsl_math.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_linalg.h>
#include <math.h>
#include <gsl/gsl_statistics.h>
#include <cassert>
#include <cmath>
#include <limits>
#include <cstdio>
#include <cstdlib>
#include <string.h>
#include <float.h>
#include <stdio.h>
#include <math.h>
#include <malloc.h>
#include <sys/time.h>
#include <sys/resource.h>

extern "C" {
#include "cmaes_interface.h"
extern void   random_init( random_t *, long unsigned seed );
extern void   random_exit( random_t *);
extern double random_Gauss( random_t *);
extern double random_Uniform(random_t *);
double const * cmaes_SetMean(cmaes_t *, const double *xmean);
}

//Tomo Kontrola
void testBoundILS(long double *ind, int num);
double PSO_mod(double a, double b);
void printPop(double* const* pop, int popSize, int dim);
void copyPop(double* const* popIn, double** popOut, int popSize, int dim);

bool improve=true;
double tunec;
int relaynum;
vector<double> mtsls1solfitness;
vector<double> icmaessolfitness;
vector<double> icmaes_train_reward;
vector<double> mtsls1_train_reward;
void test_func(long double *, long double *,int,int,int);
long double *OShift,*M,*y,*z,*x_bound;
int ini_flag=0,n_flag,func_flag;
long double *f,*x;
vector<vector<double> > matrix;
double initevalscout=0;
double initbestvalue=FLT_MAX;
vector<double> initkeepbestx;

using namespace std;


ICMAESILS::ICMAESILS(Configuration* config){
	this->config = config;
	tunea=config->gettunea();
    tuneb=config->gettuneb();
    tunec=config->gettunec();
    tuned=config->gettuned();
    tunee=config->gettunee();
    tunef=config->gettunef();
    tuneg=config->gettuneg();
    globleseed=config->getRNGSeed();
    x=(long double *)malloc(1*config->getProblemDimension()*sizeof(long double));
    f=(long double *)malloc(sizeof(long double)*1);
}

ICMAESILS::~ICMAESILS(void) {}

unsigned ICMAESILS::runICMAESILS()
{
    unsigned dim = config->getProblemDimension();
	mtsls1solfitness.resize(dim+2);
	icmaessolfitness.resize(dim+2);
	icmaes_train_reward.resize(dim+2);
	mtsls1_train_reward.resize(dim+2);

	initialization();   /* initialization */
	for(int i = 0; i < dim; i++){
		 mtsls1solfitness[i]=initkeepbestx[i];
	}

    // competition phase

///	printf("START ICMA PHASE\n");

	for(relaynum = 0; relaynum < 1; relaynum++){
	   icmaes(10000*dim*config->getlearn_perbudget(), mtsls1solfitness);
	}
	
//	printf("START ILS PHASE\n");
	
    icmaes_train_reward = icmaessolfitness;
	for(int i = 0; i < dim; i++){
				 icmaessolfitness[i]=mtsls1solfitness[i];
	}
	ILSmtsls1(10000*dim*config->getlearn_perbudget(), config->getmtsls1per_ratedim()*dim, icmaessolfitness);
	mtsls1_train_reward = mtsls1solfitness;

	//printf("START FINAL PHASE\n");

    // deployment phase
	if(icmaes_train_reward[dim]>mtsls1_train_reward[dim])
	{
		ILSmtsls1(10000*dim*(1-config->getlearn_perbudget()*2), config->getmtsls1per_ratedim()*dim, mtsls1_train_reward);
	}
	else
	{
		icmaes_train_reward[dim+1]=mtsls1_train_reward[dim+1];
		icmaes(10000*dim*(1-config->getlearn_perbudget()*2),icmaes_train_reward);
	}

	//printf("END PHASE\n");


	free(x);
	free(f);
	free(y);
	free(z);
	free(M);
	free(OShift);
	free(x_bound);
	
	return 0;

}

vector<double> ICMAESILS::icmaes (double maxfevalsforicmaes, vector<double> mtsls1feedback)
{


	  cmaes_t evo;
	  double *const*pop;
	  
	  //historicka pop kvuli Halving Boundary
	  double** popHis = NULL;
	  int popSize;
	  //popHis = (double*) = malloc(50*)
	  
	  
	  double *fitvals;
	  double fbestever=0;
	  double *xbestever=NULL;
	  double fmean;
	  int i, irun, lambda = 0, countevals = 0;
	  int maxevals;
	  char const * stop;
	  long double long_fitness;
	  int dim=config->getProblemDimension();
	  double xinit[dim],stddev[dim];
	  maxevals=maxfevalsforicmaes;
	  int countmaxevalsforicmaes;
	  int first = 1;
	  double icmaeskeepbestxk[dim];
	  double liaobestvalue;
	  double liaoevalscount;
	  if(relaynum == 0)
	  {
		       liaobestvalue= initbestvalue;
		  	   liaoevalscount=initevalscout;
		  	   countmaxevalsforicmaes=maxevals;
	  }
	  else
	  {
		   liaobestvalue=mtsls1feedback[dim];
		   liaoevalscount=mtsls1feedback[dim+1];
		   countmaxevalsforicmaes=maxevals+mtsls1feedback[dim+1];
	  }

	  double liaofirstforxinit;
	  for (irun = 0; liaoevalscount < countmaxevalsforicmaes; ++irun)
	  {
	      if(irun == 0)
	      {
	    	  for (int j = 0; j < dim; j++) {
				  xinit[j]=mtsls1feedback[j];
				  icmaeskeepbestxk[j]=xinit[j];
	    	  }
		  }
	      else
	      {
	    	  for (int j = 0; j < dim; j++) {
	    	  	 xinit[j]=(config->getMaxInitRange()-config->getMinInitRange())*gsl_rng_uniform (RNG::R)+config->getMinInitRange();
	    	  }
	      }
	      for (int j = 0; j < dim; j++) {
		  stddev[j] = tunec*(config->getMaxInitRange()-config->getMinInitRange());
	      }
	      for(int n=0;n<dim;n++)
		  {
				x[n]=xinit[n];
		  }

		  test_func(x, f, dim,1,config->getProblemID());
	      liaofirstforxinit = f[0];
	      liaoevalscount++;
	      if( liaobestvalue - liaofirstforxinit>1e-30){
			   if(liaoevalscount<=countmaxevalsforicmaes)
			   {
				   liaobestvalue=liaofirstforxinit;
				   if(liaobestvalue<=1e-8)
				   {
					   printf("%.0f %le\n",liaoevalscount,liaobestvalue);
				   }
				   else{
					   printf("%.0f %le\n",liaoevalscount,liaobestvalue);
				   }
				   for (int j = 0; j < dim; j++) {
					   icmaeskeepbestxk[j]=xinit[j];
				   }
			   }
		  }

	      string filename = "initials.par";
		  fitvals = cmaes_init(&evo, config->getProblemDimension(), xinit, stddev, 0, lambda, filename.c_str());
	      lambda = (int) cmaes_Get(&evo, "lambda");
	      setbuf(stdout, NULL);

	     //init popHis a deinit
	     /*
				popSize = cmaes_Get(&evo, "popsize");
				printf("here INIT pop=%d | dim = %d\n", popSize, dim);
			  popHis = (double**)malloc(sizeof(double*) * popSize);
			  for(int iii=0;iii<popSize;iii++) {
				popHis[iii] = (double*)malloc(sizeof(double) * dim);
			  }
			  bool myInit = true;
			  //printf("HERE\n");
			  */


	     while(!(stop=cmaes_TestForTermination(&evo)))
	     {
			  //ze by toto byly puvodni hodnoty?
			  //printPop(pop, cmaes_Get(&evo, "popsize"), dim);
			  
			  /*
			  if(myInit) {
				copyPop(pop, popHis, 1, dim);
				myInit = false;
			  } else {
				copyPop(pop, popHis, (int)cmaes_Get(&evo, "popsize"), dim);
			  }
			  */
			  pop = cmaes_SamplePopulation(&evo);
			  //printf("here INIT pop=%d | dim = %d\n", (int)cmaes_Get(&evo, "popsize"), dim);
			  //printPop(pop, cmaes_Get(&evo, "popsize"), dim);
			  //printf("------------------------\n");
			  
			  
			  for (i = 0; i < cmaes_Get(&evo, "popsize"); ++i) {

					 //-------------------------------------------------------------------------------
					 inbound(config->getMinInitRange(), config->getMaxInitRange(), pop[i], dim);
					 //-------------------------------------------------------------------------------
					 for(int n=0;n<dim;n++)
					 {

							x[n]=pop[i][n];
					 }
					 test_func(x, f, dim,1,config->getProblemID());
					 long_fitness=f[0];
					 liaoevalscount++;

					 if (long_fitness <= FLT_MAX ) {
						  fitvals[i] = long_fitness;
					 }
					 else {
							fitvals[i] = FLT_MAX;
					 }

					if( liaobestvalue - fitvals[i]>1e-30){
						 if(liaoevalscount<=countmaxevalsforicmaes)
						 {
							liaobestvalue = fitvals[i];
							if(liaobestvalue<=1e-8)
							{
								printf("%.0f %le\n",liaoevalscount,liaobestvalue);
							}
							else{
								printf("%.0f %le\n",liaoevalscount,liaobestvalue);
							}
							for (int j = 0; j < dim; j++) {
							   icmaeskeepbestxk[j]=pop[i][j];
							}
						}
					}

		       }

			  cmaes_UpdateDistribution(&evo, fitvals);
			  fflush(stdout);
		
			  
		
		}

		lambda = tuned * cmaes_Get(&evo, "lambda");
		if (lambda>200)
		{
		  lambda=200;
		}
		
		//free popHis
		/*
			  for(int iii=0;iii<popSize;iii++) {
				free(popHis[iii]);
			  }
			  free(popHis);
			  popHis = NULL;
			  */
		
        cmaes_exit(&evo);
	}
	for (int j = 0; j < dim; j++)
	{
		icmaessolfitness[j]=icmaeskeepbestxk[j];
	}
	icmaessolfitness[dim]=liaobestvalue;
	icmaessolfitness[dim+1]=countmaxevalsforicmaes;
	return icmaessolfitness;
}

vector<double> ICMAESILS::ILSmtsls1(
			int maxmtsls1fevals,
			int maxiter,
			vector<double> icmaesfeedback
	        )
{
         int dim=config->getProblemDimension();
		cmaes_t evols;
		double liaobestmtsls1value;
		double liaoevalsmtsls1count;

		liaobestmtsls1value= icmaesfeedback[dim];
		liaoevalsmtsls1count=icmaesfeedback[dim+1];
		maxmtsls1fevals=maxmtsls1fevals+icmaesfeedback[dim+1];

		double lsmin=config->getMinInitRange();
		double lsmax=config->getMaxInitRange();
		double xk[dim];
		double mtsls1keepbestxk[dim];

		for (int i = 0; i < dim; i++) {

			  xk[i]=icmaesfeedback[i];
			  mtsls1keepbestxk[i]=xk[i];
		}
		double liaofirstforxinitmtsls1;

		for(int n=0;n<dim;n++)
		{

				x[n]=xk[n];
		}
		
	testBoundILS(x, dim);	//TOMo kontrola
    	test_func(x, f, dim,1,config->getProblemID());

	    liaofirstforxinitmtsls1 = f[0];
	    liaoevalsmtsls1count++;
	    if( liaobestmtsls1value - liaofirstforxinitmtsls1>1e-30){
			  liaobestmtsls1value = liaofirstforxinitmtsls1;
			  printf("%.0f %le\n",liaoevalsmtsls1count,liaofirstforxinitmtsls1);
	    }

	    double s;
	    s=config->getmtsls1_initstep_rate()*(lsmax-lsmin);

	do{

		int iterun=0;
	    vector<int> conbef;
		bool convergence = false;
		double acceptbefore=liaobestmtsls1value;
		do
		{
			if(liaoevalsmtsls1count<maxmtsls1fevals)
			{
			   if(improve == false)
			   {

				  s=s/(long double)(2);

				  if(s<1e-20)
				  {

					 conbef.push_back(liaobestmtsls1value);
					 if(conbef.size()>=2)
					 {
						 if(abs(conbef.back()-conbef[conbef.size()-1])<1e-20)
						 {
							 convergence=true;
						 }
					 }
					 s=((0.6-0.3)*gsl_rng_uniform (RNG::R)+0.3)*(lsmax-lsmin);
				  }
			   }
			   improve=false;
			   for(int i = 0; i < dim; i++)
			   {
				   long double before1;
				   for(int n=0;n<dim;n++)
				   {
						x[n]=xk[n];
				   }
				   testBoundILS(x, dim);	//TOMo kontrola
				   test_func(x, f, dim,1,config->getProblemID());
				   before1=f[0]+addPenalty(lsmin, lsmax, xk, dim, liaoevalsmtsls1count);

				   liaoevalsmtsls1count++;
				   if( liaobestmtsls1value - before1>1e-30){
					   if(liaoevalsmtsls1count<=maxmtsls1fevals)
					   {
	                       liaobestmtsls1value = before1;
						   if(liaobestmtsls1value<=1e-8)
						   {
							   printf("%.0f %le\n",liaoevalsmtsls1count,liaobestmtsls1value);
						   }
						   else{
						   printf("%.0f %le\n",liaoevalsmtsls1count,liaobestmtsls1value);
						   }

						   for (int i = 0; i < dim; i++) {
								 mtsls1keepbestxk[i]=xk[i];
						   }
					   }
				   }

				   xk[i]=xk[i]-s;
				   long double after1;
				   for(int n=0;n<dim;n++)
				   {
							x[n]=xk[n];
				   }
				   testBoundILS(x, dim);	//TOMo kontrola
				   test_func(x, f, dim,1,config->getProblemID());
				   after1=f[0]+addPenalty(lsmin, lsmax, xk, dim, liaoevalsmtsls1count);

				   liaoevalsmtsls1count++;
				   if( liaobestmtsls1value - after1>1e-30){
					   if(liaoevalsmtsls1count<=maxmtsls1fevals)
					   {
	                                           liaobestmtsls1value = after1;

						   if(liaobestmtsls1value<=1e-8)
						   {
							   printf("%.0f %le\n",liaoevalsmtsls1count,liaobestmtsls1value);
						   }
						   else{
						   printf("%.0f %le\n",liaoevalsmtsls1count,liaobestmtsls1value);
						   }
						   for (int i = 0; i < dim; i++) {
								 mtsls1keepbestxk[i]=xk[i];
						   }
					   }
				   }

				   if(abs(after1-before1)<=1e-20)
				   {
					   xk[i]=xk[i]+s;

				   }
				   else
				   {
					   if(after1-before1>1e-20)
					   {
						   xk[i]=xk[i]+s;
						   long double before2=before1;
						   xk[i]=xk[i]+0.5*s;
						   long double after2;

						   for(int n=0;n<dim;n++)
							 {

									x[n]=xk[n];
							 }
							 testBoundILS(x, dim);	//TOMo kontrola
							 test_func(x, f, dim,1,config->getProblemID());
						   after2=f[0]+addPenalty(lsmin, lsmax, xk, dim, liaoevalsmtsls1count);

						   liaoevalsmtsls1count++;
						   if( liaobestmtsls1value - after2>1e-30){
								   if(liaoevalsmtsls1count<=maxmtsls1fevals)
								   {
	                                                                   liaobestmtsls1value = after2;
									   if(liaobestmtsls1value<=1e-8)
									   {
										   printf("%.0f %le\n",liaoevalsmtsls1count,liaobestmtsls1value);
									   }
									   else{
									   printf("%.0f %le\n",liaoevalsmtsls1count,liaobestmtsls1value);
									   }
									   for (int i = 0; i < dim; i++) {
											 mtsls1keepbestxk[i]=xk[i];
									   }
								   }
						   }
						   if(after2>=before2||(0<before2-after2<=1e-20))
						   {
							   xk[i]=xk[i]-0.5*s;

						   }
						   else
						   {

							   improve=true;
						   }
					   }
					   else
					   {

						   improve=true;
					   }

				   }
			   }
			   iterun++;
			}
			else
			{
				break;
			}
		}while(iterun<maxiter && convergence == false);
		if(liaoevalsmtsls1count<maxmtsls1fevals)
		{
			if(acceptbefore-liaobestmtsls1value < 1e-20)
			{
				for (int i = 0; i < dim; i++) {
					double srand= (lsmax-lsmin)*gsl_rng_uniform (RNG::R)+lsmin;
	                xk[i] = srand+ ((1-config->getmtsls1_iterbias_choice())*gsl_rng_uniform (RNG::R)+config->getmtsls1_iterbias_choice())*(mtsls1keepbestxk[i]-srand);
				}
			}

	        s=config->getmtsls1_initstep_rate()*(lsmax-lsmin);

		}
		else
		{
			break;
		}

	}while(liaoevalsmtsls1count<maxmtsls1fevals);
	  for (int i = 0; i < dim; i++) {
	      mtsls1solfitness[i]=mtsls1keepbestxk[i];
	  }
	  mtsls1solfitness[dim]=liaobestmtsls1value;
	  mtsls1solfitness[dim+1]=maxmtsls1fevals;
	  return mtsls1solfitness;
}

void copyPop(double* const* popIn, double** popOut, int popSize, int dim) {
	
	printf("here pop=%d | dim = %d\n", popSize, dim);
	
	for(int i=0;i<popSize;i++) {
		for(int j=0;j<dim;j++) {
			
			//printf("\tin[%d][%d]=%f\tout=%f\n",i,j,popIn[i][j],popOut[i][j]);
			printf("\tin[%d][%d]=",i,j);
			printf("%f\tout=%f\n",popIn[i][j],popOut[i][j]);
		
			popOut[i][j] = popIn[i][j];
		}
	}
}

void printPop(double* const* pop, int popSize, int dim) {
	printf("\tPrintuji POP\n");
	for(int i=0;i<dim;i++) {
		printf("%f ", pop[0][i]);
	}
	printf("\n");
}

void testBoundILS(long double *ind, int num) {
	
	//z casovych duvodu preskocime
	return ;
	
	//z definice CECu
	long double min = -100;
	long double max =  100;
	bool check = false;
	  int i;
	  for (i = 0; i < num ; i++) {
		  if (ind[i] > max)
		  {
		  //ind[i] = max;
			check = true;

		  }
		  else if (ind[i] < min)
		  {	
		  //ind[i] = min;
			check = true;
		  }
	  }
	  
	  if(check) {
		//printf("\t------------  VELKY SPATNY - JSEM outOfBounds v ILS  ----------------\t\n");
	  }
}


bool ICMAESILS::inbound(long double min, long double max, double *ind, int num) {

	  static bool _myInit = true;
	  if(_myInit) {	
		//printf("\t%lu\t\n",config->getBound());
		_myInit = false;
	  }
	//nacteni typu bound
	unsigned long _bound = config->getBound();

	if(_bound == 0) {
		//vychozi
		  bool check = true;
		  int i;
		  for (i = 0; i < num ; i++) {
			  if (ind[i] > max)
			  {
					 ind[i] = max;
				

			  }
			  else if (ind[i] < min)
			  {
				 ind[i] = min;
				 

			  }
		  }
		  return check;
	  }
	  
	  if(_bound == 1) {
		for (int i = 0; i < num ; i++) {
			if (ind[i] > max) {
				ind[i] = max;
			}
			else if (ind[i] < min)
			{
				ind[i] = min; 
			}
		}
		return true;
	  }
	  if(_bound == 2) {
		for (int i = 0; i < num ; i++) {
			if (ind[i] > max) {
				ind[i] = minmaxrand();
			}
			else if (ind[i] < min)
			{
				ind[i] = minmaxrand(); 
			}
		}
		return true;
	  }
	  if(_bound == 3) {
		//periodic
		//protoze fmod je kreten....
		//printf("\tEntering...\t");
		for (int i = 0; i < num ; i++) {
			ind[i] = min + PSO_mod(ind[i] - max, max - min);
			//ind[i] = min + fmod(ind[i], max - min);
			/*
			if((ind[i] < min || ind[i] > max) || true) {
				if(ind[i]<0) {
					//printf("%f\t%f\t = %f\n", i, b, -(-100 + fmod(-i,b)));
					ind[i] = -(-100 + fmod(-ind[i], 200));
				} else {
					//printf("%f\t%f\t = %f\n", i, b, -100 + fmod(i,b));
					ind[i] = -100 + fmod(ind[i], 200);
				}
			}
			*/
		}
		//printf("\tE... Exiting\t\n");
		return true;
	  }
	  if(_bound == 4) {
		//reflection
		for (int i = 0; i < num ; i++) {
			if (ind[i] > max) {
				ind[i] = max - (ind[i] - max);
			}
			else if (ind[i] < min)
			{
				ind[i] = min + (min - ind[i]);
			}
		}
		return true;
	  }
	  return true;
	  
}

double PSO_mod(double a, double b)
{
	if (b < 0) //you can check for b == 0 separately and do what you want
		return PSO_mod(a, -b);
	double ret = fmod(a, b);//a % b;
	if (ret < 0)
		ret += b;
	return ret;
}

long double ICMAESILS::addPenalty(long double minr, long double maxr,  double *psol, int dim, double getfunevals){
          int i;
          long double penalty = 0.0;
          for(i = 0; i < dim; i++){
            if(psol[i] < minr){

              penalty+= fabs(psol[i] - minr) * fabs(psol[i] - minr);
            }
            if(psol[i] > maxr){

              penalty+= fabs(psol[i] - maxr) * fabs(psol[i] - maxr);
            }
          }

          return penalty * getfunevals;
}
double ICMAESILS::printcosttime(){
	double etime;
	static struct timeval tp;
	gettimeofday( &tp, NULL );
   	etime =(double) tp.tv_sec + (double) tp.tv_usec/1000000.0;
   	return etime-config->getStartTime();
}

double ICMAESILS::minmaxrand()
{
     return double(config->getMinInitRange()+(config->getMaxInitRange()-config->getMinInitRange())*gsl_rng_uniform (RNG::R));
}


void  ICMAESILS::initialization()
{
	initkeepbestx.resize(config->getProblemDimension());
	unsigned int intipopsize=1*config->getProblemDimension();
	matrix.resize(intipopsize);
	for(unsigned int i=0;i<intipopsize;i++)
	{
		 matrix[i].resize(config->getProblemDimension());
		 for(unsigned a=0;a<config->getProblemDimension();a++)
		 {
			 matrix[i][a]=minmaxrand();
			 x[a]=matrix[i][a];
		 }
		 test_func(x, f, config->getProblemDimension(),1,config->getProblemID());
		 initevalscout++;
		 matrix[i].push_back(f[0]);
		 if(initbestvalue - matrix[i][config->getProblemDimension()]>1e-30){
					initbestvalue = matrix[i][config->getProblemDimension()];
				    printf("%.0f %le\n",initevalscout,initbestvalue);
					for (int j = 0; j < config->getProblemDimension(); j++) {
					   initkeepbestx[j]=matrix[i][j];
					}
		 }
	}
}
