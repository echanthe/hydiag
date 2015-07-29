function EA = eraseInitialTransitions(EA, transArray, transNo)

for iTrans = 1:transNo
    
    mSource = transArray(iTrans).mSource;
    mDest = transArray(iTrans).mDest;
    eInit = transArray(iTrans).eInit;
    
    EA.transitionMatrix(mSource,eInit) = 0;
end

end

