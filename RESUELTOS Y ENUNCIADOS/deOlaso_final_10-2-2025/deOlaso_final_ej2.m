clear all; close all; clc

%% Problema 2:
% Estabilizar el lazo usando un controlador que tenga acción integral

s = tf('s');

% Separo a mi planta en una parte de fase mínima y una parte pasatodo
% P = (-(s-1000))(-(s-800))(-(s-600))
%     -------------------------------
%             (s-1)(s-2)(s-3)
% Necesitamos multiplicar y dividir por cada polo y cero inestable
% P = -(s+1000)(s+800)(s+600)   (s-1000)(s-800)(s-600)   (s+1)(s+2)(s+3)
%     ----------------------- * ---------------------- * ---------------
%         (s+1)(s+2)(s+3)       (s+1000)(s+800)(s+600)   (s-1)(s-2)(s-3)
Pmp = zpk([-1000 -800 -600], [-1 -2 -3], -1);
Pap1 = zpk([1000 800 600], [-1000 -800 -600], 1);
Pap2 = zpk([-1 -2 -3], [1 2 3], 1);
Pap = Pap1*Pap2;
P = minreal(Pap*Pmp);

% Configuración de los gráficos de Bode
my_bode_options = bodeoptions;
my_bode_options.PhaseMatching = 'on';
my_bode_options.PhaseMatchingFreq = 1;
my_bode_options.PhaseMatchingValue = -180;
my_bode_options.Grid = 'on';

% Gráfico del pasatodo
figure();
bode(Pap, my_bode_options);
title('Bode Pap');

% Gráfico de la parte de mínima fase
figure();
bode(Pmp, my_bode_options);
title('Bode Pmp');




% Defino a mi controlador inicial
k = 1;
C = zpk([-1 -2 -3],[0 -1000 -1000], k);


%% AGREGO COSAS MAXI

pmpc = minreal(Pmp*C);

figure();
bode(pmpc, my_bode_options);
title("pmpc sin compensar");

%%

% Este controlador:
% - Anula los polos de Pmp
% - Posee acción integral
% - Posee dos polos grandes para que sea realizable (#polos >= #ceros)

% Graficamos L para hallar el k
L = minreal(P*C);
figure();
bode(L, my_bode_options);
title('Bode L = C*P con k=1');

% Corregimos el k y definimos a nuestro lazo L=PC
k = db2mag(-21.6);
C = zpk([-1 -2 -3],[0 -1000 -1000], k);
L = minreal(P*C);
figure();
bode(L, my_bode_options);
title('Bode L = C*P con k corregido');

% Obtenemos un MF muy cercano a 60°

% 4 transferencias típicas
S = 1/(1+L);
T = 1 - S;
PS = minreal(P*S);
CS = minreal(C*S);

% Bodes
figure();
subplot(2, 2, 1);
bode(S, my_bode_options);
title('Bode S');
grid on;

subplot(2, 2, 2);
bode(T, my_bode_options);
title('Bode T');
grid on;

subplot(2, 2, 3);
bode(PS, my_bode_options);
title('Bode PS');
grid on;

subplot(2, 2, 4);
bode(CS, my_bode_options);
title('Bode CS');
grid on;

% Conseguimos los margenes del lazo L
[Gm, Pm, Wcg, Wcp] = margin(L);

figure();
nyquist(L);
% Distancia al -1: 0.834
% sm = 1/0.834
sm = mag2db(1/0.834);
