function transArray = updateTransitionModeIndices(transArray,HA, transNo)

for iTrans = 1:transNo
    jTrans = HA.modesNo + iTrans;
    transArray(iTrans).mTrans = jTrans;
end

end

