function [transArray, transNo] = identifyInitialTransitions(transMatrix)


% 1. Compter et trouver les lignes et colonnes de chaque transitions
transIndexArray = find(transMatrix);
[transRowArray,transColArray] = find(transMatrix);
transNo = length(transIndexArray);

transRowColInd =  struct('ind',{},...
    'row',{},...
    'col',{});
for iTrans = 1:transNo
    transRowColInd(iTrans).ind = transIndexArray(iTrans);
    transRowColInd(iTrans).row = transRowArray(iTrans);
    transRowColInd(iTrans).col = transColArray(iTrans);
end

% 2. Identifier chaque transition
transArray = struct(...
    'mSource',{},...
    'mDest',{},...
    'eInit',{},...
    'mTrans',{},...
    'eSig',{});

for iTrans = 1:transNo
    transArray(iTrans).mSource = transRowColInd(iTrans).row;
    transArray(iTrans).mDest = transMatrix(transRowColInd(iTrans).ind);
    transArray(iTrans).eInit = transRowColInd(iTrans).col;
end

end

