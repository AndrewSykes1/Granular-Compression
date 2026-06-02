% Set motors to reverse parameters
motorparam(s1, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);
motorparam(s2, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);
motorparam(s3, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);

% Home motors
fprintf(s1, 't 2 \n');
fprintf(s2, 't 2 \n');
fprintf(s3, 't 2 \n');

% Wait for motors to finish moving
finishLCMove(s1);
finishLCMove(s2);
finishLCMove(s3);

% Set to forward
motorparam(s1, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);
motorparam(s2, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);
motorparam(s3, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);

