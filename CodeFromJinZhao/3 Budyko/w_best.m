% w最佳值计算函数 Fu
% 需要输入ET、Pr、ET0、w初始值（0）、搜索步长
function [w_b, ET_err] = w_best(E0, Pr, ET, wgap)

    w = 0 + wgap;
    ETw = E0 + Pr - Pr*((E0/Pr)^w + 1)^(1/w);
    
    while ETw < ET
        w = w + wgap;
        if w > 20
            break
        end
        ETw = E0 + Pr - Pr*((E0/Pr)^w + 1)^(1/w);
    end
    
    if ETw < ET
        w_b = nan;
        ET_err =nan;
    else
        ETw1 = E0 + Pr - Pr*((E0/Pr)^(w - wgap) + 1)^(1/(w - wgap));
        
        if abs(ETw1 - ET) < abs(ETw - ET)
            w_b = w - wgap;
            ET_err = ETw1 - ET;
        else
            w_b = w;
            ET_err = ETw - ET;
        end
    end
end
