%% Ejercicio 4: linealizacion
clear all;close all;clc
orden=3;
x=sym('x',[orden 1],'real');
u=sym('u','real');

% Valores buscados en papel
alfa=1;
beta=2;% Es datos

% Las ecuaciones de estados
h1 = -alfa * sqrt(x(1)-x(2)) + u;
h2 = alfa * sqrt(x(1)-x(2)) - beta * sqrt(x(2)-x(3));
h3 = beta * sqrt(x(2)-x(3)) - sqrt(x(3));

f = sqrt(x(3));

h = [h1;h2;h3];

% Jacobianos de la linealizacion
A=jacobian(h,x);
B=jacobian(h,u);
C=jacobian(f,x);
D=jacobian(f,u);

% Puntos de equlibrio
x0=[9 5 4]; % El primer elemento es dato
u0=2; % Es dato
y0=2;

% Reemplazo los valores simbolicos del jacobiano por los valores en el
% equilibrio
A = subs(A,{x(1),x(2),x(3),u},{x0(1),x0(2),x0(3),u0});
B = subs(B,{x(1),x(2),x(3),u},{x0(1),x0(2),x0(3),u0});
C = subs(C,{x(1),x(2),x(3),u},{x0(1),x0(2),x0(3),u0});
D = subs(D,{x(1),x(2),x(3),u},{x0(1),x0(2),x0(3),u0});

A = double(A);
B = double(B);
C = double(C);
D = double(D);

A
B
C
D
G = zpk(ss(A,B,C,D))

%% Ejercicio 2:

close all;
P = G;
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

% Grafico del bode de la planta P. En este busco la w tal que tenga una
% fase de -30 grados, lo que me va servir cuando se sume la accion integral
% C_int=1/s que aporta -90, hace que la fase de L = P*C_int evaluada en la
% w buscada, se tenga una fase de -120 del cual se obtiene un margen de
% fase -120 - (-180) = 60 grados.
figure();bode(P,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Defino control integral
Cint = zpk([],0,1);

L_int = Cint * P;

% Grafico bode L_int que es la planta controlada por accion integral pura
% C_int=1/s. En este grafico de puede ver a que w=0.0309 rad/s se tiene una
% fase de -120 grados, ademas la ganancia en ese punto es de 29.3db, lo
% cual se va a atenuar en el siguiente paso con agregar al controlador 
% una ganancia kp = -29.3db
% tal que 0.0309 rad/s sea la frecuencia de cruce wgc.
figure();bode(L_int,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Defino controlador con ganancia kp
kp = db2mag(-29.3); % Cancela la ganancia con tal de que w=0.0309 rad/s
% tenga ganancia 0db
C = Cint * kp;

L = C * P;
% Grafico de L, donde se puede ver que w=0.0309 es la frecuencia de cruce
% wgc que tiene una fase de -120, asegurando una margen de fase de 60
% grados con respecto a -180 grados.
figure();bode(L,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Defino retardo de medio de muestreo generado por el controlador

% Este valor de Ts fue elegido por una formula del libro del Amstron y
% Murray, tal que el cero de fase no minima asociado al retardo de muestreo
% no me no sume 0.01 grados como retraso de fase.
TS = round(4/354,3)

% Se aproxima retardo e^-(Ts/2*s) con aproximacion de pade
Cdelay = zpk(4/TS,-4/TS,-1)
figure();bode(Cdelay,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);


% Defino controlador con ganancia kp
kp = db2mag(-29.3-0.122); % Cancela la ganancia con tal de que w=0.0306 rad/s
% tenga ganancia 0db + un factor de correccion
C = Cint * kp * Cdelay;


L = C * P;
% Grafico de L con retardo de media muestra, donde se puede ver que w=0.0306 es la frecuencia de cruce
% wgc que tiene una fase de -120, asegurando una margen de fase de 60
% grados con respecto a -180 grados.
figure();bode(L,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);


% Ejercicio 4e: Controlador digital

% Modelo de control digital: Convierto el control C = Cint * kp diseñad0
Cd = c2d(Cint * kp,TS,'tustin');
% La parte de Cdelay se asocia al bloque zero order hold que se pone en
% simulink en la simulacion 4e

% Ejercicio 4f: calculo de sm
S = 1/(1+L);

figure();bode(S,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

sm = 1/db2mag(2.87)

