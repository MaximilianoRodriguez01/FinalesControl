%% Ej 1
clear all; 
close all;


%% Opciones para el Bode
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

%% Pap y pmp
% Ceros de P = 1000 cuadruple
% Polos de P = p cuadruple

p = 1.071;
z = 1000;

Ps = zpk([z z z z], [p p p p], 1);

% reflejo polos y ceros positivos
pap = zpk([-p -p -p -p ...
           z z z z], ...
           [-z -z -z -z ...
           p p p p], ...
           1);

%pmp * pap debe ser P
pmp = zpk([-z -z -z -z], [-p -p -p -p], 1);

c = zpk([-p -p -p -p], [-z -z -z -z 0], 1);

%% Pap

figure();
bode(pap,optionss);
title("pap")

%% de lo escrito tengo wgc = 1014.9

pmpc = minreal(pmp*c);
figure();
bode(pmpc, optionss);
title("pmpc sin compensar");

% Encuentro -30 db

k = db2mag(30);

pmpc = minreal(k*pmpc);

figure();
bode(pmpc, optionss);
title("pmpc");

%% L

L = minreal(pap*pmpc);

figure();
bode(L, optionss);
title("L");

%% PxC confirmacion

figure();
Ls = minreal(c*k*Ps);
bode(Ls, optionss);
title("PxC");