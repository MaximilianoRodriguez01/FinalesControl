clear all
close all

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

L = zpk([-2 -2], [0 -1 1], 1);

figure();
bode(L, optionss);
title("L");

figure();
nyqlog(L);


