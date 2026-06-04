function [lowTargets, highTargets] = compStepArray(totalStep,lowCnt,highCnt)

    % Find the motor steps for each instr
    highStepSz = round(totalStep/highCnt);
    lowStepSz  = round(totalStep/lowCnt);

    % Force an initial scan
    highTargets = [0];
    lowTargets = [0];

    % Create step instr for high res
    for i = 1:highCnt
        if i <= highCnt/2
            highTargets = [highTargets, highStepSz];
        elseif i>highCnt/2
            highTargets = [highTargets, -highStepSz];
        end
    end

    % Create step instr for low res
    for i = 1:lowCnt
        if i <= lowCnt/2
            lowTargets = [lowTargets, lowStepSz];
        elseif i>lowCnt/2
            lowTargets = [lowTargets, -lowStepSz];
        end
    end

end