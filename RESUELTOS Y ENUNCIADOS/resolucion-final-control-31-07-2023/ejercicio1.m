%% Ejecicio 1: compensacion

close all;
% Separo la expresion de la planta P en
% en parte fase minima Pmp y pasa todo Pap
Pmp = zpk([-2 -2],[-4 -4 0],1)
Pap = zpk([-4 -4],[4 4],1)

P = minreal(Pmp * Pap)

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

% Grafico bode Pmp
figure();bode(Pmp,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Grafico bode Pap
optionss.MagVisible='on';
figure();bode(Pap,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

Cint = zpk([],0,1)

% Grafico del bode L de la parte Pmp de minima fase y accion
% de control integral Cint
L_int_mp = Cint * Pmp;
optionss.MagVisible='on';
figure();bode(L_int_mp,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Grafico bode de L con accion integral Cint y la planta P
L = Cint * P;
optionss.MagVisible='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=30;
figure();bode(L,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Disenio de una red de adelanto Ccomp para aumentar la fase a 78 grados
% en w=31 rad/s que es el area donde puedo establecer una frecuencia de
% cruce wgc. Esto se logra poniendo un cero una decada antes(3.1) de 31
% rad/s y un polo una decada despues(310)
z_lead = -3.1;
p_lead = -310;
Ccomp = zpk(z_lead,p_lead,1)

% Grafico del bode de la red de adelanto Ccomp
optionss.PhaseMatchingValue=0;
optionss.PhaseMatchingFreq=0;
figure();bode(Ccomp,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Grafico del bode L si se controla a la planta P con una red de adelanto
% Ccomp junto con accion integral Cint
L = Ccomp * Cint * P;
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=30;
figure();bode(L,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Ajuste de la ganancia para maximizar el margen de fase, en este caso el
% ejercicio pide que sea mayor 60 grados. Del grafico donde se ve mayor
% margen de fase es en w=66.5 rad/s
kp = db2mag(86.5);
C = Cint * Ccomp * kp;
L = C * P;
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=30;
figure();bode(L,optionss,{.1,1000});
set(findall(gcf,'type','line'),'linewidth',2);

