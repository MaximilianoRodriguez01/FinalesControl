
clc; clear vars; close all;
%Configuracion
optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=10;
optionss.Grid='on'; 

%Definiciones
s = tf("s");
k = db2mag(17);

Pap = ((50-s)^2/(50+s)^2)*((s+1)^2/(s-1)^2);
Pmp = (s+50)^2/(s+1)^2;
C = k*(1/s)*((s+1)^2/(s+50)^2);
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

%Respuesta a Escalones
figure();
time = 10;
h1=subplot(3,1,1);
step(T,time);title('T');grid on
h2=subplot(3,1,2);
step(PS,time);title('PS');grid on
h3=subplot(3,1,3);
step(CS,time);title('CS');grid on
set(findall(gcf,'type','line'),'linewidth',2);
linkaxes([h1 h2 h3], 'x');

%Nyquist total
figure; 
nyqlog(C*P);