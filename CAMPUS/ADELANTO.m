clc;
close all;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Buscamos mejorar el MF del lazo
%Lo que se hace es situar la frecuencia central del copensador en aquella
%frecuencia en donde el lazo sin compensar vale -10*log(alfa).
%La frecuencia crossover del sistema compensado sera distinta a la del lazo
%sin compensar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Compensador de avance de fase (con Bode)
disp('Sistema a compensar:');
G=zpk([],[0 -1],1)                         %defino la planta
disp('Especificaciones:Kv=10 y MF>45°');   %Especificaciones:Kv=10 y MF>45°

%1)Comenzamos con un control proporcional que satisfaga que Kv=10
Kc=10;

%2)Buscamos cumplir con la especificacion MF>45°
MF_esp=45;      %MF especificado
L=Kc*G;
figure;
bode(L);
title('Bode de L (sin compensar)');
grid on;
s1=allmargin(L);
MF_actual=s1.PhaseMargin;       %MF actual
Wco=s1.PMFrequency;             %frecuencia de crossover

%3)Calculamos la fase necesaria y de alli el alfa
DeltaFase=MF_esp-MF_actual+10;  %fase necesaria
alfa=(1-sin(deg2rad(DeltaFase)))/(1+sin(deg2rad(DeltaFase))); 

%4)Dado que el compensador amplificara una magnitud de mag_Wm, buscamos cual es la frecuencia Wm para la cual la magnitud de L sin compensar
%vale -mag_Wm
mag_Wm=10*log10(1/alfa); 

%5)Encontamos graficamente que Wm=4.41 rad/seg
Wm=4.41;               %frecuencia central del compensador

%6)Diseñamos el compensador
Tau=1/(sqrt(alfa)*Wm);
Wcero=1/Tau;           %frecuencia del cero
Wpolo=1/(alfa*Tau);    %frecuencia del polo
disp('Compensador obtenido:')
C=zpk(-Wcero,-Wpolo,Kc/alfa)

%7)Graficamos resultados
figure;
subplot(1,2,1); bode(C);
title('Bode del compensador de adelanto de fase');
grid on;
subplot(1,2,2);pzmap(C);
title('Compensador de adelanto de fase');
figure;
bode(L,C*G);
title('Ganancia de lazo compensada con red de adelanto de fase');
legend('Ganancia de lazo sin compensar','Ganancia de lazo compensada')
grid on;