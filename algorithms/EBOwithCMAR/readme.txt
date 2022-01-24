This zip folder contains following folders and files:

1. data for email: This folder contains the result of EBOwithCMAR.

2. Result_Record: This folder contains the new result of EBOwithCMAR using 32-bit MATLAB.
   Performance of EBOwithCMAR on test problem 2 is different from 64-bit MATLAB.

3. MATLAB files:
i) bestt
ii) EBO
iii) EBO_bin
iv) gnR1R2
v) han_boun
vi)  init_cma_par
v) Introd_Par
vi) LS2
vii) main_loop
viii) Scout
ix) updateArchive


To run the code:

 Extract EBOwithCMAR.rar.
 Run main_loop.m.
 You can change the dimension (Par.n) in Introd_Par.m to 10 or 30 or
50 or 100.

Results:
 The detailed results (formatted as requested by the organizers) as well as
seeds will be located in the ''Results_Record'' folder. Note that if you
do not want to save these values, simply set Par.Printing=0 defined in
Introd_Par.m.
