D = 50;
maxfes = 1200;
for i = 1 : 15
	fnum = i;
	optimize_de(D, fnum, maxfes);
end
