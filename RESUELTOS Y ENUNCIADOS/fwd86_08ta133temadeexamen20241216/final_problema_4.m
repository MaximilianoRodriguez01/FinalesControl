clear all;close all;clc;

s = tf('s');
P = 0.0025/((s+0.059)*(s+0.02)*(s+1.066));

% Matrices de la linealizacion hecho en el ejercicio 3
A = [-0.125000000000000,0.125000000000000,0.250000000000000;
    0.500000000000000,-1,0;
    0,0,-0.020000000000000];

B = [0;0;0.020000000000000];

C = [0 1 0];

D = 0;

%Uso la transferencia obtenida y la paso a variables de estado
G = ss(zpk(P));

%Calculo las matrices correspondientes en base a la transferencia y 
% el agregado de la accion integral
Aa = [A zeros(order(G),1) ; -C 0];
Ba = [B; -G.d];

% Ubico todos los polos en -0.01 (eleccion arbitraria) 
% que son estables. El orden es mayor debido a la accion integral
Ka = acker(Aa, Ba, [-0.01 -0.01 -0.01 -0.01]);

K = Ka(1:order(G));
kI = -Ka(end);