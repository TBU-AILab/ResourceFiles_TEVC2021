package cz.utb.fai.ailab;
public abstract class Problem 
{
	public static enum type{MIN,MAX,APPROX};
	
	public static int dimension = 10;
	public static double LB = -100;
	public static double UB = 100;
	public static double errorAccuracy = 1E-8;
	public static double optimum = 0;
}
