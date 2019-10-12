% 模型树构造函数
function mtbuild(SplitX, RegressX, Y, AllSplitX, AllRegressX, AllY, binCat, out_path, random_number)
    %model tree build
    %SplitX为分裂变量，RegressX为回归变量，Ytr为目标变量
    %AllSplitX, AllRegressX, AllY为总的数据
    %binCat为SplitX参量的类型，0代表连续变量，1代表类别变量
    %RegressX默认就是连续变量
    % set(0,'RecursionLimit,10000000000');
    %out_path 为输出路径
    %random_number 为第几次随机
    
    if  nargin < 4
         error ('Too few input arguments.');
    end
    
    if  (isempty(SplitX) || isempty(RegressX) || isempty(Y))
        error('Training data is empty or not enough.');
    end
    
    [n, leafnumber] = size(SplitX); %记录n样本数，m参量个数
    if size(Y,1) ~=n && size(RegressX,1) ~=n
        error('The number of rows in the matrix and the vector should be equal.');
    end
    
    if size(Y,2) ~=1
        error('Ytr should have one colum.');
    end
    
    if (nargin < 4) || isempty(binCat)
        binCat = zeros(1, leafnumber);
    end
    
    tic;
    
    MinNumCases = 90;
    %MinCaseNumber：最后叶子节点剩余样本数，有关分裂停止的条件
    MinCaseNumber = 40;
    model.tree.caseInd = (1:1:length(SplitX))';
    model.tree.type ='LEAF';
    %model.tree.ID = 1;
    model.tree.condition ='OPEN';
    model.binCat = binCat;
    [model.tree.model.coefs, model.tree.model.attrInd] =  bestParameter(RegressX, Y); 
    currentbic = calcBicSubtree(model.tree, AllSplitX, AllRegressX, AllY, binCat);
    
    global mtree;
    mtree = model.tree;
    global mtreeTest;
    % mtreeTest = mtree;
    
    %开始生长树
    GrowTree = true;
    disp('Start grow tree...')
    while GrowTree
        number = 1;
        num = signLeafNode(0, number);
    %      n = 2;
        tmpbic = NaN(num-1, 1);
        for ii = 1:(num-1)
    %         mtreeTest = [];
            mtreeTest = mtree;
            foundLeafNode(0, ii, SplitX, RegressX, Y, mtreeTest.caseInd, binCat, MinNumCases, MinCaseNumber);
            tmpbic(ii) = calcBicSubtree(mtreeTest, AllSplitX, AllRegressX, AllY, binCat);
            str1 = ['mtree',num2str(ii),'=mtreeTest',';'];
            eval(str1);
            mtreeTest = [];
        end
        number2 = find(tmpbic(:) == min(tmpbic));
        minbic = tmpbic(number2);
    %     current_min = currentbic - minbic;
        if minbic < currentbic
            currentbic = minbic;
            str2 = ['mtree','=mtree',num2str(number2),';'];
            eval(str2);
            GrowTree = true;
        else
            GrowTree = false;
        end
        mtree.bic = currentbic;
        clc;
        save([out_path, 'MT', random_number, '.mat'],'mtree');
    %     save([out_path, 'MT_1','.mat'],'mtree');
    end
    
    toc;
    fprintf('Have fun, You have done...');
    
    end
    
    %==========================辅助函数============================%
    %标记叶子
    function m = signLeafNode(code, m)
    global mtree;
    code = num2str(code);
    a = 'mtree';
    b = '.number';
    c = '.left';
    d = '.right';
    g = '.type';
    h = '.condition';
    if str2num(code(1)) == 0
         a = a;
    else
        for i = 1:length(code)
            if str2num(code(i))==1
                a = [a, c];    
            else
                 if str2num(code(i))==2
                      a = [a, d];  
                 end
            end
        end
    %     a = a;
    %     a = [a b];  
    end
    e = [a, g];
    f = eval(e);
    j = [a, h];
    k = eval(j);
    if (strcmp(f, 'LEAF')&&strcmp(k, 'OPEN'))
        str1 = [a,b];
        eval([str1, '=', num2str(m)]);
        m = m + 1;
    else
        if strcmp(f, 'INTERIOR')
            code = str2num(code);
            m = signLeafNode((code*10)+1, m);
            m = signLeafNode((code*10)+2, m);
        end
    end
    %mtree = mtree;
    end
    
    %Find best split for open leaf node
    function  foundLeafNode(code, m, SplitX, RegressX, Y, caseInd, binCat, MinNumCases, MinCaseNumber)
    %%找到所有叶子节点
    %node包括node的所有信息
    %找到所有叶子节点，并分别赋予number
    %计算每个open的叶子节点，分裂后的newTreeBIC
    global mtreeTest;
    code = num2str(code);
    a = 'mtreeTest';
    b = '.left';
    c = '.right';
    d = '.type';
    e = '.condition';
    f = '.number';
    if str2num(code(1)) == 0
        a = a;
    else
        for i = 1:length(code)
            if str2num(code(i)) == 1
                a = [a, b];
            else
                if str2num(code(i)) == 2
                    a = [a, c];
                end
            end
        end
    end
    a = a;
    g = [a, d];
    gg = eval(g);
    h = [a, e];
    hh = eval(h);
    j = [a, f];
    k = '.caseInd';
    l = '.model.coefs';
    n = '.model.attrInd';
    o = 'LEAF';
    p = 'INTERIOR';
    q = 'OPEN';
    t = 'CLOSED';
    u = '.splitAttribute';
    v = '.splitLocation';
    w = '.leftInd';
    ww = '.rightInd';
    if (strcmp(gg, 'LEAF') && (strcmp(hh, 'OPEN')))
        jj = eval(j);
        if jj == m
            node1 = splitNode1(SplitX(caseInd,:), RegressX(caseInd,:), Y(caseInd,:), caseInd, binCat, MinNumCases,MinCaseNumber);
            if ~isempty(node1)
                eval([a,b,d,'=','o']);
                eval([a,c,d,'=','o']);
                eval([a,d,'=','p']);
                str1 = [a,b,k,'=node1.leftInd'];
                str2 = [a,c,k,'=node1.rightInd'];
                str3 = [a,b,l,'=node1.left.model.coefs'];
                str4 = [a,b,n,'=node1.left.model.attrInd'];
                str5 = [a,c,l,'=node1.right.model.coefs'];
                str6 = [a,c,n,'=node1.right.model.attrInd'];
                str7 = [a,u,'=node1.splitAttribute'];
                str8 = [a,v,'=node1.splitLocation'];
                str9 = [a,w,'=node1.leftInd'];
                str10 = [a,ww,'=node1.rightInd'];
                eval(str1);
                eval(str2);
                eval(str3);
                eval(str4);
                eval(str5);
                eval(str6);
                eval(str7);
                eval(str8);
                eval(str9);
                eval(str10);
                if length(node1.leftInd)>=MinNumCases
                    eval([a,b,e,'=','q']);
                else
                    eval([a,b,e,'=','t']);
                end
                if length(node1.rightInd)>=MinNumCases
                    eval([a,c,e,'=','q']);   
                else
                    eval([a,c,e,'=','t']);  
                end 
            end
        end
    %     bic = calcBicSubtree(mtreeTest, RegressX, Y);
    %     return
    else
         if strcmp(gg, 'INTERIOR')
             code = str2num(code);
             r = [a, w];
             s = eval(r);
             rr = [a, ww];
             ss = eval(rr);
             foundLeafNode((code*10)+1, m, SplitX, RegressX, Y, s, binCat, MinNumCases,MinCaseNumber);
             foundLeafNode((code*10)+2, m, SplitX, RegressX, Y, ss, binCat, MinNumCases,MinCaseNumber);
         end
    end
    end
    
    %节点分裂
    function  node = splitNode1(SplitX1, RegressX1, Y1, caseInd, binCat, MinNumCases,MinCaseNumber)
    %SplitX为分裂变量，RegressX为回归变量，Y为目标变量
    %binCat为分裂变量类型
    [mSplitX, nSplitX] = size(SplitX1);
    mRegressX = size(RegressX1, 1);
    mY= size(Y1, 1);
    node.caseInd = caseInd;
    if (mSplitX ~= mRegressX || mRegressX ~= mY || mSplitX ~= mY)
        error('The number of rows in the matrix and the vector should be equal.');
    end
    minSSE = inf;
     %if (strcmp(node.type, 'LEAF') && (strcmp(node.condition, 'OPEN')))
     if mSplitX >= MinNumCases
         for i =1: nSplitX
             if binCat(i) == 0
                 for j = 1: mSplitX
                     [leftInd, rightInd] = Conleftright(SplitX1(j, i), i , SplitX1);
    %                  leftInd = caseInd(leftInd);
    %                  rightInd = caseInd(rightInd);
                     if (length(leftInd) >= MinCaseNumber) && (length(rightInd) >= MinCaseNumber)
                         [left1.coefs, left1.attrInd] = bestParameter(RegressX1(leftInd, :), Y1(leftInd, :));
                         [right1.coefs, right1.attrInd] = bestParameter(RegressX1(rightInd, :), Y1(rightInd, :));
                         left1.ytest = RegressX1(leftInd, left1.attrInd) * left1.coefs(2:end) + left1.coefs(1) ;
                         right1.ytest = RegressX1(rightInd, right1.attrInd) * right1.coefs(2:end) + right1.coefs(1);
                         ssetmp = sum((left1.ytest - Y1(leftInd, :)).^2) + sum((right1.ytest - Y1(rightInd, :)).^2);
                          if ssetmp < minSSE
                              minSSE = ssetmp;
                              leftIndtmp = leftInd;
                              rightIndtmp = rightInd;
                              splitAttribute = i;
                              splitLocation = SplitX1(j, i);
                              left.model.coefs = left1.coefs;
                              left.model.attrInd = left1.attrInd;
                              right.model.coefs = right1.coefs;
                              right.model.attrInd = right1.attrInd;
                          else
                              continue
                          end
                     else
                         continue
                     end      
                 end 
             else
                 if binCat(i) == 1
                    [leftInd, rightInd] = Catleftright(SplitX1(:, i), RegressX1, Y1, MinCaseNumber);
                    if ((isempty(leftInd)) || (isempty(rightInd)))
                        ssetmp = inf;
                    else
                        if (length(leftInd) >= MinCaseNumber) && (length(rightInd) >= MinCaseNumber)
                             [left1.coefs, left1.attrInd] = bestParameter(RegressX1(leftInd, :), Y1(leftInd, :));
                             [right1.coefs, right1.attrInd] = bestParameter(RegressX1(rightInd, :), Y1(rightInd, :));
                             left1.ytest = RegressX1(leftInd, left1.attrInd) * left1.coefs(2:end) + left1.coefs(1) ;
                             right1.ytest = RegressX1(rightInd, right1.attrInd) * right1.coefs(2:end) + right1.coefs(1);
                             ssetmp = (sum((left1.ytest - Y1(leftInd, :)).^2) + sum((right1.ytest - Y1(rightInd, :)).^2));
                        else
                            continue
                        end
                    end
                    if ssetmp < minSSE
                        minSSE = ssetmp;
                        leftIndtmp = leftInd;
                        rightIndtmp = rightInd;
                        splitAttribute = i; 
                        left.model.coefs = left1.coefs;
                        left.model.attrInd = left1.attrInd;
                        right.model.coefs = right1.coefs;
                        right.model.attrInd = right1.attrInd;
                    end
    %                 leftInd = caseInd(leftInd);
    %                 rightInd = caseInd(rightInd); 
                 end
             end
         end
         
         if ~isempty(leftIndtmp)
              leftInd = caseInd(leftIndtmp);
              rightInd = caseInd(rightIndtmp);
              node.leftInd = leftInd;
              node.rightInd = rightInd;
              node.splitAttribute = splitAttribute;
              if binCat(node.splitAttribute) == 0
                  node.splitLocation = splitLocation; 
              else
                    node.splitLocation = NaN;
              end
              node.left.model.coefs = left.model.coefs;
              node.left.model.attrInd = left.model.attrInd;
              node.right.model.coefs = right.model.coefs;
              node.right.model.attrInd = right.model.attrInd;
              node.left.caseInd = leftInd;
              node.right.caseInd = rightInd;
         else
             node = [];
         end
     else
         node = [];         
     end
    end
    
    % 选择最佳回归变量进行回归
    function  [RegCo, Parameter] =  bestParameter(leafX, leafY)
    %leafX为节点的回归变量
    %leafY为节点的目标变量
    %RegCo为选出的回归变量的回归系数
    %Parameter为选出的回归变量
    [nleafX, mleafX] = size(leafX);
     %ii = 1;
     %SSE = NaN(2^mleafX-1, 1);
     %RegCo = NaN(2^mleafX-1, 1);
     minbic = 10000000000000000;
     %Parameter1 = zeros(1,mleafX);
     re = NaN(36, mleafX, mleafX);
    for  i = 1: mleafX
        %进行组合
        re(1:nchoosek(mleafX, i), 1:i, i) = chooseParameter(mleafX, i); 
        
        for j = 1:nchoosek(mleafX, i)
            tmpX = leafX(:, re(j, 1:i, i));
            %交叉验证
            indices= crossvalind('Kfold', nleafX, 10);
            MSE = 0;
            regco = NaN(i+1,10);
            sse = NaN(10, 1);
            for k = 1:10   
                %MSE = NaN(10, 1);
                test = (indices == k);
                train = ~ test;
                %进行回归
                tmpX1 = [ones(sum(train),1), tmpX(train, :)];
                regco(:,k) = regress(leafY(train,:), tmpX1);
                yhat = tmpX(test, :) * regco(2:end,k) + regco(1,k);
                sse(k) = sum((yhat - leafY(test,1)).^ 2);  
                MSE = MSE + sse(k) / length (tmpX(test, :)) ;
            end
            %SSE(ii) = mean(sse(:));
            %RegCo(ii) = median(regco);
            %mse = sum(MSE(:))/10;
            mse = MSE/10;
            tmpbic = biccalc(mse, nleafX, mleafX);
            tmpParameter = re(j, :, i);
            if tmpbic < minbic
                minbic = tmpbic;
                Parameter1 = tmpParameter;
            end    
        end       
    end
    Parameter2 = Parameter1(~isnan(Parameter1));
    Parameter = Parameter2(Parameter2 ~=0);
    leafX1 = [ones(size(leafX, 1),1), leafX(:, Parameter)];
    RegCo = regress(leafY, leafX1);
    
    end
    
    %组合几个参量的函数,几个参量选取
    function re = chooseParameter(nn, mm)
    re = (1: nn)';
    while(size(re, 2) < mm)
        tmp = [];
        for i = 1 : size(re, 1)
           tmp = [tmp ; [ones(nn - re(i, end), 1)*re(i, :), (re(i, end)+1:nn)']];
        end
        re = tmp;
    end
    end
    
    %分裂点处分成左右两支（连续变量）
    function [leftInd, rightInd] = Conleftright(split, splitAttribute, SplitX2)
        leftInd = find(SplitX2(:, splitAttribute) < split);
        rightInd = find(SplitX2(:, splitAttribute) >= split);
    end
     
    %分裂点处分成左右两支（类别变量）
    function [leftInd, rightInd] = Catleftright(X, RegressX, Y, MinCaseNumber)
    %Find Best Categorial Split
    %类别变量是类似于聚类，但又与聚类不同
    %X为这一个类别变量，RegressX是用来进行回归的变量，Y为目标变量
        LX = tabulate(X);
        hang = 1;
        for p = 1:size(LX, 1)
            if LX(p,2) ~=0
                Groups(hang,1) = LX(p,1);
                hang = hang +1;
            end
        end
        num = size(Groups, 1);
        re = chooseParameter(num, 2);
        while(num > 2)
            sse = NaN(size(re, 1), 1);
            for k = 1: size(re, 1)
                CatInd = [];
                for l = 1:size(Groups, 2)
                     if ~isnan(Groups(re(k, 1), l))
                         group1 = find(X == Groups(re(k, 1), l));
                         CatInd = [CatInd; group1];
                     end
                end
                for o = 1:size(Groups, 2)
                     if ~isnan(Groups(re(k, 2), o))
                         group2 = find(X == Groups(re(k, 2), o));
                         CatInd = [CatInd; group2];
                     end
                end
                if length(CatInd) >= MinCaseNumber
                 [RegCo, Parameter] = bestParameter(RegressX(CatInd, :), Y(CatInd, :));
                 ytest = RegressX(CatInd, Parameter(1, :)) * RegCo(2:end) + RegCo(1);
                 sse(k) = sum(ytest - Y(CatInd, :)) ^ 2;
                else
                    continue
                end
            end
            % Groups中存放了可以合并的一行，第一次运行时这一行是含有两个类型，以后不定,最后值剩余两行，NaN是20行20列
            Groups = conbination(Groups, re((sse == min(sse(:))), :)); 
            num = sum(~isnan(Groups(:,1)));
            re = chooseParameter(num, 2);
        end 
    %     m = size(Groups, 2);
    leftInd = [];
    rightInd = [];
    if size(Groups, 1)>1
        for mm = 1:size(Groups, 2)
            if ~isnan(Groups(1, mm))
                mmm = find(X == Groups(1, mm));
                leftInd = [leftInd;mmm];
            end
            if ~isnan(Groups(2, mm))
                nnn = find(X == Groups(2, mm));
                rightInd = [rightInd;nnn];
            end
        end
    else
        leftInd = [];
        rightInd = [];
    end
    
    end
    
    %类别变量两个类型合并
    function array = conbination(a, b)
    % a中存放类别，b中存放可以合并的两行
    array = NaN(20, 20);
    a1 = a(b, :);
    m = 1;
    for i = 1:2
        for k =1:(sum(~isnan(a1(i,:)))) 
            array(1,m) = a1(i,k);
            m = m+1;
        end
    end
    % for j = 1:(sum(~isnan(a1(2,:))))
    %     array(2,m) = a1(2,j);
    %     m = m+1;
    % end
    a(b, :) = [];
    for k = 1:size(a,1)
        for l = 1:size(a, 2)
            array(k+1, l) = a(k, l);
        end
    end
    end
    
    %计算整棵树的BIC
    function treebic = calcBicSubtree(node, SplitX, RegressX, Y, binCat)
    
    PredictY= predictMT(node, SplitX, RegressX, binCat);
    sumSSE = sum((PredictY - Y).^ 2);
    MSE = sumSSE/(length(Y));
    numS = length(Y);
    numP = size(RegressX, 2);
    treebic = biccalc(MSE, numS, numP);
    
    end
    
    %用当前的树进行预测结果
    function PredictY= predictMT(node, SplitX, RegressX, binCat)
    mSplitX = size(SplitX,1);
    PredictY = NaN(mSplitX,1);
    for i = 1:mSplitX
        PredictY(i) = predict_MT(node, SplitX(i,:), RegressX(i,:), binCat);
    %     eatstr = ['Complated: ', num2str(i*100/mSplitX),'%'];
    %     disp(eatstr);
    end
    end
    
    %计算一棵树、一个样本的预测值
    function Yq = predict_MT(node, SplitX, RegressX, binCat)
    mSplitX = size(SplitX,1);
    Yq = NaN(mSplitX,1);
        if strcmp(node.type, 'INTERIOR')
            if binCat(node.splitAttribute) == 1
                if ~isnan(SplitX(1, node.splitAttribute))
                    if ismember(SplitX(1, node.splitAttribute), node.leftInd)
                        Yq = predict_MT(node.left, SplitX, RegressX, binCat);
                    else
                        Yq = predict_MT(node.right, SplitX, RegressX, binCat);
                    end
                else
                    Yq = NaN;
                end
            else
                if binCat(node.splitAttribute) == 0
                    if ~isnan(SplitX(1, node.splitAttribute))
                        if SplitX(1, node.splitAttribute) < node.splitLocation
                            Yq = predict_MT(node.left, SplitX, RegressX, binCat);
                        else
                            Yq = predict_MT(node.right, SplitX, RegressX, binCat);
                        end
                    else
                        Yq = NaN;
                    end
    
                end
            end
        else
            if strcmp(node.type, 'LEAF')
                if ~isempty(node.model.attrInd)
                    if ~any(isnan(RegressX(1, node.model.attrInd)))
                        Yq = RegressX(1, node.model.attrInd) * node.model.coefs(2:end) + node.model.coefs(1);
                    end 
                end
            end
        end
    
    end
    
     % BIC准则函数
    function  BIC = biccalc(mse, numS, numP)
    % mse为交叉验证后求出的均方误差
    %numS为节点样本数量
    %numP为选择的参量个数
    BIC = (log10(mse)) * numS + (log10(numS)) * numP;
    end
    
    %整个树的bic(暂不使用)
    function treebic = calcBicSubtree11(node, SplitX, RegressX, Y, binCat)
    
    if strcmp(node.type, 'INTERIOR')
        treebic = calcBicSubtree(node.left, SplitX, RegressX, Y, binCat) +...
        calcBicSubtree(node.right, SplitX, RegressX, Y, binCat);
    else
        if strcmp(node.type,'LEAF')
            leafY = Y(node.caseInd,:);
            tmpX = RegressX(node.caseInd, node.model.attrInd);
            regco = node.model.coefs;
            yhat = tmpX * regco(2:end) + regco(1);
            treeSSE = sum((yhat - leafY).^ 2);
            numS = length(leafY);
            mse = treeSSE/numS;
            numP = length(node.model.attrInd);
            treebic = biccalc(mse, numS, numP);
        end
    end
    end
    
    %找到分裂的节点在mtree中的位置(暂不使用)
    function  foundAction(code, m, SplitX, RegressX, Y, binCat, MinNumCases)
    global mtree;
    if strcmp(node.type,'LEAF')&&(strcmp(node.condition,'OPEN'))
        if node.number == m;
            node1 = splitNode2(SplitX(node.caseInd,:), RegressX(node.caseInd,:), Y(node.caseInd,:), node.caseInd, binCat);
            node.leftInd = node1.leftInd;
            node.rightInd = node1.rightInd;
            node.splitAttribute = node1.splitAttribute;
            node.splitLocation = node1.splitLocation;
            node.left.model.coefs = node1.left.model.coefs;
            node.left.model.attrInd = node1.left.model.attrInd;
            node.right.model.coefs = node1.right.model.coefs;
            node.right.model.attrInd = node1.right.model.attrInd;
            node.left.caseInd = node1.leftInd;
            node.right.caseInd = node1.rightInd;
            node.type = 'INTERIOR';
            node.left.type = 'LEAF';
            node.right.type = 'LEAF';
            if length(node.leftInd) > MinNumCases
                node.left.condition = 'OPEN';
            else
                node.left.condition = 'CLOSED';             
            end
            if length(node.rightInd) > MinNumCases
                node.right.condition = 'OPEN';    
            else
                node.right.condition = 'CLOSED';     
            end
        end
    %     return
    else
        if strcmp(tree, node.type,'INTERIOR')
            node = foundAction(node.left, m, SplitX, RegressX, Y, binCat, MinNumCases);
            node = foundAction(node.right, m, SplitX, RegressX, Y, binCat, MinNumCases);
        end
    end
    if length(node.caseInd) == length(mtree.caseInd)
        mtree = node;
    end
    end
    
    %节点分裂(暂不使用)
    function  node = splitNode2(SplitX1, RegressX1, Y1, caseInd, binCat)
    %SplitX为分裂变量，RegressX为回归变量，Y为目标变量
    %binCat为分裂变量类型
    [mSplitX, nSplitX] = size(SplitX1);
    mRegressX = size(RegressX1, 1);
    mY= size(Y1, 1);
    node.caseInd = caseInd;
    if (mSplitX ~= mRegressX || mRegressX ~= mY || mSplitX ~= mY)
        error('The number of rows in the matrix and the vector should be equal.');
    end
    minSSE = inf;
     %if (strcmp(node.type, 'LEAF') && (strcmp(node.condition, 'OPEN')))
         for i =1: nSplitX
             if binCat(i) == 0
                 for j = 1: mSplitX
                     [leftInd, rightInd] = Conleftright(SplitX1(j, i), i , SplitX1);
                     leftInd = caseInd(leftInd);
                     rightInd = caseInd(rightInd);
                     if (length(leftInd) >= 100) && (length(rightInd) >= 100)
                         [left.coefs, left.attrInd] = bestParameter(RegressX1(leftInd, :), Y1(leftInd, :));
                         [right.coefs, right.attrInd] = bestParameter(RegressX1(rightInd, :), Y1(rightInd, :));
                         left.ytest = RegressX1(leftInd, left.attrInd) * left.coefs;
                         right.ytest = RegressX1(rightInd, right.attrInd) * right.coefs;
                         ssetmp = (sum((left.ytest - Y1(leftInd, :)).^2) + sum((right.ytest - Y1(rightInd, :)).^2));
                          if ssetmp < minSSE
                              minSSE = ssetmp;
                              leftIndtmp = leftInd;
                              rightIndtmp = rightInd;
                              splitAttribute = i;
                              splitLocation = SplitX1(j, i);
                              left.model.coefs = left.coefs;
                              left.model.attrInd = left.attrInd;
                              right.model.coefs = right.coefs;
                              right.model.attrInd = right.attrInd;
                          end
                     end      
                 end 
             else
                 if binCat(i) == 1
                    [leftInd, rightInd] = Catleftright(SplitX1(:,i), RegressX1, Y1);
                    leftInd = caseInd(leftInd);
                    rightInd = caseInd(rightInd);
                    if (length(leftInd) >= 100) && (length(rightInd) >= 100)
                        [left.coefs, left.attrInd] = bestParameter(RegressX1(leftInd, :), Y1(leftInd, :));
                        [right.coefs, right.attrInd] = bestParameter(RegressX1(rightInd, :), Y1(rightInd, :));
                        left.ytest = RegressX1(leftInd, left.attrInd) * left.attrInd;
                        right.ytest = RegressX1(rightInd, right.attrInd) * right.attrInd;
                        ssetmp = (sum((left.ytest - Y1(leftInd, :)).^2) + sum((right.ytest - Y1(rightInd, :)).^2));
                        if ssetmp < minSSE
                            minSSE = ssetmp;
                            leftIndtmp = leftInd;
                            rightIndtmp = rightInd;
                            splitAttribute = i;
                            left.model.coefs = left.coefs;
                            left.model.attrInd = left.attrInd;
                            right.model.coefs = right.coefs;
                            right.model.attrInd = right.attrInd;
                        end
                    end
                 end 
             end
         end
            node.leftInd = leftIndtmp;
            node.rightInd = rightIndtmp;
            node.splitAttribute = splitAttribute; 
            if binCat(node.splitAttribute) == 0
                node.splitLocation = splitLocation;
            else
                node.splitLocation = NaN;
            end
            node.left.model.coefs = left.coefs;
            node.left.model.attrInd = left.attrInd;
            node.right.model.coefs = right.coefs;
            node.right.model.attrInd = right.attrInd;
     %end        
    end
    
    %整棵树的SSE(暂不使用)
    function treeSSE = ssecalcu(node, RegressX, Y)
    if strcmp(node.type, 'INTERIOR')
        treeSSE = ssecalcu(node.left, RegressX, Y) +...
        ssecalcu(node.right, RegressX, Y);
    else
        if strcmp(node.type,'LEAF')
            leafY = Y(node.caseInd,:);
            tmpX = RegressX(node.caseInd, node.model.attrInd);
            regco = node.model.coefs;
            yhat = tmpX * regco;
            treeSSE = sum((yhat - leafY).^ 2);       
    %         [~, treeSSE] = calcBic(node, RegressX, Y);
        end
    end
    end
    
    %计算一个节点的BIC(暂不使用)
    function [bic, SSE] = calcBic(node, RegressX, Y)
    %node包括node的所有信息
    n = length(RegressX(node.caseInd, :));
    indices = crossvalind('Kfold', n, 10);
    m = length(node.model.attrInd);
    MSE = 0;
    regco = NaN(m,10);
    sse = NaN(10, 1);
    leafY = Y(node.caseInd,:);
    a = length(node.caseInd);
    % b = length(node.model.attrInd);
    leafX = RegressX(node.caseInd, node.model.attrInd);
    for i = 1:10
        test = (indices == i);
        train = ~ test;
        regco(:, i) = regress(leafY(train,1), leafX(train, :));
        yhat = leafX(test, :) * regco(:, i);
        sse(i) = sum((yhat - leafY(test,1)).^ 2);
        MSE = MSE + sse(i) / length (leafX(test, :)) ;   
    end
    SSE = sum(sse(:))/10;
    mse = MSE/10;
    bic = biccalc(mse, a, m);     
    end