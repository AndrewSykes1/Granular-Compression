function pco_errdisp(txt,errorcode)
%if errorcode display error text with errornumber in HEX
%  
if(errorcode)
 disp([txt,' failed with error 0x',num2str(4294967296+errorcode,'%08X')]);   
end
end
