clear all
close all

% Configuración de los bodes
my_bode_options = bodeoptions;
my_bode_options.MagVisible='on';
my_bode_options.PhaseMatching = 'on';
my_bode_options.PhaseMatchingFreq = 1;
my_bode_options.PhaseMatchingValue = -180;
my_bode_options.Grid = 'on';

%% Espacio de estados

% En base a lo escrito en la hoja, defino las ecuaciones del espacio de estados

syms x1 x2 x3 x4 u y;
x = [x1 x2 x3 x4];
y = sqrt(x3);


f1 = (-sqrt(x1 - x2) + x4);
f2 = sqrt(x1-x2)-sqrt(x2-x3);
f3 = sqrt(x2-x3)-sqrt(x3);
f4 = 40*u - 20*x4;

f = [f1 f2 f3 f4];

%% valores del equilibrio

x1e = 3;
x2e = 2;
x3e = 1;
x4e = 1;

xe = [x1e; x2e; x3e; x4e];

ue = 1/2;
ye = 1;

%% reemplazo para linealizar


A = jacobian(f, x);
B = jacobian(f, u); 
C = jacobian(y, x);
D = jacobian(y, u);

A = subs(A, str2sym({'x1', 'x2', 'x3', 'x4' ,'u', 'y'}), {x1e, x2e, x3e, x4e ,ue, ye});
B = subs(B, str2sym({'x1', 'x2', 'x3', 'x4' ,'u', 'y'}), {x1e, x2e, x3e, x4e ,ue, ye});
C = subs(C, str2sym({'x1', 'x2', 'x3', 'x4' ,'u', 'y'}), {x1e, x2e, x3e, x4e ,ue, ye});
D = subs(D, str2sym({'x1', 'x2', 'x3', 'x4' ,'u', 'y'}), {x1e, x2e, x3e, x4e ,ue, ye});



Ass = double(A);
Bss = double(B);
Css = double(C);
Dss = double(D);

% Transferencia
P = zpk(ss(Ass, Bss, Css, Dss));

% figure();
% bode(P, my_bode_options);
% title("Bode De P");

autovalores = eig(Ass);

%% Compensacion

s = tf("s");

figure();
bode(P, my_bode_options);
title("bode de la planta");

wgc = 0.191;

fase_pap = deg2rad(-5);
Ts = tan(-fase_pap/2)*4/wgc;

pade = (1-Ts/4*s)/(1+Ts/4*s);

% c = zpk([-20 -1.623 -0.7775 -0.09903], [0 -1000 -1000 -1000 -1000], 1);
c = zpk(-0.0993,0,1);

figure();
bode(minreal(P*c), my_bode_options);
title("Bode De PC");

k = db2mag(1.46);

figure();
bode(minreal(k*P*c), my_bode_options);
title("Bode compensado de pc");

L = minreal(k*P*c*pade);

figure();
bode(L, my_bode_options);
title("Bode compensado de pc CON PADE");

% wgc_inverso = Ts / (tan(deg2rad(30/2))*(4));
% 
% wgc = 1/wgc_inverso;

%% Grupo de las 4

S = 1 / (1 + L);
T = 1 - S;
PS = minreal(P*S);
CS = minreal(c*S);

%% Calculo el Margen de estabilidad, el cual lo consigo graficando la
% Sensiblidad y haciendo la inversa del pico maximo

figure();
bode(S, my_bode_options);
title("S");

% Sm = 1/db2mag(4.06);
% 
% smdb = mag2db(Sm);

%% C) Simulo un escalon de referencia tal que y = 1.1
% mi salida tiene que seguir una referencia.
% En la consigna me dicen que "y" termina valiendo 1.1
% y que la referencia es un escalon.
% Sabemos que Y(s) = T(s) * R(s), asi que:

ref = 1.2;
y_ref = T * ref;

figure();
% La funcion step ya me realiza el grafico de la respuesta al escalon
step(y_ref);
grid on;
title("respuesta al escalon de entrada con y = 1.2");

Ts = 10;

C_dig = c2d(c, Ts, 'tustin');


% %% D) respuesta a una perturbacion de 0.1
% 
% ref_perturbacion = 0.1;
% figure;
% step(ref_perturbacion * S);
% grid on;
% title('Respuesta del sistema ante un escalón de perturbación de magnitud 0.1');








 


%% Plantilla para otros ejercicios
% % Elimino el efecto del polo dominante
% 
% c = zpk(-0.01562, [0 -10e3], -1);
% 
% % Busco wgc con -115 grados de fase
% 
% figure();
% bode(minreal(P*c), my_bode_options);
% title("pxc sin ajustar");
% 
% wgc = 1.88;
% 
% % Encuentro que tiene una ganancia de -137dB en esa frecuencia
% 
% k = db2mag(137);
% 
% c = c*k;
% 
% figure();
% bode(minreal(P*c), my_bode_options);
% title("PXC AJUSTADO");
% 
% s = tf("s");
% 
% % Despe
% 
% Ts = tan(deg2rad(5/2))*(4/wgc);
% 
% Pade = (1-Ts/4*s)/(1+Ts/4*s);
% 
% figure();
% bode(minreal(P*c*Pade), my_bode_options);
% title("L con C digitalizado");
% 
% 
% C_discretizado= c2d(c, Ts, 'tustin');