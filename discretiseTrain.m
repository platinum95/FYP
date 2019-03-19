function [ tCentres, bLevels ] = discretiseTrain( voltages, timeInterval )
% DISCRETISETRAIN Discretise the given spike train from voltage level
% to binary values. Returns equally sized arrays of time centres and
% binary level.


% Find the smallest step between any two spikes with the autocorrelation
%voltageCorr = acf( voltages, 100 );
minInt = 100; % Hardcode 100ms for now

samplingRate = minInt / 2.0;

% Get the baseline signal level
signalFloor = mean( voltages );

% Get the spike threshold
vThreshold = 0.0; % Placeholder for now


% Discretise the voltages based on the threshold
dVoltages = voltages > vThreshold;

% Now get the interval + levels
bLevels = [];
tCentres = [];

for i = 0 : ceil( length( dVoltages ) / samplingRate )
   lowerBound = i * samplingRate + 1;
   upperBound = ( i + 1 ) * samplingRate;
   
   if( upperBound > length( dVoltages ) )
       upperBound = length( dVoltages );
   end
   dSlice = dVoltages( lowerBound : upperBound );
   sigLev = 0;
   for vi = 1 : length( dSlice )
       if( dSlice( vi ) > vThreshold )
           sigLev = 1;
           break;
       end
   end
   bLevels = [ bLevels sigLev ];
   tCentres = [ tCentres ( lowerBound + ( samplingRate / 2.0 ) ) ];
   
   
end

end % function

