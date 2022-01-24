D = 30;
maxfes = 2000;
for i = 1 : 15
	fnum = i;
	optimize_de(D, fnum, maxfes);
end
