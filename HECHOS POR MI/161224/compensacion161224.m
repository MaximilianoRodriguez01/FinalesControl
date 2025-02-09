%Ej 2
clear all; 
close all;


%% Opciones para el Bode
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

%% Compensacion

pap = zpk([50 50 -1 -1],[1 1 -50 -50], 1);

pmp = zpk([-50 -50], [-1 -1], 1);

c = zpk([-1 -1], [-50 -50 0], 1);

figure();
bode(pap, optionss);
title("pap");

wgc = 6.21;

pmpc = minreal(pmp*c);

figure();
bode(pmpc, optionss);
title("pmpc sin compensar");

k = db2mag(15.9);

pmpc = minreal(k*pmpc);

figure();
bode(pmpc, optionss);
title("pmpc");

L = minreal(pap*pmpc);

figure();
bode(L, optionss);
title("L");

%% Luego, se tiene el grupo de las 4 transferencias.

S = 1 / (1 + L);
T = 1 - S;
PS = minreal(P*S);
CS = minreal(C*S);

% Por último, simulo respuesta al escalón de referencia y al de
% perturbación.

figure(); step(T); title('T');grid on
figure(); step(PS); title('PS');grid on

%calculo el Margen de estabilidad, el cual lo consigo graficando la
%Sensiblidad y haciendo la inversa del pico maximo

figure();
bode(S,optionss);
title("S");

Sm = 1/db2mag(7.35);







