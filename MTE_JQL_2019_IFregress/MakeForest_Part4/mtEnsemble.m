function mtEnsemble(mtree, SplitX, RegressX, Y, AllSplitX, AllRegressX, AllY, binCat, outPath, MinNumCases, MinCaseNumber, treeNumber, ensembleNumber)
    % set(0,'RecursionLimit,10000000000');
    if  nargin < 10 || isempty(MinNumCases)
        MinNumCases = 90;
    end
    
    if nargin < 11 || isempty(MinCaseNumber)
        MinCaseNumber = 40;
    end
    
    if nargin < 12 || isempty(treeNumber)
        treeNumber = 200;
    end
    
    if nargin < 13 || isempty(ensembleNumber)
        ensembleNumber = 25;
    end
    
    %定义元胞数组forest
    forest = cell(treeNumber/10, 10);
    %
    forest{1} = mtree;
    
    global mtreeF1;
    global mtreeTest;
    global panduannnn;
    
    mtreeTest = [];
    panduannnn = [];
    
    tic;
    %随机选择树
    %随机生长树
    mm = 2;
    while isempty(forest{treeNumber/10, 10})
        tempnnz = zeros(treeNumber/10,10);
        for kk = 1:treeNumber/10
            for ll = 1:10
                if ~isempty(forest{kk, ll})
                    tempnnz(kk, ll) = 1;
                else
                    tempnnz(kk, ll) = 0;
                end
            end
        end
        tempnumber = nnz(tempnnz);
        randnumber = randi(tempnumber, 1);
        growTree(forest{randnumber}, SplitX, RegressX, Y, AllSplitX, AllRegressX, AllY,binCat, MinNumCases, MinCaseNumber);
        forest{mm} = mtreeF1;
        mm = mm+1;
        mtreeF1 = [];
        %保存路径，需修改
        save([outPath,'Forest4.mat'],'forest');
    end
    
    tmpbic = NaN(treeNumber/10,10);
    for iii = 1:treeNumber/10
        for jjj = 1:10
            tmpbic(iii, jjj) = forest{iii, jjj}.bic;
        end
    end
    ensemble = cell(ensembleNumber/5,5);
    sortbic = sort(tmpbic(:));
    for i = 1:ensembleNumber
        mmm = tmpbic(:) == sortbic(i);
        ensemble{i} = forest{mmm};
    end
    
    toc;
    save([outPath,'ensemble4_',num2str(ensembleNumber),'.mat'],'ensemble');
    fprintf('Have fun, Model Tree Ensemble have done...');
    
    end
    
    %=============================辅助函数=================================%
    %随机分裂生长树
    function growTree(tree1, SplitX, RegressX, Y, AllSplitX, AllRegressX, AllY, binCat, MinNumCases, MinCaseNumber)
    global mtreeF1;
    global mtreeTest;
    global panduannnn;
    
    number = 1;
    mtreeF1 = tree1;
    number1 = SignInteriorNode(0, number);
    
    leafnumber =0;
    %判断是否叶子节点大于两个
    if number1 >1
        while leafnumber <=2
            number2 = randi([3,(number1-1)], 1);
            leafnumber = LeafNumber(number2, mtreeF1, leafnumber);
        end
    else
        number2 = 1;
    end
    CutSplitNode(0, number2, SplitX, RegressX, Y, binCat, mtreeF1.caseInd, MinNumCases, MinCaseNumber);
    currentbic = calcBicSubtree(mtreeF1, AllSplitX, AllRegressX, AllY, binCat);
    
    %生长树
    Grow = false;
    while Grow == false
        
        GrowTree = true;    
        while GrowTree == true
            number3 = signLeafNode(0, number);
            tmpbic = NaN(number3-1, 1);
            for ii = 1: (number3 - 1)
                mtreeTest = mtreeF1;
                foundLeafNode(0, ii, SplitX, RegressX, Y, mtreeTest.caseInd, binCat, MinNumCases, MinCaseNumber);
                tmpbic(ii) = calcBicSubtree(mtreeTest, AllSplitX, AllRegressX, AllY, binCat);
                str1 = ['mtreeForest',num2str(ii),'=mtreeTest',';'];
                eval(str1);
                mtreeTest = [];
            end
            number4 = find(tmpbic(:) == min(tmpbic));
            minbic = tmpbic(number4);
            if minbic < currentbic
                currentbic = minbic;
                str2 = ['mtreeF1','=mtreeForest',num2str(number4),';'];
                eval(str2);
                GrowTree = true;
            else
                GrowTree = false;
            end
            clc;
        end
        
        %判断最后的分裂点中是否有random的，然后删掉，再生长
        panduannnn = [];
        panduanmm = panduan(0, 1);
        if  ismember(1, panduannnn)
            Grow = false;
        else
            Grow = true;
        end
    end
    mtreeF1.bic = currentbic;
    end
    
    %标记所有内部节点
    function number = SignInteriorNode(code, number)
    %随机选出一个内部节点
    global mtreeF1;
    code = num2str(code);
    a = 'mtreeF1';
    b = '.left';
    c = '.right';
    d = '.type';
    e = '.ID';
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
    % a = a;
    aa = [a, d];
    aaa = eval(aa);
    if strcmp(aaa,'LEAF')
        return
    else
        if strcmp(aaa,'INTERIOR')
            code = str2num(code);
            str1 = [a,e, '= number'];
            eval(str1);
            number = number + 1;
            number = SignInteriorNode((code*10)+1, number);
            number = SignInteriorNode((code*10)+2, number);
        end
    end
    end
    
    %把随机选中的内部节点左右信息和分裂信息裁剪掉
    function CutSplitNode(code, number2, SplitX, RegressX, Y, binCat, caseInd, MinNumCases, MinCaseNumber)
    global mtreeF1;
    code = num2str(code);
    a = 'mtreeF1';
    b = '.left';
    c = '.right';
    d = '.type';
    e = '.ID';
    f = '.caseInd';
    g = '.leftInd';
    h = '.rightInd';
    k = '.model.coefs';
    l = '.model.attrInd';
    m = 'LEAF';
    n = 'INTERIOR';
    o = 'OPEN';
    p = 'CLOSED';
    q = '.splitLocation';
    r = '.splitAttribute';
    s = '.condition';
    st = '.splitType';
    ran = 'RANDOM';
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
    dd = [a, d];
    ddd = eval(dd);
    ee = [a, e];
    if strcmp(ddd,'INTERIOR')
        eee = eval(ee);
        if eee == number2
            str1 = [a,'=rmfield(eval(a),''left'')'];
            str2 = [a,'=rmfield(eval(a),''right'')'];
            str3 = [a,'=rmfield(eval(a),''leftInd'')'];
            str4 = [a,'=rmfield(eval(a),''rightInd'')'];
            str5 = [a,'=rmfield(eval(a),''splitAttribute'')'];
            str6 = [a,'=rmfield(eval(a),''splitLocation'')'];
            eval(str1);
            eval(str2);
            eval(str3);
            eval(str4);
            eval(str5);
            eval(str6);
            ff = [a, f];
            fff = eval(ff);
            node1 = randomSplit(SplitX(caseInd, :), RegressX(caseInd, :), Y(caseInd, :), binCat, fff, MinCaseNumber);
            eval([a,b,d,'=','m']);
            eval([a,c,d,'=','m']);
            eval([a,d,'=','n']);
            eval([a,s,'=','o']);
            eval([a,st,'=','ran']);
            str7 = [a,g,'=node1.leftInd'];
            str8 = [a,h,'=node1.rightInd'];
            str9 = [a,b,k,'=node1.left.model.coefs'];
            str10 = [a,b,l,'=node1.left.model.attrInd'];
            str11 = [a,c,k,'=node1.right.model.coefs'];
            str12 = [a,c,l,'=node1.right.model.attrInd'];
            str13 = [a,r,'=node1.splitAttribute'];
            str14 = [a,q,'=node1.splitLocation'];
            str15 = [a,b,f,'=node1.leftInd'];
            str16 = [a,c,f,'=node1.rightInd'];
            eval(str7);
            eval(str8);
            eval(str9);
            eval(str10);
            eval(str11);
            eval(str12);
            eval(str13);
            eval(str14);
            eval(str15);
            eval(str16);
            if length(node1.leftInd)>=MinNumCases
                eval([a,b,s,'=','o']);
            else
                eval([a,b,s,'=','p']);
            end
            if length(node1.rightInd)>=MinNumCases
                eval([a,c,s,'=','o']);
            else
                eval([a,c,s,'=','p']);
            end
            return
        else
            code = str2num(code);
            sss = [a,g];
            ssss = [a,h];
            ttt = eval(sss);
            tttt = eval(ssss);
            CutSplitNode((code*10)+1, number2, SplitX, RegressX, Y, binCat, ttt, MinNumCases, MinCaseNumber);
            CutSplitNode((code*10)+2, number2, SplitX, RegressX, Y, binCat, tttt, MinNumCases, MinCaseNumber);
        end
    else
        if strcmp(ddd, 'LEAF')
            return
        end
    end
    end
    
    %对随机选中的内部节点进行随机分裂
    function node = randomSplit( SplitX2, RegressX2, Y2, binCat, caseInd, MinCaseNumber) 
    node.caseInd = caseInd;
    [mSplitX, nSplitX] = size(SplitX2);
    random = false;
    while random == false
        m =randi(mSplitX, 1);
        n = randi(nSplitX, 1);
        if binCat(n) == 0
            [leftInd, rightInd] = Conleftright(SplitX2(m, n), n, SplitX2);
        else
            if binCat(n) == 1
                Cat_type = tabulate(SplitX2(:,n));
                Cat_type1 = Cat_type(:, 1);
                Cat_type2 = Cat_type(:, 2);
                Cat_type3 = Cat_type1(Cat_type2 == 1);
                random_a = randi(length(Cat_type3), 1);
                leftInd = find(Cat_type3 < Cat_type3(random_a));
                rightInd = find(Cat_type3 >= Cat_type3(random_a));
            else
                continue
            end
        end
            
        if (length(leftInd) >= MinCaseNumber) && (length(rightInd) >= MinCaseNumber)
            [left.coefs, left.attrInd] = bestParameter(RegressX2(leftInd, :), Y2(leftInd, :));
            [right.coefs, right.attrInd] = bestParameter(RegressX2(rightInd, :), Y2(rightInd, :));
            leftInd = caseInd(leftInd);
            rightInd = caseInd(rightInd);
            node.leftInd = leftInd;
            node.rightInd = rightInd;
            node.type = 'INTERIOR';
            node.left.model.coefs = left.coefs;
            node.left.model.attrInd = left.attrInd;
            node.right.model.coefs = right.coefs;
            node.right.model.attrInd = right.attrInd;
            node.splitAttribute = n;
            node.splitLocation = SplitX2(m, n);
            random = true;
        else
            random = false;
        end    
    end
    end
    
    %找到选取的内部节点并判断是否有大于2的叶子节点
    function leafnumber = LeafNumber(num, node, leafnumber)
    if strcmp(node.type, 'INTERIOR') 
        if node.ID == num
            leafnum = 0;
            leafnum =  LeafNumber1(node, leafnum);
            leafnumber = leafnum;
            return
        else
            leafnumber = LeafNumber(num, node.left, leafnumber);
            leafnumber = LeafNumber(num, node.right, leafnumber);    
        end
    end
    end
    
    function leafnum = LeafNumber1(node, leafnum)
    if strcmp(node.type,'INTERIOR')
        leafnum = LeafNumber1(node.left, leafnum);
        leafnum = LeafNumber1(node.right, leafnum);
    else
        if strcmp(node.type,'LEAF')
            leafnum = leafnum +1;
        end
     
    end
    end
    
    %判断最后分裂的节点中是否有random的
    function m = panduan(code, m)
    global mtreeF1;
    global panduannnn;
    code = num2str(code);
    a = 'mtreeF1';
    b = '.left';
    c= '.right';
    d = '.type';
    e = '.splitType';
    f = 'LEAF';
    g = '.condition';
    h = 'OPEN';
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
    ad = [a,d];
    ae = [a,e];
    add = eval(ad);
    aa = eval(a);
    abd = [a,b,d];
    acd = [a,c,d];
    if strcmp(add,'INTERIOR')
        if isfield(aa, 'splitType')
            aee = eval(ae);
            if strcmp(aee, 'RANDOM')
                abdd = eval(abd);
                acdd = eval(acd);
                if (strcmp(abdd, 'LEAF') && strcmp(acdd, 'LEAF'))
                    str1 = [a,'=rmfield(eval(a),''left'')'];
                    str2 = [a,'=rmfield(eval(a),''right'')'];
                    str3 = [a,'=rmfield(eval(a),''leftInd'')'];
                    str4 = [a,'=rmfield(eval(a),''rightInd'')'];
                    str5 = [a,'=rmfield(eval(a),''splitAttribute'')'];
                    str6 = [a,'=rmfield(eval(a),''splitLocation'')'];
                    str7 = [a,'=rmfield(eval(a),''splitType'')'];
                    eval([a,d,'=','f']);
                    eval([a,g,'=','h']);
                    eval(str1);
                    eval(str2);
                    eval(str3);
                    eval(str4);
                    eval(str5);
                    eval(str6);
                    eval(str7);
                    panduannnn(m) = 1;
                    m = m+1;
                else
                    panduannnn(m) = 2;
                    m = m+1;
                end
            end
        else
            code = str2num(code);
             m = panduan((code*10)+1, m);
             m = panduan((code*10)+2, m);
        end
    else
        if strcmp(add, 'LEAF')
            panduannnn(m) = -1;
            m = m+1;
        end
    end
    end
    
    %============================from mtbuild=================================%
    %%%%%%%%%%%%%%%%%%%
    %标记叶子
    function m = signLeafNode(code, m)
    global mtreeF1;
    code = num2str(code);
    a = 'mtreeF1';
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
    
    %连续变量分裂
    function [leftInd, rightInd] = Conleftright(split, splitAttribute, SplitX2)
        leftInd = find(SplitX2(:, splitAttribute) < split);
        rightInd = find(SplitX2(:, splitAttribute) >= split);
    end
     
    %离散变量分裂
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
            %% Groups中存放了可以合并的一行，第一次运行时这一行是含有两个类型，以后不定,最后值剩余两行，NaN是20行20列
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
    
    %两个类型合并
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
    
    %计算一棵树、多个样本的预测值
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
    