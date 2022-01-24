package cz.utb.fai.ailab;
/* 
  DEsPA Algorithm implemented in Java for solving CEC2015 benchmark
  Reference: �	Noor .H. Awad, Mostafa. Z. Ali, Robert G. Reynolds, 
  A Differential Evolution with Success-based Parameter Adaptation for 
  CEC2015 Learning-based Optimization, IEEE Congress of Evolutionary Computations, CEC 2015. 
  
  Written by: Noor Awad (noorawad1989@gmail.com)
  19Dec 2014
 */

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;
import java.text.DecimalFormat;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/*
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
*/

public class TestDE {
	static int Runs=51;
	static DescriptiveStatistics Avgerror;
	static DescriptiveStatistics Avgtime;
	
	static PrintStream file;
	static int func;
	
	static DecimalFormat exp_form = new DecimalFormat("0.00000000E0");
	
	// Change here
	static int startfunc=0;
	static int funcnums=15;
	// {10,30,50,100}
	static int dim = 10;

	static int border = 0;

	static boolean Enable_archive = false;
	static boolean Write_All_Results = true;

	// Blank workbook
	// static XSSFWorkbook workbook = new XSSFWorkbook();

	public static void main(String[] args) throws Exception {

		// System.out.println("Working Directory = " + System.getProperty("user.dir"));
		Locale.setDefault(new Locale("en", "US"));
		// System.out.println(Locale.getDefault());

		/*
		if (false) {
			return;
		}
		*/

		dim = Integer.parseInt(args[0]);
		border = Integer.parseInt(args[1]);



		int[] optims = { 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500};
	    Map<String, Object[]> data = new TreeMap<String, Object[]>();
//		XSSFSheet[] sheet=new XSSFSheet[funcnums];
		for(int j=startfunc;j<funcnums;j++)
		{
			
			double[] resultsDE=new double[2];   //hold results from DE
			
			func=j+1;
			
			int count=0;
//			sheet[j] = workbook.createSheet("fun"+func); //create a sheet for results
//			int lastRow= sheet[j].getLastRowNum(); //last row that was written so far		
			
			System.out.println("Func # "+ func+": Expected optimal: "+exp_form.format(optims[j]));
			data.put("1", new Object[] {"Fun: "+func, "Expected optimal: ", ""+exp_form.format(optims[j])}); //write the header on the new sheet
			data.put(""+data.size()+1, new Object[] {"Run#", "Error", "Elapsed time (min)"}); //write the header on the new sheet
			count+=2;
//			writeExcel(data, sheet, j, 0); //write data
			data.clear();
			//writeExcel(data, sheet, j, lastRow); //write data

			initFile(func, dim);
			Avgerror =new DescriptiveStatistics();
			Avgtime =new DescriptiveStatistics();
			for(int i=0;i<Runs;i++)
			{
				long lStartTime = System.currentTimeMillis();		
		
				DE mos=new DE(func, dim, Enable_archive, Write_All_Results, border);
				
//				lastRow= sheet[j].getLastRowNum();
				resultsDE=mos.start(Avgerror,i,file,1.0, j, data, Enable_archive, Write_All_Results);
			
				int r=i+1;
				System.out.println("Run # "+r+" : error = " + exp_form.format(Avgerror.getElement(i)));
				
				long lEndTime = System.currentTimeMillis(); 
				long difference = lEndTime - lStartTime;
				double mins=(difference/1000.0)/60.0;
				Avgtime.addValue(mins);
				//System.out.println(", Elapsed time in minutes: " + mins);
				data.put(""+data.size()+1, new Object[] {""+resultsDE[0],""+resultsDE[1],""+mins}); //write data on the new sheet
				count+=1;
//				writeExcel(data, sheet, j, count); //write data
				data.clear();
			}
			
			
			//data.put(""+data.size()+1, new Object[] {""}); //write data on the new sheet
			
			double meanerror=Avgerror.getMean();
			System.out.println("Avg error for "+ + Runs+" runs is: " + exp_form.format(meanerror));
			
			data.put(""+data.size()+1, new Object[] {"Avg error for "+Runs+" runs is: ", ""+exp_form.format(meanerror)}); //write data on the new sheet
			//System.out.println(">>>>>>size is now: " + data.size());
			//data.put(""+data.size()+1, new Object[] {""}); //write data on the new sheet
			////////////////////////////////file.println();
			////////////////////////////////file.println("Avg error for "+Runs+" runs is: " + meanerror);
		
			double meantime=Avgtime.getMean();
			System.out.println("Avg elapsed time for "+ Runs+" runs is: " + meantime);
			System.out.println("*********************");
			data.put(""+data.size()+1, new Object[] {"Avg elapsed time for "+ Runs+" runs is: ",""+meantime}); //write data on the new sheet
			//System.out.println(">>>>>>size is now: " + data.size());
			////////////////////////////////////////file.println("Avg elapsed time for "+ Runs+" runs is: " + meantime);
			
			//System.out.println(">>>>"+data.size());
			count+=2;
//			writeExcel(data, sheet, j, count); //write data
			data.clear(); //clear for the new sheet
			
		}
		//closeExcel();
	}///main
	
	
	
	public static void initFile(int func, int dim) {		
		try {
			// create data directory
			String dirname1="AllResults for DEsPA";
			File dir1 = new File(dirname1);
			
			if (!(dir1.exists()&& dir1.isDirectory()))
				dir1.mkdir(); // create when not existed

			// log file
			try {
				file =  new PrintStream(new FileOutputStream(dir1+"/DEsPA_"+func+"_"+dim+".txt"));
			}
			catch (FileNotFoundException e) {
			  	System.out.println("file log.txt failed to create");
			  	
			}
		} catch (Exception e) {
			System.out.println("Errors during creating dir 'log'.");
	}
	} ///initFile

	/*
	public static void writeExcel(Map<String, Object[]> data, XSSFSheet[] sheet, int j, int count){
		//Iterate over data and write to sheet
        Set<String> keyset = data.keySet();
        
        int rownum = count; //lastRow;
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
	
	/*
	public static void closeExcel(){
		try
        {
            //Write the workbook in file system
            FileOutputStream out = new FileOutputStream(new File("Results Sheet"+".xlsx"));
            workbook.write(out);
            out.close();
            System.out.println("Results were written successfully on disk....xlsx");
        } 
        catch (Exception e) 
        {
            e.printStackTrace();
        }
	}///closeExcel
	*/
	
}
