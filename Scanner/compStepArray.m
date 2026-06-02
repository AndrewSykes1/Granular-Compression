function [lowTargets, highTargets] = compStepArray(totalStep,lowCnt,highCnt)

lowStepSz  = round(totalStep/lowCnt);
highStepSz = round(totalStep/highCnt);

lowTargets  = [0];
highTargets = [0];

for div = 1:lowCnt
    lowTargets =  [lowTargets, lowStepSz];
end

for div = 1:highCnt
    highTargets = [highTargets, highStepSz];
end

lowTargets  = [lowTargets,  -totalStep];
highTargets = [highTargets, -totalStep]; 

end