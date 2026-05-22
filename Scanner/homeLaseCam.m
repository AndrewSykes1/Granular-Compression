% Set to reverse
motorparam(s1, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);
motorparam(s3, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);
motorparam(s2, motorReverseRpm, motorReverseAcc, motorReverseDcc, motorAbortDcc);

% Move to position 0
moveto(s1, motorHome);
moveto(s3, motorHome);
moveto(s2, motorHome);

% Wait for motors to finish moving
finishMove(s1);
finishMove(s3);
finishMove(s2);

% Set to forward
motorparam(s1, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);
motorparam(s3, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);
motorparam(s2, motorForwardRpm, motorForwardAcc, motorForwardDcc, motorAbortDcc);

