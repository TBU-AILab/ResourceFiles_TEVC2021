/*
  CEC15 Test Function Suite for Single Objective Optimization
  Jane Jing Liang 
  email: liangjing@zzu.edu.cn; liangjing@pmail.ntu.edu.cn
  Nov. 21th 2014

  Reference: 
  J. J. Liang, B. Y. Qu, P. N. Suganthan, Q. Chen, "Problem Definitions and Evaluation Criteria for the CEC 2015 Competition on Learning-based Real-Parameter Single Objective Optimization",Technical Report201411A, Computational Intelligence Laboratory, Zhengzhou University, Zhengzhou, China and Technical Report, Nanyang Technological University, Singapore, 2014.
*/

1. Run "mex -setup" and choose a proper complier (Microsoft Visual C++ 6.0 is prefered)
   Would you like mex to locate installed compilers [y]/n? y
2. Put cec15_func.cpp and input_data folder with your algorithm in the same folder. Set this folder as 	the current path.
3. Run the following command in Matlab window:
   mex cec15_func.cpp -DWINDOWS
4. Then you can use the test functions as the following example:
   f = cec15_func(x,func_num); 
   here x is a D*pop_size matrix.
5. main.m is an example test code with PSO algorithm.


