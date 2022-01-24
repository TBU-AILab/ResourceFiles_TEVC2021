D = 10;
maxfes = 6000;
for i = 1 : 15
	fnum = i;
	optimize_de(D, fnum, maxfes);
end
