%% Ejercicio 3:

close all;
z = 1000;
Papz = zpk([z z z z],[-z -z -z -z],1)

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

figure();bode(Papz,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

p = 1.071;
Papp = zpk([-p -p -p -p],[p p p p],1)

figure();bode(Papp,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

Pap = Papz * Papp
figure();bode(Pap,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

