function num_steps=wall_inches_to_steps(inches)
%This function convert the distance in inches into number of steps for the
%compression wall motor.

num_rev=inches*10; %We have 1/10 inches per revolution.
num_steps=num_rev*51200; %We have 51200 steps per revolution

end