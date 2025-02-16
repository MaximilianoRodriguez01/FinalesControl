clear all;close all;clc 

orden= 3;
x = sym('x',[orden 1],'real');
u = sym('u','real');

%Constantes
Fp = 0;
p = 0.02;

%Ecuaciones no lineales
F1 = ( x(3) - sqrt(x(1)-x(2)) )/power(x(1), 2);
F2 = ( sqrt(x(1)-x(2)) - sqrt(x(2)) + Fp )/power(x(2), 2);
F3 = p*u-p*x(3);

f= [F1 F2 F3]; 
A = jacobian(f,x);
B = jacobian(f,u);
C= [0 1 0]; 
D= 0; 
x0 = [2 1 1]; 
u0 = 1; 
y0 = 1; 
A=subs(A, {'x1','x2', 'x3'}, {x0(1), x0(2), x0(3)});
%B=subs(B, {'','',}, {'','',}); 

A = double(A);
B = double(B);
G=zpk(ss(A,B,C,D));

%veo si es estable
eig(A);

%% Compensacion de la planta

clc; clear vars; close all;
%Configuracion
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on'; 

%Definiciones
s = tf("s");
k = db2mag(39.4);
Ts = 0.5;

Pap = (1-s*Ts/4)/(1+s*Ts/4); %digitalizacion
Pmp = 0.0025/((s+0.059)*(s+0.02)*(s+1.066));
C = k*(1/s)*(s+0.02)*(s+0.059)/(s+1.066);
P = Pap*Pmp;

%Bode 
figure;
bode(C*Pmp, optionss); title("C*Pmp");
grid on;

figure;
bode(Pap, optionss); title("Pap");
grid on;

figure;
bode(C*Pmp*Pap, optionss); title("C*Pmp*Pap");
grid on;

%Gang of four
S = 1/(1+C*P);
T = C*P/(1+C*P);
PS = P/(1+C*P);
CS = C/(1+C*P);

figure;
bode(S, optionss); title("Sensibilidad");
grid on;

figure;
bode(T, optionss); title("Transeferencia T");
grid on;

%Respuesta al escalon
figure();
step(T, 70); title("Step T");
grid on;

%Nyquist total para ver estabilidad
figure; 
nyqlog(C*P);

% Armo el controlador digital para el simulink
Cdigital = c2d(C, Ts, "Tustin");