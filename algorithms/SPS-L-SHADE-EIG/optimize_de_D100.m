D = 100;
maxfes = 600;
for i = 1 : 15
	fnum = i;
	optimize_de(D, fnum, maxfes);
end
