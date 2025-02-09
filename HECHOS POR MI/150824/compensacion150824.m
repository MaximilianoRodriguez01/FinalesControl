%Ej 1
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
% Ceros de P = -2 doble
% Polos de P = 0, 4 doble

% reflejo polos y ceros positivos
pap = zpk([-4 -4],[4 4], 1);

%pmp * pap debe ser P
pmp = zpk([-2 -2 0], [-4 -4 0], 1);

c = zpk([-4 -4], [-2 -2 0], 1);

%% Encontrar wgc
% grafico el bode del pap y busco un w tal que 
% la fase sea -30

figure();
bode(pap, optionss);
title("pap");

wgc = 30;

%% Grafico pmp*c

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