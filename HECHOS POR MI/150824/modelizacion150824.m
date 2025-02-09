close all
clear all

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

s = tf("s");

% Definir variables como simbolicas

syms x1 x2 x3 x4 u y;
x = [x1;x2;x3;x4];

% Punto de equlibrio (x'=0)
% Equilibrio

x_e = [3; 2; 1; 1];
ue = 1/2;


f1 = -sqrt(x(1)-x(2)) + x(4);
f2 = sqrt(x(1)-x(2))-sqrt(x(2)-x(3));
f3 = sqrt(x(2)-x(3))-sqrt(x(3));
f4 = 40*u -20*x(4);

f = [f1;f2;f3;f4];

%defino la salida
y = sqrt(x(3));

A = jacobian(f,x);
%la funcion subs cambia las ocurrencias de {x(1),x(2),x(3),x(4),u} por {x_e(1),x_e(2),x_e(3),x_e(4),u_e}
A = double(subs(A,{x(1),x(2),x(3),x(4),u},{x_e(1),x_e(2),x_e(3),x_e(4),ue}));

B = jacobian(f,u);
B = double(subs(B,{x(1),x(2),x(3),x(4),u},{x_e(1),x_e(2),x_e(3),x_e(4),ue}));

C = jacobian(y,x);
C = double(subs(C,{x(1),x(2),x(3),x(4),u},{x_e(1),x_e(2),x_e(3),x_e(4),ue}));

D = jacobian(y,u);
D = double(subs(D,{x(1),x(2),x(3),x(4),u},{x_e(1),x_e(2),x_e(3),x_e(4),ue}));


% Transferencia

P = zpk(ss(A, B, C, D));

C = zpk([-1.623 -0.7775 -0.09903 -20],[0 -1000 -1000 -1000 -1000],1);



%% segunda parte 

Ts = 0.5;

wgc_inverso = Ts / (tan(deg2rad(30/2))*(4));

wgc = 1/wgc_inverso;

pade = (1-Ts/4*s)/(1+Ts/4*s);

figure();
bode(minreal(P*C), optionss);
title("Bode De PC");

k = db2mag(233);

figure();
bode(minreal(k*P*C), optionss);
title("Bode compensado de pc");

L = minreal(k*P*C*pade);

figure();
bode(L, optionss);
title("Bode compensado de pc CON PADE");


    