function moveWall(steps, ao)
%make data to send
data = eye(4);
for i = 2:abs(steps/4)
    data = [data ; eye(4)];
end
data = [data; 0 0 0 0];
data = data * 3;
if steps > 0
    data = fliplr(data);
end
putdata(ao, data);
start(ao);
end