/* 
  DEsPA Algorithm implemented in Java for solving CEC2015 benchmark
  Reference: �	Noor .H. Awad, Mostafa. Z. Ali, Robert G. Reynolds, 
  A Differential Evolution with Success-based Parameter Adaptation for 
  CEC2015 Learning-based Optimization, IEEE Congress of Evolutionary Computations, CEC 2015. 
  
  Written by: Noor Awad (noorawad1989@gmail.com)
  19Dec 2014
 */
package cz.utb.fai.ailab;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import java.io.PrintStream;
/*
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
*/

public class DE {
	
	int border;
	
	int FEs;
	int genNo;
	int func;
	int dim;
	int FEsMax;
	int NP;
	int mem_pos;
	double p_min;
	int suc_par;
	
	double MCR; 
	double MF;
	double F,CR;
	double Diff;
	
	ArrayList<Solution> popualtionspace;
	
	ArrayList<Solution> A;
	testfunc tf ;
	
	public static Random rnd;
	
	DescriptiveStatistics SF;
	DescriptiveStatistics SFsquar;
	DescriptiveStatistics SCR;
	DescriptiveStatistics frec;
	
	int mem_size;
	double []mem_F;
	double []mem_CR;

	double glo_err=1e-8;
	long lStartTime;
	
	int NP_Threshold; // Max=init
	int NP_Min=4;
	
	int countPrint=0;

	int archive_size;
	int archive_idx=0;
	double archive_ratio=1.4;
	ArrayList<Solution> archive;
	
	public static double PSO_mod(double a, double b) {
		if (b < 0) // you can check for b == 0 separately and do what you want
			return PSO_mod(a, -b);
		double ret = a % b;// a % b;
		if (ret < 0)
			ret += b;
		return ret;
	}

	int saturation_count=0;
	int p_num;
	public void initializeParameters(int func, int dim)
	{
		// Variable parameters
		 this.func=func;
		 this.dim=dim;
		 FEsMax=10000*dim;
		 FEs=0;
		 NP=NP_Min;//540;
		 NP_Threshold=15*dim;  
		 genNo=FEsMax/NP;
		 MF=0.5;
		 MCR=0.5;
		 F=0.5;
		 CR=0.9;
		 p_min= 2.0/NP;
		 suc_par=0;
		 
		 SF = new DescriptiveStatistics();
		 SFsquar = new DescriptiveStatistics();
		 SCR = new DescriptiveStatistics();
		 frec = new DescriptiveStatistics();
		 
		 mem_size=10;
		 mem_F = new double[mem_size];
		 mem_CR = new double[mem_size];
		 
		 for(int i=0;i<mem_size;i++)
		 {
			 mem_F[i]=0.5;
			 mem_CR[i]=0.5;
		 }
		 
		 mem_pos=0;
		 
		 archive_size = (int)Math.round(archive_ratio * NP);
	}
	
	public void ComputeT1() throws Exception
	{
		dim=30;
		double []X=new double[dim];
		double []fitness=new double[1];
		
		for (int j=0;j<dim;j++)
			X[j] = Problem.LB + Math.random()*(Problem.UB - Problem.LB);
		
		
		for(int i=0;i<200000;i++)
			tf.test_func(X, fitness, dim,1,1);
	}
	
	public DE()
	{
		tf = new testfunc ();
		initializeBoundaries();
	}
	
	public DE(int func, int dim,  boolean Enable_archive, boolean Write_All_Results, int border)
	{
		this.border = border;
		
		popualtionspace=new ArrayList<Solution>();
		A=new ArrayList<Solution>();
		archive=new ArrayList<Solution>();
		
		rnd=new Random();
		
		initializeParameters(func, dim);
		
		initializefunc(func, dim);	
	}
	
	public void initializeBoundaries()
    {
		Problem.LB=-100; Problem.UB=100;
    }
	
	
	public void initializefunc(int numFunction, int dim)
	{
		tf = new testfunc ();
		 
		Problem.dimension=dim;
		initializeBoundaries();
		
		int[] optims = { 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500};
		
		Problem.optimum=optims[numFunction-1];
	}
	
	// Needed
	public void initPopulation(PrintStream file, boolean Write_All_Results) throws Exception
	{
		double []X= new double[NP*dim];
		double []f= new double[NP];
		
		for(int i=0;i<NP;i++)
		{
			Solution Individual = new Solution();
			for (int j=0;j<Problem.dimension;j++)
			{
				Individual.X[j] = ((Problem.UB - Problem.LB) * Math.random()) + Problem.LB;
				X[i*dim+j]=Individual.X[j];
			}
			popualtionspace.add(Individual);
		}
		
		tf.test_func(X, f, dim,NP,func);
		
		for(int i=0;i<NP;i++)
		{
			popualtionspace.get(i).fitness[0]=f[i];
			int FE=i+1;
			printAllResults(FE, popualtionspace.get(i), file, Write_All_Results);
		}	
	}
	
	public Solution best(ArrayList<Solution> popualtion )
	{
		int min=0;
		for(int i=1;i<popualtion.size();i++)
			if(popualtion.get(i).fitness[0] < popualtion.get(min).fitness[0] )
				min=i;
		return popualtion.get(min);	
	}
	
	public Solution worst()
	{
		int max=0;
		for(int i=1;i<NP;i++)
			if(popualtionspace.get(i).fitness[0] > popualtionspace.get(max).fitness[0] )
				max=i;
		return popualtionspace.get(max);	
	}
	
	ArrayList<Integer> randInt(int size, int r_Indx, int not, boolean flag)
	{
		//define ArrayList to hold Integer objects
	     ArrayList<Integer> numbers = new ArrayList<Integer>();
	     ArrayList<Integer> outIndx = new ArrayList<Integer>();
	     
	     // When external archive is used
		if (flag == true)
		{
			int r1, r2;
			  
			do {
			    r1 = (int)(Math.random() * size);
			} while (r1 == not);
			do {
			    r2 = (int)(Math.random() * (size + archive_idx));
			} while ((r2 == not) || (r2 == r1));
			
			if (r2 >= size)
			{
				r2=r2-size;
			}
			
			if(r2 == size)
				r2=r2-1;
				
			 outIndx.add(r1);
			 outIndx.add(r2);
		}
		else
		{
	     for(int i = 0; i < size; i++)
	     {
	    	 if (i==not)
	    		 continue;
	    	 numbers.add(i);
	     }
	     Collections.shuffle(numbers);
//	     if(numbers.size() == 1)
//	    	 System.out.println("bug");
	     for(int j =0; j < r_Indx; j++)
	    	 outIndx.add(numbers.get(j));
		}
	     return outIndx;
	}
	
	double trimDimensionValue(double x)
	{
		if(x < Problem.LB || x > Problem.UB)
			x=Problem.LB + rnd.nextDouble()*(Problem.UB - Problem.LB);
		return x;
	}
	
	double trimDimensionValue_Middle(double x)
	{
		if(x < Problem.LB ) x=(Problem.LB + x)/2.0;
		
		if(x > Problem.UB ) x=(Problem.UB + x)/2.0;
		
		return x;
	}
	
	
	
	//Return random value with uniform distribution [0, 1)
	   double randDouble() {
	    return rnd.nextDouble() / Double.MAX_VALUE;
	  }

	   /*
	    Return random value from Cauchy distribution with mean "mu" and variance "gamma"
	    http://www.sat.t.u-tokyo.ac.jp/~omi/random_variables_generation.html#Cauchy
	  */
	   double cauchy_g(double mu, double gamma) {
			return mu + gamma * Math.tan(Math.PI*(Math.random() - 0.5));
		    }

	   /*
	    Return random value from normal distribution with mean "mu" and variance "gamma"
	    http://www.sat.t.u-tokyo.ac.jp/~omi/random_variables_generation.html#Gauss
	  */
	   double gauss(double mu, double sigma){
			return mu + sigma * Math.sqrt(-2.0 * Math.log(Math.random())) * Math.sin(2.0 * Math.PI * Math.random());
		    }

	  
	   void QuickSortforIndex(double[] arr, int fir, int lst, int[] indx) {
			double x = arr[(fir + lst) / 2];
			int i = fir;
			int j = lst;
			double temp_var = 0;
			int temp_num = 0;

			while (true) {
			    while (arr[i] < x) i++;
			    while (x < arr[j]) j--;      
			    if (i >= j) break;

			    temp_var = arr[i];
			    arr[i] = arr[j];
			    arr[j] = temp_var;

			    temp_num = indx[i];
			    indx[i] = indx[j];
			    indx[j] = temp_num;

			    i++;
			    j--;
			}

			if (fir < (i -1)) QuickSortforIndex(arr, fir, i - 1, indx);
			if ((j + 1) < lst) QuickSortforIndex(arr, j + 1, lst, indx);
		    }
	   
	// Needed   
	ArrayList<Solution> currenttobepbest_adapted_bin(ArrayList<Solution> popualtion, PrintStream file, boolean Write_All_Results, boolean Enable_archive) throws Exception
	{
		if (FEs >= FEsMax)
			return popualtion;
		
		ArrayList<Solution> pop_temp = new ArrayList<Solution>();
		
		int popSize=popualtion.size();
		int[] sorted_arr = new int[popSize];
		double[] sorted_fit = new double[popSize];
		
		 for (int i = 0; i < popSize; i++) sorted_arr[i] = i;
		 for (int i = 0; i < popSize; i++) sorted_fit[i] = popualtion.get(i).fitness[0];
		 
		 QuickSortforIndex(sorted_fit, 0, popSize - 1, sorted_arr);
		    
		
		SCR.clear();
		SF.clear();
		SFsquar.clear();
		frec.clear();
		suc_par=0;
		
		int dimSize=Problem.dimension;
		
		 //int p_num =(int)Math.round(popualtion.size() * 0.11);
		p_num =(int)Math.round(popualtion.size() * 0.11);
		// double p_var = (0.2 - p_min) * Math.random()  + p_min;
		
		double[] X_temp = new double [popSize * dim];
		double []f_temp= new double[popSize];
		
		double []Fi= new double[popSize];
		double []CRi= new double[popSize];
		
		for (int i=0;i<popSize;i++)
		{
			// Check if those two random numbers is same as index of best
			ArrayList<Integer> rndn=new ArrayList<Integer>();//=randInt(NP,1);
			rndn=randInt(popSize,2,i, Enable_archive); // true when archive is used
			
			int r1=rndn.get(0);
			int r2=rndn.get(1);
			
			int random_selected_period = (int)(Math.random()*mem_size);// randf.get(0) % mem_size; 
			MF=mem_F[random_selected_period];
			MCR=mem_CR[random_selected_period];

			 Fi[i]=0;
			do{ Fi[i]=cauchy_g(MF,0.1); }
			while(Fi[i]<=0);
			
			if(Fi[i]>1) Fi[i]=1;
		
		    CRi[i]=gauss(MCR,0.1);
			if(CRi[i] > 1) CRi[i]=1;
			else if(CRi[i]<0.0)
				CRi[i]=0.0;

			int p_best_ind = sorted_arr[(int)(Math.random() * p_num)];
		    
		    Solution best=popualtion.get(p_best_ind);//best(popualtionspace);
		    
			// DE Mutation 
			double U[] = new double [dimSize];

			int n = (int)(Math.random() * dimSize);
			
			for (int j = 0; j<dimSize; j++) {
				if((Math.random() < CRi[i]) || (j == n))
				{
					if(r1 >= popSize || r2 >= popSize)
						System.out.println("here");
					U[j] = popualtion.get(i).X[j]+Fi[i]*(best.X[j]-popualtion.get(i).X[j])+Fi[i]*(popualtion.get(r1).X[j]-popualtion.get(r2).X[j]);
					//U[j] = trimDimensionValue_Middle(U[j]);
				}
				else
					U[j] = popualtion.get(i).X[j];	
		    }
			
			for (int j = 0; j<dimSize; j++) 
			{
				//System.out.println("here");
				//******************************************************************************************************** */
				if(border == 0 || border == 5) {
					if(U[j] < Problem.LB) U[j]=(Problem.LB+popualtion.get(i).X[j])/2.0;
					else if (U[j] > Problem.UB) U[j]=(Problem.UB+popualtion.get(i).X[j])/2.0;
				} else if(border == 1) {
					//HARD
					if(U[j] < Problem.LB) { U[j] = Problem.LB; }    
                    if(U[j] > Problem.UB) { U[j] = Problem.UB; }
				} else if(border == 2) {
					//Random
					if(U[j] < Problem.LB || U[j] > Problem.UB) { U[j] = Problem.LB + Math.random()*(Problem.UB - Problem.LB); }
				} else if(border == 3) {
					//Periodic
					U[j] = Problem.LB + PSO_mod(U[j] - Problem.UB, Problem.UB - Problem.LB);
				} else if(border == 4) {
					//Reflection
					if(U[j] > Problem.UB) {
						U[j] = Problem.UB - (U[j] - Problem.UB);
					}
					else if (U[j] < Problem.LB)
					{
						U[j] = Problem.LB + (Problem.LB - U[j]);
					}

				}
				

				//******************************************************************************************************** */
				/*
				if(U[j] < Problem.LB) U[j]=(Problem.LB+popualtion.get(i).X[j])/2.0;
				else if (U[j] > Problem.UB) U[j]=(Problem.UB+popualtion.get(i).X[j])/2.0;
				*/
//				U[j] = trimDimensionValue(U[j]);
			}

			for(int j=0;j<dim;j++)
				X_temp[i*dim+j]=U[j];
			
			Solution DEsol=new Solution();
			DEsol.X=U;
			
			pop_temp.add(DEsol);
		}
		
		tf.test_func(X_temp, f_temp, dim,popSize,func);
		
		for(int i=0;i<popSize;i++)
		{
			pop_temp.get(i).fitness[0]=f_temp[i];
			FEs++;
			
			if(pop_temp.get(i).fitness[0] == popualtion.get(i).fitness[0])
			{
				replace(popualtion.get(i), pop_temp.get(i));
			}
			
			else if(pop_temp.get(i).fitness[0] < popualtion.get(i).fitness[0])
			{
				
				frec.addValue(Math.abs(popualtion.get(i).fitness[0] - pop_temp.get(i).fitness[0]));
				SF.addValue(Fi[i]);
				SCR.addValue(CRi[i]);
				suc_par++;
				replace(popualtion.get(i), pop_temp.get(i));
				
				// For the using of external archive
				if (archive_size > 1) { 
					if (archive_idx < archive_size) {
					    archive.add(popualtion.get(i));
					    archive_idx++;  
					}
					//Delete random individual to make space for the newly inserted element
					else {
					    int rnd_idx = (int)(Math.random() * archive_size);
					    for (int j = 0; j < dim; j++) archive.get(rnd_idx).X[j] = popualtion.get(i).X[j];
					    archive.get(rnd_idx).fitness[0]=popualtion.get(i).fitness[0];
					} 
				    }
				
			}
		
			printAllResults(FEs, popualtion.get(i), file, Write_All_Results);
			
			if (FEs >= FEsMax)
				return popualtion;
		}	

		if(suc_par > 0)
		{
			//mem_F[mem_pos]=0.0;
			//mem_CR[mem_pos]=0.0;
			updateMemFandCR(suc_par);
		}
		
		
		return popualtion;
	}
	
	void printAllResults(int FEs, Solution s, PrintStream file, boolean Write_All_Results)
	{
		if (Write_All_Results){
		boolean flag = false;
		if(FEs == FEsMax*0.0001)
			flag = true;
		if(FEs == FEsMax*0.001)
			flag = true;
		if(FEs == FEsMax*0.01)
			flag = true;
		if(FEs == FEsMax*0.02)
			flag = true;
		if(FEs == FEsMax*0.03)
			flag = true;
		if(FEs == FEsMax*0.04)
			flag = true;
		if(FEs == FEsMax*0.05)
			flag = true;
		if(FEs == FEsMax*0.1)
			flag = true;
		if(FEs == FEsMax*0.2)
			flag = true;
		if(FEs == FEsMax*0.3)
			flag = true;
		if(FEs == FEsMax*0.4)
			flag = true;
		if(FEs == FEsMax*0.5)
			flag = true;
		if(FEs == FEsMax*0.6)
			flag = true;
		if(FEs == FEsMax*0.7)
			flag = true;
		if(FEs == FEsMax*0.8)
			flag = true;
		if(FEs == FEsMax*0.9)
			flag = true;
		if(FEs == FEsMax*1.0)
			flag = true;
		
		if(flag == true)
		{
			countPrint++;
			double ibfuncvalue=s.fitness[0];
			double ierror=ibfuncvalue-Problem.optimum;
			//System.out.println(FEs+" :"+ierror);
			file.print(ierror+" ");
		}
		}
	}
	
	
	
		
	
	void replace(Solution olds, Solution news)
	{
		olds.X=news.X;
		olds.fitness[0]=news.fitness[0];
	}
	

	
	double lehmer(DescriptiveStatistics SF)
	{
		double mean1=SF.getMean();
		double mean2=SFsquar.getMean();
		double meanF=mean2/mean1;
		
		return meanF;
	}
	
	double meanpow(DescriptiveStatistics DS)
	{
		double n=2;
		double sum=0.0;
		double sum2=0.0;
		for(int i=0;i<DS.getN();i++){
			sum+=Math.pow(DS.getElement(i), n);
			sum2+=DS.getElement(i);
		}
		double value=sum/sum2;


		return value;
	}
	
	double meanWA(DescriptiveStatistics DS)
	{
		double sum=0.0;
		double sum2=0.0;
		
		for(int i=0;i<DS.getN();i++){
			sum+=frec.getElement(i);
		}
		
		for(int i=0;i<DS.getN();i++){
			double wk=frec.getElement(i)/sum;
			
			sum2+=DS.getElement(i)*wk;
		}
		return sum2;
	}
	void updateFandCR()
	{
		if(SF.getN() != 0 && SCR.getN() != 0)
		{
			MF=MF*(1-0.1)+0.1*meanpow(SF);
			MCR=MCR*(1-0.1)+0.1*meanpow(SCR);
		}
	}
	
	void updateMemFandCR(int success)
	{
		double sum=0.0;
		double sum1=0.0;
		double sum2=0;
		double sum3=0;
		double sum4=0;
		
		for(int i=0;i<success;i++){
			sum+=frec.getElement(i);
			double t;
			t=frec.getElement(i);
		}
		
		//weighted mean for CR and also F
		for(int i=0;i<success;i++){
			double wk=frec.getElement(i)/sum;
			
			sum1+=SF.getElement(i)*SF.getElement(i)*wk;
			sum2+=SF.getElement(i)*wk;
			
			sum3+=SCR.getElement(i)*SCR.getElement(i)*wk;
			sum4+=SCR.getElement(i)*wk;
			
		}
		
		mem_F[mem_pos]= sum1/sum2;
		mem_CR[mem_pos]= sum3/sum4;

		mem_pos++;
		if(mem_pos >= mem_size)//mem_size)
			mem_pos=0;
	
	}
	
	public double Cauchy(double mu, double delta)
	{
		double result = mu + delta*Math.tan(Math.PI*( rnd.nextDouble() - 0.5 ));
		return result;
	}
	
	
	public void sort(Comparator<? super Solution> comparator, ArrayList<Solution> data ) {
		Collections.sort(data, comparator);
	}
	
	/*
	public static void writeExcel(Map<String, Object[]> data, XSSFSheet[] sheet, int j, int lastRow){
		//Iterate over data and write to sheet
        Set<String> keyset = data.keySet();
        
        int rownum = lastRow;
        for (String key : keyset)
        {
            Row row = sheet[j].createRow(rownum++);
            Object [] objArr = data.get(key);
            int cellnum = 0;
            for (Object obj : objArr)
            {
               Cell cell = row.createCell(cellnum++);
               if(obj instanceof String)
                    cell.setCellValue((String)obj);
                else if(obj instanceof Integer)
                    cell.setCellValue((Integer)obj);
            }
        }

	}///writeExcel
	*/
	
	// Needed
	public void IncreasePopulation(PrintStream file, boolean Write_All_Results) throws Exception
	{
		
		if(popualtionspace.size() <= NP_Threshold)
		{
			ArrayList<Solution> pop_temp= new ArrayList<Solution> ();
			
			double NP_current=popualtionspace.size();
			
			long extra=Math.round(((NP_current+NP_Threshold)/FEsMax)*FEs+NP_Min);
			//System.out.println(extra);
			
			double []X= new double[(int) extra*dim];
			double []f= new double[(int) extra];

			for(int i=0;i<extra;i++)
			{
				Solution farther = new Solution();
				for (int j=0;j<Problem.dimension;j++)
				{
					farther.X[j] = Problem.LB + rnd.nextDouble()*(Problem.UB - Problem.LB);
					X[i*dim+j]=farther.X[j];
				}
				
				pop_temp.add(farther);
				
			}
			
			tf.test_func(X, f, dim,(int) extra,func);
			FEs=FEs+(int) extra;
			
			for(int i=0;i<extra;i++)
			{
				pop_temp.get(i).fitness[0]=f[i];
				popualtionspace.add(pop_temp.get(i));
				printAllResults(FEs, pop_temp.get(i), file, Write_All_Results);
			}	
		}
		
		else
			saturation_count++;
	}
	
	// Needed
	public void ReducePopulation() throws Exception
	{
			
		int NP_current=popualtionspace.size();

		int NP_gen_next= (int)Math.round((((NP_Min - NP_Threshold) / (double)FEsMax) * FEs) + NP_Threshold);
		
		if(NP_current > NP_gen_next)
		{
		
			int minus = NP_current - NP_gen_next;
			if ((NP_current - minus) <  NP_Min) 
				minus = NP_current - NP_Min;

		sort(new ObjectiveComparator(0),popualtionspace);
		
		ArrayList<Solution> temp = new ArrayList<Solution> ();
		for(int i=0;i<NP_gen_next;i++)
			temp.add(popualtionspace.get(i));
	
		popualtionspace.clear();
		popualtionspace=temp;
		int pop_Size=popualtionspace.size();
		
		// Update archive size
		archive_size = (int)Math.round(pop_Size * archive_ratio);
		if (archive_idx > archive_size) 
			archive_idx = archive_size;
		
		// Update p value, No need for this
		p_num = (int)Math.round(pop_Size *  0.11);
		if (p_num <= 1)  p_num = 2;
		
		}
	}
	
	
	void printRest(PrintStream file, boolean Write_All_Results)
	{
		double ierror=0.0;
		if(countPrint < 17)
		{
			for(int i=countPrint+1; i<=17;i++)
				file.print(ierror+" ");
		}
		file.println();
	}
	
	public double[] start(DescriptiveStatistics Avgerror, int run, PrintStream file, Double sheet, int j, Map<String, Object[]> data, boolean Enable_archive, boolean Write_All_Results) throws Exception
	{
		 lStartTime = System.currentTimeMillis(); 
		boolean stop_inc=false;
		double[] returns=new double[2];
		
		initPopulation(file, Write_All_Results);
		
		for(int i=0;i<genNo;i++)
		{
			//Collections.shuffle(popualtionspace);
			
			if (FEs >= FEsMax)
			{
				Solution sbest=best(popualtionspace);
				double bfuncvalue=sbest.fitness[0];
				double error=sbest.fitness[0]-Problem.optimum;
				Avgerror.addValue(error);
				int iterationrun=run+1;
	
				returns[0]=iterationrun;
				returns[1]=error;
				
				printRest(file, Write_All_Results);
				return returns;
			}
			
			currenttobepbest_adapted_bin(popualtionspace, file, Write_All_Results, Enable_archive);
			
			
			Solution ibest=best(popualtionspace);
			double ibfuncvalue=ibest.fitness[0];
			double ierror=ibfuncvalue-Problem.optimum;
			//System.out.println(FEs+" "+ ierror);

			if (ierror <= Problem.errorAccuracy)
			{
				ibfuncvalue=Problem.optimum;
				ierror=ibfuncvalue-Problem.optimum;
			}
			
			if(ibfuncvalue == Problem.optimum)
			{
				Avgerror.addValue(ierror);
				int iterationrun=run+1;
				returns[0]=iterationrun;
				returns[1]=ierror;
				
				printRest(file,Write_All_Results);
				return returns ;
			}
			
		if(stop_inc == false)
			IncreasePopulation(file, Write_All_Results);
	
		if (FEs >= FEsMax-(FEsMax/4))
			{
				stop_inc= true;
				ReducePopulation();
			}
		
		}
		
		
		Solution ibest=best(popualtionspace);
		double ibfuncvalue=ibest.fitness[0];
		double ierror=ibfuncvalue-Problem.optimum;
		
		Avgerror.addValue(ierror);
		int iterationrun=run+1;
		returns[0]=iterationrun;
		returns[1]=ierror;
		
		return returns;   ///never reach here
		
		
	}
	
	

}
