function SendCompCommand(Did,command)
%This function send a command to the compression drive
%and check that it was correctly received

fprintf(Did,command);
DAnswer=fscanf(Did);

if(any(DAnswer=='%') || any(DAnswer=='*')) 
    %Good, nothing to do
elseif(DAnswer=='?') 
    %Oo, error, aborting program
    error('The compression drive returned an error code');
else
    %Don't know what it is, report and abort
    error(['The compression drive returned an unkwown answer: ' DAnswer]);
end

end