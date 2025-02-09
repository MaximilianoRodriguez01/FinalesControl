%% Ejercicio 3:

%Dada la transferencia P(s) = (1000 - s/s-p)^4
%Determinar el rango de valores de p tal que se puede obtener retraso de
%fase admisible para la parte pasatodo que sea de 30 grados o mejor.

%Pmp = [(1000 + s)/(s+p)]^4
%Pap = [1000-s/1000+s s+p/s-p]^4 = [-(1000+s)/1000+s s+p/s-p]^4

%De la expresión del pasatodo Pap se quiere elegir un p tal que el que el 
%retraso de fase admisible sea de (angulo)𝑎𝑝 = 30 𝑔𝑟𝑎𝑑𝑜𝑠, en otras palabras 
%que el retraso de fase que mete Pap sea de 30 grados o menor. Esto se
%puede encontrar de 2 maneras una por unas ecuaciones del amstrong y murray 
%y por otro lado mediante Matlab graficando el bode Pap iterando con varios 
%valores de 'p' hasta ver en algún bode un retraso de fase de 30 grados.

%Mediante Ecuaciones del Amstron y Murray:
%De antemano se puede saber que retraso de fase mete el cero de fase no 
%mínima p=1000 de orden 4 del Pap, si se lo analiza por separado
%Papz = (−(s−1000)/s+1000)^4, esta parte agrega un retraso de fase 
%admisible (angulo)apz = 30 grados a partir de las frecuencias w, que se 
%puede obtener una cota superior de frecuencias, mediante la siguiente 
%formula:

%w <= z tan(angulo(apz)/(2n))

%Donde z es el cero de fase no mínima(cero en el lado derecho), y n es el 
%orden del z de fase no mínima, en nuestro caso z=1000 y n=4. Si evaluamos 
%estos valores en la ecuación anterior, se tiene la cota:

%w <= 65.54 rad/s

%Por lo que significa que Papz tendrá un retraso de fase 30 grados o menor 
%a partir de un valor inferior a w=65.54 rad/s, por lo que que significa 
%que la fase del bode del Papz tendrá valores de 0 a -30 grados para
%valores inferiores a w=65.54 rad/s. Esto se puede ver en el siguiente 
%grafico del bode del Papz.

%En rojo se puede ver las frecuencias w acotadas superiormente por w_max 
%donde el retraso de fase va desde 0 hasta 30 grados.

%Ahora si se analiza por separado la parte del Pap que comprende el polo 
%inestable de orden 4
%Papp = (s+p/s-p)^4
%Se puede obtener una cota de frecuencias inferior donde Papp tiene como 
%retraso de fase admisible angulo(app) = 30 grados, con la siguiente 
%formula:

% w >= p / (tan(angulo(app)/2n)) 

%Donde p es el polo inestable y n el orden del polo inestable. Esta formula 
%establece una cota inferior de frecuencias w donde se asegura que el 
%retraso de fase Papp que mete sea entre 0 y 30 grados, por lo que el
%polo p tiene que estar cerca del z=1000, para asegurar que cuando 
%Pap=Papz*Papp en alguna región desde p hasta z haya un retraso de fase 
%30 grados. Se puede hallar el polo p tal que exista un w del bode
%Pap=Papz*Papp tal que tenga fase -30 grados. Esto se hace mediante las 
%formulas mencionadas del amstrong y murray.

%Con utilizar las siguientes formula mencionadas, exigimos de Papz y Papp 
%tengan un retraso de fase de 15 grados en la misma frecuencia w tal 
%que 𝜙̃𝑎𝑝𝑧 + 𝜙̃𝑎𝑝𝑝 = 15 𝑔𝑟𝑎𝑑𝑜𝑠 + 15 𝑔𝑟𝑎𝑑𝑜𝑠 = 30 𝑔𝑟𝑎𝑑𝑜𝑠 = 𝜙̃𝑎𝑝.

% w = z tan(angulo(apz))/2n
% w = p / (tan(angulo(app))/2n)

%Igualamos ambas ecuaciones:
% se tiene que p = 1.071
%Que es el polo inestable del Papp que asegura que en
%w = 1.071 / (tan(angulo(app))/2n) = 32.73 rad/s
%haya un retraso de fase de 15 grados al igual que pasa con Papz, como se 
%ve en el bode de Papz de abajo.

%También se muestra bode de Papp, que con el polo p calculado, se asegura 
%que w=32.6 rad/s haya un retraso de fase de 15 grados.

%Si se combinan ambos efecto en fase mediante Pap=Papz*Papp, se puede ver 
%que la fase máxima que alcanza en w=32.6 rad/s es con fase de -30 grados, 
%que se logra si 𝑝 ≥ 1.071, el cual p=1.071 es el minimo p que asegura un 
%retraso de fase admisible de 30 grados de Pap.


close all;
z = 1000;
Papz = zpk([z z z z],[-z -z -z -z],1);

optionss=bodeoptions;
optionss.MagVisible='on';
optionss.PhaseMatching='on';
optionss.PhaseMatchingValue=-180;
optionss.PhaseMatchingFreq=1;
optionss.Grid='on';

figure();bode(Papz,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

p = 1.071;
Papp = zpk([-p -p -p -p],[p p p p],1);

figure();bode(Papp,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

Pap = Papz * Papp;
figure();bode(Pap,optionss,{.0001,1000});
set(findall(gcf,'type','line'),'linewidth',2);

