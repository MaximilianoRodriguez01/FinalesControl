% 1) a) Un cero real simple en el semiplano derecho abierto impone limitaciones significativas en el diseño de sistemas de control
% debido a que contribuye con componentes que pueden inducir inestabilidades. 
% En el contexto de sistemas de control, un cero en el semiplano derecho significa que existe una frecuencia 
% donde la ganancia del sistema se incrementa en lugar de atenuarse. 
% Esto puede resultar en respuestas transitorias no deseadas, oscilaciones o incluso inestabilidades si no se maneja adecuadamente. Por lo tanto, al diseñar sistemas de control, es crucial considerar cómo gestionar o evitar tales ceros para garantizar la estabilidad y el rendimiento deseado del sistema.
% 
% b) Un polo real simple en el semiplano derecho abierto también impone limitaciones serias en el diseño de sistemas de control. 
% Los polos en el semiplano derecho están asociados con términos exponenciales crecientes en el tiempo, 
% lo cual es indeseable en la mayoría de los sistemas de control, ya que puede conducir a respuestas que divergen o 
% se vuelven inestables. Por lo tanto, es esencial evitar que los polos estén en esta región al diseñar controladores 
% para asegurar que el sistema sea estable y tenga una respuesta controlable y predecible.
% 
% c) El retraso de fase admisible se refiere al máximo retraso en la fase de la respuesta en frecuencia de un sistema que 
% se puede tolerar sin que el sistema se vuelva inestable. Este parámetro es crítico en el diseño de controladores, 
% especialmente en sistemas que requieren respuestas rápidas y precisas. Un retraso de fase excesivo puede llevar a 
% oscilaciones no deseadas o a una disminución del margen de estabilidad del sistema.
% 
% Problema 2:
% 
% En cuanto a la implementación de un controlador en tiempo discreto, se realiza un modelo en tiempo continuo 
% y luego se discretiza para adaptarlo al dominio digital. Este proceso implica varias etapas:
% 
% Modelado en Tiempo Continuo: Primero se modela el sistema en forma de ecuaciones diferenciales 
% o en el dominio de la transferencia de funciones utilizando la teoría de control en tiempo continuo.
% 
% Discretización: Para implementar el control en un sistema digital (computadora o microcontrolador), 
% es necesario discretizar el modelo en tiempo continuo. Esto se logra mediante métodos como el muestreo 
% (con frecuencia de muestreo adecuada) o transformaciones de dominio como la transformada Z.
% 
% Controlador Discreto: Una vez discretizado, el controlador diseñado en tiempo continuo se convierte en un 
% controlador discreto que opera en instantes de tiempo discretos determinados por la frecuencia de muestreo.
% Es crucial asegurar que el controlador discreto mantenga la estabilidad y el rendimiento del sistema original en tiempo continuo.
% 
% Este proceso garantiza que el diseño teórico del controlador, que funciona bien en el dominio continuo, 
% se adapte correctamente al mundo digital, asegurando una implementación efectiva y control estable del sistema físico o 
% virtual que se esté controlando.


%%
close all
clear all

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

s = tf("s");

%% Definir variables como simbolicas

syms x1 x2 u y;
x = [x1;x2];

% Punto de equlibrio (x'=0)
% Equilibrio

x_e = [1; 0];
ue = 4;
ye = 1;


f1 = x(2);
f2 = 10 - u/(0.4*x(1));

f = [f1;f2];

%defino la salida
y = x(1);

A = jacobian(f,x);
%la funcion subs cambia las ocurrencias de {x(1),x(2),x(3),x(4),u} por {x_e(1),x_e(2),x_e(3),x_e(4),u_e}
A = double(subs(A,{x(1),x(2),u},{x_e(1),x_e(2),ue}));

B = jacobian(f,u);
B = double(subs(B,{x(1),x(2),u},{x_e(1),x_e(2),ue}));

C = jacobian(y,x);
C = double(subs(C,{x(1),x(2),u},{x_e(1),x_e(2),ue}));

D = jacobian(y,u);
D = double(subs(D,{x(1),x(2),u},{x_e(1),x_e(2),ue}));

%% Transferencia

P = minreal(zpk(ss(A, B, C, D)));

pzmap(P);

Avals = eig(A);

pap = zpk(-3.162, 3.162, 1);

pmp = zpk([],[-3.162 -3.162], -2.5);

c = zpk([-3.162 -3.162], [-1000 0], -1);

% SI ME PIDEN TS LO MAS GRANDE POSIBLE ES PAP 15 Y PADE 15


figure();
bode(pap, optionss);
title("pap");

wgc = 14.3;

figure();
bode(minreal(pmp*c), optionss);
title("pmpc sin compensar");

k = db2mag(75.3);

c = k*c;

% figure();
% bode(P*c,optionss);
% title("P*C sin comp");

fase_pap = deg2rad(-5);
Ts = tan(-fase_pap/2)*4/wgc;

figure();
bode(minreal(pmp*c), optionss);
title("Bode compensado de pc");


figure();
bode(minreal(pmp*c*pap), optionss);
title("Bode compensado de L SIN PADE");


pade = (1-Ts/4*s)/(1+Ts/4*s);


L = minreal(pmp*c*pap*pade);

figure();
bode(L, optionss);
title("Bode compensado de pc CON PADE");

% GRUPO DE LAS 4.
S=1/(1+L);
T=1-S;
PS=minreal(P*S);
CS=minreal(C*S);

figure();
time=1;
h1=subplot(3,1,1);
step(S,T,time);title('S & T');grid on
h2=subplot(3,1,2);
step(PS,time);title('PS');grid on
h3=subplot(3,1,3);
step(CS,time);title('CS');grid on
set(findall(gcf,'type','line'),'linewidth',2);
linkaxes([h1 h2 h3], 'x');

figure()
step(T);
title("Respuesta al escalon");


figure()
step(feedback(4*L,1))
title("Respuesta al escalon SOBREPICO CORREGIDO");


figure();
bode(4*L, optionss);
title("Bode compensado de L CON PADE");

Ts = 0.012;

C_dig = c2d(c, Ts, 'tustin');








