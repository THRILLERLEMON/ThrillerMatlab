function forest_h = CombineF(F1, F2) 
 %��ɭ��F2�ϲ���ɭ��F1
 m = cellfun('isempty', F1);  
 n = cellfun('isempty', F2);
 [mF2, nF2] = size(n);
 number = find(m, 1,'first' );
 for j = 2:mF2*nF2
     if n(j) == 0
         F1{number} = F2{j};
         number = number + 1;
     end
     eatstr = ['Complated ����', num2str(j*100/(mF2*nF2)), '%'];
     disp(eatstr);
 end 
 forest_h = F1;
 disp('Have fun, you have done ~ ~ ~');
end
 