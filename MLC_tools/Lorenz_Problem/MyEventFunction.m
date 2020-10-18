function [VALUE, ISTERMINAL, DIRECTION] = MyEventFunction(T, Y)
    %The event function stops when VALUE == 0 and
    %ISTERMINAL==1
    %a. Define the timeout in seconds
    TimeOut = 10;
    %b. The solver runs until this VALUE is negative (does not change the sign)
    VALUE = toc-TimeOut;
    %c. The function should terminate the execution, so
    ISTERMINAL = 1;
    %d. The direction does not matter
    DIRECTION = 0;
end