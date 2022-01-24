package cz.utb.fai.ailab;


public class Solution
{
	public double[] X;
	public double[] fitness;
	
	public boolean enable;
	public boolean improve;
	public double searchRange;
	public int grade;
	
	public Solution()
	{
		X = new double[Problem.dimension];
		fitness = new double [1];
		enable = true;
		improve = true;
		
		grade = 0;
	}
	
	public Solution clone()		// To obtain a perfect copy of the Solution Object
	{
		Solution s = new Solution();
		s.X = X.clone();
		s.fitness = this.fitness;
		s.enable = this.enable;
		s.improve = this.improve;
		s.searchRange = this.searchRange;
		s.grade = this.grade;
		return s;
	}
	
	public int compareTo(Solution s)
	{
		if(this.fitness[0] < s.fitness[0]) return -1;
		else if(this.fitness[0] > s.fitness[0]) return 1;
		else
		{
			for (int i = 0; i < this.X.length; i++) 
			{
				if(this.X[i] != s.X[i]) return -2; 
			}
			return 0;
		}
	}
	
	public double distance(Solution s)
	{
		double d = 0;
		for (int i = 0; i < X.length; i++) d += Math.pow(X[i] - s.X[i],2) ;
		return Math.sqrt(d);
	}
	
	public void aff(Solution s)
	{
		this.X = s.X.clone();
		this.fitness = s.fitness;
	}
}