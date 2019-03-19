
dataInputDirPath = "./2cell_outputs2";
dataOutputDirPath = "./2cell_analysis";

dataFilePaths = dir( dataInputDirPath + "/*_probes.csv" );

numFiles = length( dataFilePaths );

outputDataCell = cell( numFiles + 1, 4 );
outputDataCell( 1, : ) = { 'DataFile' 'MutualEntropy' 'MutualEntropyShifted' 'DelayEstimateMs' };

for idx = 1:numFiles
   file = dataFilePaths( idx );
   fileName = file.name;
   fileBaseName = strsplit( fileName, "." );
   fileBaseName = fileBaseName( 1 );
   filePath = strcat( dataInputDirPath, strcat( "/", fileName ) );
   [ delayEst, mInfo, mInfoShft ] = analyseFile( filePath );
   outputDataCell( idx + 1, : ) = { fileName mInfo mInfoShft delayEst }; 
   fprintf( "File %s; Mutual Info: %fbits/sym; Mutual Info (shifted Y): %fbits/sym; Delay Estimate: %fms\n", ...
       fileName, mInfo, mInfoShft, delayEst );
end

% Convert cell to a table and use first row as variable names
outputDataTable = cell2table( outputDataCell ( 2 : end, : ), ...
                              'VariableNames', outputDataCell( 1 , : ) );

% Write the table to a CSV file
%writetable( outputDataTable, 'outputData.csv' );

% Function to read in 2-cell simulation data and analyse it, returning
% the mutual information of the channel
function [ delayEstMs, mutualInfo, mutualInfoShft ] = analyseFile( filename )
    % Read the data CSV
    data = csvread( filename, 1 );
    dataX = data( :, 2 );
    dataY = data( :, 3 );
    dataXgz = dataX;
    dataXgz( dataXgz < 0 ) = 0;
    dataYgz = dataY;
    dataYgz( dataYgz < 0 ) = 0;
    
    % Get the simulation timestep interval in ms
    timeInterval = data( 2, 1 ) - data( 1 , 1 );
    
    % Cross-correlate to estimate delay
    [ sigCorr, lags ] = xcorr( dataYgz, dataXgz, 150 );
    % Find local maxima in the correlation
    [ peaks, pkLocs ] = findpeaks( sigCorr, lags, 'MinPeakHeight',1.0 );
    % Try to find the lowest lag value that isn't 0
    pkLocs = pkLocs( pkLocs > 0.0 );
    delayEstTimeSteps = 0;
    if( ~isempty( pkLocs ) )
        delayEstTimeSteps = pkLocs( 1 );
    end
    % Delay estimate in simulation timesteps, convert to MS
    delayEstMs = delayEstTimeSteps * timeInterval;
    
    % Advance dataY by delatEstTimeSteps for comparison
    dataYshifted = delayseq( dataY, delayEstTimeSteps );
    
    [ tX, dXLevs ] = discretiseTrain( dataX );
    [ tY, dYLevs ] = discretiseTrain( dataY );
    [ tYshft, dYShftLevs ] = discretiseTrain( dataYshifted );

    mutualInfo = getMutualInfo( dXLevs, dYLevs );
    mutualInfoShft = getMutualInfo( dXLevs, dYShftLevs );
end