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

syms x1 x2 x3 x4 x5 x6 u y;
x = [x1;x2;x3;x4;x5;x6];

% Punto de equlibrio (x'=0)
% Equilibrio

x_e = [2; 1; 1; 0; 0; 0;];
ue = 1;
ye = 1;


f1 = (x(3)-sqrt(x(1)-x(2)))/(x(1)^2);

f2 = (sqrt(x(1)-x(2))-sqrt(x(2)))/(x(2)^2);

f3 = x(4);
f4 = x(5);
f5 = x(6);

f6 = (u - (1/2)*x(6) - (3/2)*x(5) - 2*x(4) - x(3)) * 16;


f = [f1;f2;f3;f4;f5;f6];

%defino la salida
y = x(2);

A = jacobian(f,x);

A = double(subs(A,{x(1),x(2),x(3),x(4),x(5), x(6),u},{x_e(1),x_e(2),x_e(3),x_e(4),x_e(5),x_e(6),ue}));

B = jacobian(f,u);
B = double(subs(B,{x(1),x(2),x(3),x(4),x(5), x(6),u},{x_e(1),x_e(2),x_e(3),x_e(4),x_e(5),x_e(6),ue}));

C = jacobian(y,x);
C = double(subs(C,{x(1),x(2),x(3),x(4),x(5), x(6),u},{x_e(1),x_e(2),x_e(3),x_e(4),x_e(5),x_e(6),ue}));

D = jacobian(y,u);
D = double(subs(D,{x(1),x(2),x(3),x(4),x(5), x(6),u},{x_e(1),x_e(2),x_e(3),x_e(4),x_e(5),x_e(6),ue}));


% Transferencia

P = zpk(ss(A, B, C, D));

Avals = eig(P);

C = zpk([-0.0586 -1.0664 -2 -2 -2 -2],[0 -100 -100 -100 -100 -100],1);



%% segunda parte 

Ts = 0.5;

wgc_inverso = Ts / (tan(deg2rad(30/2))*(4));

wgc = 1/wgc_inverso;

pade = (1-Ts/4*s)/(1+Ts/4*s);

figure();
bode(minreal(P*C), optionss);
title("Bode De PC SIN COMPENSAR");

k = db2mag(199);

figure();
bode(minreal(k*P*C), optionss);
title("Bode compensado de pc");

L = minreal(k*P*C*pade);

figure();
bode(L, optionss);
title("Bode compensado de pc CON PADE");


%% Grupo de las 4

S = 1 / (1 + L);
T = 1 - S;
PS = minreal(P*S);
CS = minreal(C*S);

%% Calculo el Margen de estabilidad, el cual lo consigo graficando la
% Sensiblidad y haciendo la inversa del pico maximo

figure();
bode(S, optionss);
title("S");

Sm = 1/db2mag(4);

smdb = mag2db(Sm);

figure();
step(feedback(L,1));
title("Respuesta al escalon de T");

%tiene un sobrepico menor al 10%

%% C) Simulo un escalon de referencia tal que y = 1.1
% mi salida tiene que seguir una referencia.
% En la consigna me dicen que "y" termina valiendo 1.1
% y que la referencia es un escalon.
% Sabemos que Y(s) = T(s) * R(s), asi que:

ref = 1.1;
y_ref = T * ref;

figure();
% La funcion step ya me realiza el grafico de la respuesta al escalon
step(y_ref);
grid on;
title("respuesta al escalon de entrada con y = 1.1");


%% D) respuesta a una perturbacion de 0.1

ref_perturbacion = 0.1;
figure;
step(ref_perturbacion * S);
grid on;
title('Respuesta del sistema ante un escalón de perturbación de magnitud 0.1');

% tarda 2 segundos en volver al estado sin perturbacion
% por lo que considero que le cuesta rechazar a las perturbaciones


C_dig = c2d(C*k, 0.5, 'tustin');