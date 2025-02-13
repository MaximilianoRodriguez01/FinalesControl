%Ej 1
clear all; 
close all;

% Diseñar un controlador para la planta 



%% Opciones para el Bode
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

%% Pap y pmp

% reflejo polos y ceros positivos
pap = zpk([-8 -7 1 2],[-2 -1 7 8], 1);

%pmp * pap debe ser P
pmp = zpk([-2 -1], [-8 -7], 1);

c = zpk([-8 -7], [-2 -1 0], 1);

% c = zpk([-2 -1], [-8 -7 0], 1);

%% Pap

figure();
bode(pap,optionss);
title("pap")

%% wgc = 0.215

pmpc = minreal(pmp*c);
figure();
bode(pmpc, optionss);
title("pmpc sin compensar");

% Encuentro 13 db en 0.215 y -33 db en 45 grados

k = db2mag(-13.3);

pmpc = minreal(k*pmpc);

figure();
bode(pmpc, optionss);
title("pmpc");

%% L

L = minreal(pap*pmpc);

figure();
bode(L, optionss);
title("L");

%% t

T = minreal(L / (1 + L)); % Función de transferencia en lazo cerrado
figure;
pzmap(T);
title('Polos y Ceros de la función en lazo cerrado');
grid on;