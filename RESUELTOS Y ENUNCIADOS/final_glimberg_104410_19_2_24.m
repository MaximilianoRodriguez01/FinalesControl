clear all;clc;close all;
s = tf('s');

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';
%analizo lo realizado a mano a ver si con lo realizado llego a un mf=60
%grados

pmp=(s+2)^2/(s*(s+4)^2)
pap=(s+4)^2/(s-4)^2
P=pmp*pap;
k=29.84;
%k nuevo para mejorar el mf 
k=40;
c=k*(s+4)/s;
bode(pmp*c*pap);
L=pmp*c*pap
%lo que voy a realizar es iteracion tal de encontrar el ts que no me reste
%mas de 5 grados de mf.
T = [0.1 0.22 0.01 0.005 0.004 0.003 0.002 0.001];
%%

figure()
bode(L, optionss, 'black');
grid on
hold on
for i=1:length(T)
    T(i)
    Pad=zpk([1/(T(i)/4)],[-1/(T(i)/4)],-1);
    bode(L*Pad, optionss)
end

legend('L', '0.1', '0.22',' 0.01 ','0.005 ','0.004 ','0.003 ','0.002 ','0.001')
hold off
%%
L=pmp*c*pap;
C=k*(s+4)/s;
pade=zpk([1/(0.004 /4)],[-1/(0.004 /4)],-1);
l=L*pade;
%grafico la respuesta en frecuencia del sistema
S=1/(1+l);
T=1-S;
PS=minreal(P*S);
CS=minreal(C*pade*S);
% Bodes
%optionss.MagVisible='on';
freqrange={10^-1,100};
figure();
h1=subplot(2,2,1);
bode(L,optionss,freqrange);title('L')
optionss.PhaseVisible='off';
h2=subplot(2,2,2);
bode(S,T,optionss,freqrange);title('S & T')
h3=subplot(2,2,3);
bode(PS,optionss,freqrange);title('PS')
h4=subplot(2,2,4);
bode(CS,optionss,freqrange);title('CS')
set(findall(gcf,'type','line'),'linewidth',2);
figure
bode(S)
% sm 1/pico =>
figure
step(CS)
figure
%pico corto y que llegue a 1 o estabilize
step(T)
%%
%simulink
Ts=0.004;
Cd = c2d(c, Ts, 'tustin');