clear all; close all; clc

%% Linealización
% Definiciones simbólicas
syms x1 x2 x3 x4 x5 x6 u y;
% x1 = H1
% x2 = H2
% x3 = Fin
% x4 = Fin'
% x5 = Fin''
% x6 = Fin'''

% Funciones de estado no lineales
p = 2;
f1 = (x3 - sqrt(x1 - x2))/x1^2;
f2 = (sqrt(x1-x2) - sqrt(x2))/x2^2;
f3 = x4;
f4 = x5;
f5 = x6;
% Desarrollando la antitransformada de Laplace...
f6 = -4*p*x6 -6*(p^2)*x5 -4*(p^3)*x4 -(p^4)*x3 + (p^4)*u;
y = x2;
x = [x1; x2; x3; x4; x5; x6];
f = [f1; f2; f3; f4; f5; f6];

% Matrices linealizadas
A = jacobian(f,x);
B = jacobian(f,u);
C_i = jacobian(y,x);
D = jacobian(y,u);

% Puntos de equilibrio
x2e = 1;    % Establecido por la consigna
x1e = 2;    % Sale de la ecuación de x2' (cero en el equilibrio)
x3e = 1;    % Sale de la ecuación de x1' (cero en el equilibrio)
x4e = 0;    % Derivada, nula en el equilibrio
x5e = 0;    % Derivada, nula en el equilibrio
x6e = 0;    % Derivada, nula en el equilibrio
ue = -1;    % Sale de la ecuación antitransformada de Fin(s)
ye = x2e;

% Evaluar el jacobiano en los valores de equilibrio
A = subs(A, str2sym({'x1','x2','x3','x4','x5','x6','u'}), {x1e,x2e,x3e,x4e,x5e,x6e,ue});
B = subs(B, str2sym({'x1','x2','x3','x4','x5','x6','u'}), {x1e,x2e,x3e,x4e,x5e,x6e,ue});
C_i = subs(C_i, str2sym({'x1','x2','x3','x4','x5','x6','u'}), {x1e,x2e,x3e,x4e,x5e,x6e,ue});
D = subs(D, str2sym({'x1','x2','x3','x4','x5','x6','u'}), {x1e,x2e,x3e,x4e,x5e,x6e,ue});

Ass = double(A);
Bss = double(B);
Css = double(C_i);
Dss = double(D);

% Transferencia de la planta linealizada
P = minreal(zpk(ss(Ass, Bss, Css, Dss)));

% P = 2/((s+0.05861)(s+1.066)(s+2)^4)

% Configuración de los gráficos de Bode
my_bode_options = bodeoptions;
my_bode_options.PhaseMatching = 'on';
my_bode_options.PhaseMatchingFreq = 1;
my_bode_options.PhaseMatchingValue = -180;
my_bode_options.Grid = 'on';

%% Digitalizacion
% Parametros de digitalización
Phase_dig = 5;    % Convención de 5° en digitalización
Ts = 0.5;
Wgc_max = 4/Ts * tan(deg2rad(Phase_dig)/2);    % Limitación del diseño
% Wgc_max = 0.3493 rad/s

% Aproximación de Padé (Z = 4/Ts)
s = tf('s');
Pd = (1 - Ts/4 * s)/(1 + Ts/4 * s);

%% Diseño del controlador
% Defino a mi controlador inicial
k = 1;
C = zpk([-0.05861 -1.066],[0 -100],k);

% Este controlador:
% - Posee acción integral con el polo en el origen
% - Anula los dos polos más chicos de P
% - Posee un polo en frecuencias altas para que el controlador sea
% realizable (#polos >= #ceros)

% Graficamos L para ajustar la ganancia k
L = minreal(C*P*Pd);
figure();
bode(L, my_bode_options);
title('Bode L = C*P*Pd con k=1');

% Corregimos el k y definimos a nuestro lazo L
% L(0.232 rad/s) = (-45.6dB, -120°)
% Si wgc = 0.232 rad/s <-> MF = 60°
% Este wgc cumple con la limitación de diseño impuesta por la
% digitalización y su cero con parte real positiva asociado
k = db2mag(45.6);
C = zpk([-0.05861 -1.066],[0 -100],k); 
L = minreal(C*P*Pd);
figure();
bode(L, my_bode_options);
title('Bode L = C*P*Pd con k corregido');

%% Análisis del lazo
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

%% Sobrepico
% Respuesta al escalón de referencia, asociada con T = Y/R
tiempo = 30;
figure();
step(T,tiempo);title('y(t), respuesta al escalón de referencia');
grid on
% Se observa que el sobrepico llega hasta 1.07 (menor al 10% de 1)

%% Márgen de estabilidad
% Diagrama de nyquist para obtener el sm 
figure();
nyquist(L);
% Distancia al -1: 2.681
% sm = 1/2.681
sm = mag2db(1/2.681);
% Se observa satisfactoriamente que sm = -8.57 dB (menor a 6 dB)

%% Paso el controlador a discreto
C_digital = c2d(C, Ts, 'tustin');
