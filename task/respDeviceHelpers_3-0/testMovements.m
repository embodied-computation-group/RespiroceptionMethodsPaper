
clear all

sPort = "COM6";
sBaudRate = 9600;
[init, respDevice] = setupResp(sPort, sBaudRate); 

for repeat = 1:5
    
    for goMore = 1:3
        
        if goMore == 1
            newPosition = 0;
        elseif goMore == 2
            newPosition = 50;
        elseif goMore == 3
            newPosition = 100;
        end
        
        moveResp(respDevice, newPosition);
        pause(2);
        
    end
    
    
    
end
