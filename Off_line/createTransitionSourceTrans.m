function EA = createTransitionSourceTrans(EA, transArray, transNo)

for iTrans = 1:transNo
    
    mSource = transArray(iTrans).mSource;
    mDest = transArray(iTrans).mDest;
    eInit = transArray(iTrans).eInit;
    mTrans = transArray(iTrans).mTrans;
    
    EA.transitionMatrix(mSource,eInit) = mTrans;
end

end

