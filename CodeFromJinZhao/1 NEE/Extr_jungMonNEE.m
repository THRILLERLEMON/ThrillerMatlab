% Extract Jung's monthly NEE from NC file as geotiff.
% 2017.4.22
clear;close all;clc

%%  input

Mon_pt = 'G:\Jung_NEE\raw\monthly';
hds = 'CRUNCEPv6';

yrs = [1982,2013];
mns = [1,12];

outpt = 'G:\Jung_NEE\GEOTIFF\monthly';
bv = -9999;

%%  operate

Rmat = makerefmat('RasterSize',[360 720],...
    'Latlim',[-90 90],'Lonlim',[-180 180],...
    'ColumnsStartFrom','north');

mlstr = {'ANN','MARS','RF'};
ptstr = {'','_HB'};

mdys = [31,28,31,30,31,30,31,31,30,31,30,31];
for yr = yrs(1):yrs(2)
    disp(num2str(yr))
    
    mdys2 = mdys;
    if mod(yr,400)==0 || (mod(yr,4)==0 && mod(yr,100)~=0)
        mdys2(2) = 29;
    end
    
    for mn = mns(1):mns(2)
        disp(num2str(mn))
        
        for iml = 1:length(mlstr)
            for ipt = 1:length(ptstr)
                GPPnm = [Mon_pt,'\',hds,'.',mlstr{iml},...
                    '.GPP',ptstr{ipt},'.monthly.',num2str(yr),'.nc'];
                TERnm = [Mon_pt,'\',hds,'.',mlstr{iml},...
                    '.TER',ptstr{ipt},'.monthly.',num2str(yr),'.nc'];
                
                GPP = ncread(GPPnm,['GPP',ptstr{ipt}],...
                    [1 1 mn],[inf inf 1],[1 1 1])'*mdys2(mn);
                TER = ncread(TERnm,['TER',ptstr{ipt}],...
                    [1 1 mn],[inf inf 1],[1 1 1])'*mdys2(mn);
                NEE = TER-GPP;
                NEE(isnan(NEE)) = bv;
                NEE(end-11:end,:) = bv;  %
                
                NEEnm = [outpt,'\',hds,'.',...
                    mlstr{iml},'.NEE',ptstr{ipt},'.monthly.',...
                    num2str(yr),num2str(mn,'%02d'),'.tif'];
                geotiffwrite(NEEnm,NEE,Rmat)
                
                disp([' ',mlstr{iml},ptstr{ipt}])
            end
        end
    end 
end

disp('Finish!')
