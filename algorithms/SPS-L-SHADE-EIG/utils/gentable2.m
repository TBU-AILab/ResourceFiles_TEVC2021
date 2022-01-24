function gentable2(metafilename)
load(metafilename);
filenames_o = filenames;
nA = numel(filenames_o);

for i = 1 : nA
	load(filenames_o{i});
	
	[nP, nR, nF] = size(allfvals); %#ok<*NODEF>
	for j = 1 : nF
		fbias = j * 100;
		allfvals(:, :, j) = allfvals(:, :, j) - fbias; %#ok<*AGROW>
	end
	allfvals(allfvals <= 1e-8) = 0;
	
	for j = 1 : nF
		txtfilename = sprintf('%s_%d_%d.txt', ...
			solver, j, measureOptions.Dimension);
		fileID = fopen(txtfilename, 'w');
		for p = 1 : nP
			for r = 1 : nR
				fprintf(fileID, '%.15E ', allfvals(p, r, j));
			end
			fprintf(fileID, '\n');
		end
		fprintf(fileID, '\n');
		fclose(fileID);
		
		fprintf('Generated: %s\n', txtfilename);
	end
end
end