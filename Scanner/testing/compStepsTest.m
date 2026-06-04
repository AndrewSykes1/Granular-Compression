totalStep = 325000;
lowCnt    = 4;
highCnt   = 8;

lowStepSz  = round(totalStep/lowCnt);
lowTargets = [0];

for i = 1:lowCnt
    if i <= lowCnt/2
        lowTargets = [lowTargets, lowStepSz];
    elseif i>lowCnt/2
        lowTargets = [lowTargets, -lowStepSz];
    end
end

display(lowTargets);


highStepSz  = round(totalStep/highCnt);
highTargets = [0];

for i = 1:highCnt
    if i <= highCnt/2
        highTargets = [highTargets, highStepSz];
    elseif i>highCnt/2
        highTargets = [highTargets, -highStepSz];
    end
end

display(highTargets);