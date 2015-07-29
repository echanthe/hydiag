function EA = createTransitionTransDest(EA, transArray, transNo)

for iTrans = 1:transNo
    
    mSource = transArray(iTrans).mSource;
    mDest = transArray(iTrans).mDest;
    eInit = transArray(iTrans).eInit;
    mTrans = transArray(iTrans).mTrans;
    eSig = transArray(iTrans).eSig;
    
    EA.transitionMatrix(mTrans,eSig) = mDest;
end

end