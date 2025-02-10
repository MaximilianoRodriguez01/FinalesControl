%% Ejercicio 4: Linealizacion 
% x1_punto = -sqrt(x1-x2) + u_hat
% x2_punto = sqrt(x1-x2) - sqrt(x2-x3)
% x3_punto = sqrt(x2-x3) - sqrt(x3)
% y = sqrt(x3)

% U_HAT = 40/(s+20) * U(s)

% Hallar el punto de linealizacion tal que en el equilibrio, x3=1
% a) Controlar con un PI discretizado 
% b) MF 60 grados
% c) Simulación no lineal de un escalón que lleve el nivel del tanque 3, 
% desde el equilibrio a un valor 20% mayor
% d) Fundamentar bien el diseño en base a respuestas en frecuencia.
% e) Proponer un criterio para elegir 𝑇𝑠 de muestreo tal que la acción de 
% control se mantenga entre los valores 𝑢𝑚𝑎𝑥 = 8, 𝑢𝑚𝑖𝑛 = 0 .
% f) Simulación no lineal con controlador de tiempo discreto.
% g) Evaluar margen de estabilidad “𝑠𝑚”.

%Los valores de x2e x3e ye y alfa se despejaron al considerar que las
%ecuaciones de estados con x_punto=0 cuando se evalua x_punto = h(xe,ue)=0
%en los valores de estados en el equilibrio. Las matrices de la
%linealizacion del sistema en un entorno de xe son las siguientes en
%espacio de estados.

%
%Se propone controlar la planta, con un controlador PI, donde la parte
%integral 1/s mete una retraso de fase de -90 grados en la wgc donde la P
%tiene fase -30 grados, haciendo que L = P*C en la frecuencia de 
%wgc=0.0435 rad/s se tena un margen de fase de 60 grados. El Ts a elegir del
%muestreo debe ser un cero de fase no minima (4/Ts) que si esta alejado lo
%suficiente de wgc, sea despreciable el retraso de fase asociado a 4/Ts. El
%wgc elegido hace que el control sea lento entonces wgc, se supone que no
%supera los limites propuestos de diseno.

%A continuacion se grafica el Bode L_int = P*1/s, donde se controla a la
%planta mencionada con control integral C = 1/s. En este grafico se busca
%el punto w tal que una fase de -120 grados para asegurar un margen de fase
%de 60 grados con respecto a -180 grados. En este caso se ve que 
%w=0.0435 rad/s.

%En el siguiente grafico de Bode de L=P*1/s*kp, 
%kp=-32.5dB (magnitud en dB en w). 
%En el grafico del Bode de magnitud cambiada tal que en w=0.0435 rad/s se
%tenga 0dB y se conserva la fase que teniamos de -120 grados ya que solo le
%cambiamos la ganancia. De esta forma se puede ver que se tiene un margen
%de fase de 60 grados como se ve en la figura.

%Si agrego al controlador un retraso de media muestra (se explica en el
% ejercicio 4d) con un tiempo de muestreo Ts lo suficiente tal que 
% e^(-Ts*s/2) agregue un retraso de fase despreciable como se de en la
% figura de abajo.

%Se puede ver que el diseno del controlador no se vera afectado si 
% C = kp/s * Cdelay, (Cdelay se explica en el ejercicio 4d), el bode de
% L=C*P se conserva no apartandose tanto del diseno que teniamos antes,
% pues wgc=0.0435 en este caso en donde el margen de fase es de 60.2
% grados.

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

%Proponer criterio para elegir Ts de muestreo tal que la accion de control
%se mantenga entre los valores umax=8 umin=0

%Un criterio para eleir Ts de muestreo para la accion de control es que la
%aproximacion de Pade de media muestra de 
% e^(- s*Ts/2) =aprox (1 - Ts*s/4)/(1 + Ts*s/4) no agregue mucho retraso de
% fase considerable a la wgc(frecuencia de corte) para que el margen de
% fase sea proximado a 60 grados. En el diseno se tuvo como wgc = 0.0435.

%Dado que (1 - Ts*s/4)/(1 + Ts*s/4) = - (s-4*s/Ts)/(s+4S/Ts)
%es un pasatodo con un cero z=4/Ts de fase no minima, que va a agregar un
%retraso de fase en la wgc elegida, se puede obtener cual es el valor de
%z=4/Ts que va a agregar un retraso de fase angulo(ap)=0.01 grados, que se
%obtiene con la siguiente ecuacion (sacado del libro del Amstron y Murray):

%wgc = z tan(angulo(ap)/2)
% wgc/(tan(angulo()ap)/2) = z = 4/Ts
% Ts = 4 tan(angulo(ap)/2)/wgc
% Ts = 4 tan(0.01/2)/0.0435 rad/s = 6.87 ms --> OJO pasar 0.01grados a rad

%Se redondea Ts con Ts = 7 ms
%z = 4/Ts = 582.1

%En Matlab se prueba que se tiene que la aproximacion de pade de media
%muestra es:

%C_delay = - (s-582.1)/(s+582.1)

%Y el retraso de fase que se aplica en wgc=0.0508 en el siguiente grafico
%del retraso de media muestra C_delay.

%Lo cual verifica que el Ts elegido aplica un pequeno (despreciable)
%retraso de fase a wgc=0.0435 rad/s que no afecta al diseno que teniamos
%del controlador C.


%% Diseno del Controlador

% Grafico del bode de la planta P. En este busco la w tal que tenga una
% fase de -30 grados, lo que me va servir cuando se sume la accion integral
% C_int=1/s que aporta -90 grados, hace que la fase de L = P*C_int evaluada en la
% w buscada, se tenga una fase de -120 grados del cual se obtiene un margen de
% fase -120 - (-180) = 60 grados.

figure()
bode(P, optionss); 
% w = 0.0435 --> aprox -30 grados 

% Defino control integral
Cint = zpk([],0,1);

L_int = Cint * P;

% Grafico bode L_int que es la planta controlada por accion integral pura
% C_int=1/s. En este grafico se puede ver a que w=0.0435 rad/s se tiene una
% fase de -120 grados, ademas la ganancia en ese punto es de 32.5 dB, lo
% cual se va a atenuar en el siguiente paso con agregar al controlador 
% una ganancia kp = -32.5 dB
% tal que 0.0435 rad/s sea la frecuencia de cruce wgc.

figure();
bode(L_int,optionss);

% Defino controlador con ganancia kp
kp = db2mag(-32.5); % Cancela la ganancia con tal de que w=0.0435 rad/s
% tenga ganancia 0db
C = Cint * kp;

L = C * P;
% Grafico de L, donde se puede ver que w=0.0435 es la frecuencia de cruce
% wgc que tiene una fase de -120, asegurando una margen de fase de 60
% grados con respecto a -180 grados.

figure()
bode(L,optionss);

% Defino retardo de medio de muestreo generado por el controlador

% Este valor de Ts fue elegido por una formula del libro del Amstron y
% Murray, tal que el cero de fase no minima asociado al retardo de muestreo
% no me sume 0.01 grados como retraso de fase.
Ts=0.007;

% Se aproxima retardo e^-(Ts/2*s) con aproximacion de pade
Cdelay = zpk(4/Ts,-4/Ts,-1);
figure();bode(Cdelay,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

% Defino controlador con ganancia kp
kp = db2mag(-32.5-0.122); % Cancela la ganancia con tal de que 0.0435 rad/s
% tenga ganancia 0db + un factor de correccion
C = Cint * kp * Cdelay;


L = C * P;
% Grafico de L con retardo de media muestra, donde se puede ver que w=0.0508 es la frecuencia de cruce
% wgc que tiene una fase de -120, asegurando una margen de fase de 60
% grados con respecto a -180 grados.
figure();bode(L,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);


% Ejercicio 4e: Controlador digital

% Modelo de control digital: Convierto el control C = Cint * kp diseñad0
Cd = c2d(Cint * kp,Ts,'tustin');
% La parte de Cdelay se asocia al bloque zero order hold que se pone en
% simulink en la simulacion 4e

% Ejercicio 4f: calculo de sm
S = 1/(1+L);

figure()
bode(S,optionss);

sm = 1/db2mag(2.69);