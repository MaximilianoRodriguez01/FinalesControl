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


s = tf("s");


P = tf((1000-s)*(800-s)*(600-s)/((s-1)*(s-2)*(s-3)));
figure();
pzmap(P);
title("Diagrama de polos y ceros");

pap = zpk([-3 -2 -1 600 800 1000], ...
          [-1000 -800 -600 1 2 3], ...
          1);

pmp = zpk([-1000 -800 -600], ...
          [-3 -2 -1], ...
          1);

c = zpk([-3 -2 -1], [-1000 -800 -600 0], 1);

figure();
bode(pap, optionss);
title("pap");

% Busco fase -30 en el pap y encuentro wgc 2.72

% wgc = 2.72;

pmpc = minreal(pmp*c);

figure();
bode(pmpc, optionss);
title("pmpc sin compensar");


% En el bode encuentro que en w = 2.72 hay ganancia -8.7

k = db2mag(8.7);

c = k*c;

pmpc = minreal(pmp*c);

figure();
bode(pmpc, optionss);
title("pmpc");

L = minreal(pap*pmpc);

figure();
bode(L, optionss);
title("L");

%% Grupo de las 4

S = 1 / (1 + L);
T = 1 - S;
PS = minreal(P*S);
CS = minreal(c*S);








