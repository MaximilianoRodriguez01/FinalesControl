%% Problema Polo Cero en RHP angulo lag aportado :
clear all;close all;clc
s=tf('s');
p=3
z=30
m = 1 ; %multiplicidad
%Papp=exp(-s*0.5);
Pap1=zpk([-p],[p],1);
Pap2=zpk([z],[-z],-1);
Pap1
Pap2
Pap = (Pap1 * Pap2)^m

optionss=bodeoptions;
optionss.MagVisible='off';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';
%Pap= Pap1 * Pap2 ;
figure();bode(Pap1,Pap2,Pap,optionss,{.1,1000});
title('Pap1 Pap2 Pap');
legend('Pap1 p=xp','Pap2 zero xz','(Pap1*Pap2)^m','Location','south');
set(findall(gcf,'type','line'),'linewidth',2);

figure();
pzmap(Pap);

%P=minreal((Pap1*Pap2)^m);
