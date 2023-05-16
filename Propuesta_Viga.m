%% Comprobación de propuesta de diseño | Flexión
%       Viga simplemente reforzada
clc; clear;

%   Valores área varillas base (No., A(cm2), diam (cm)
Var = [3 0.71 0.95
    4 1.27 1.27
    5 1.98 1.59
    6 2.85 1.91
    8 5.07 2.54
    10 7.92 3.18
    12 11.40 3.81];

%% Datos iniciales
% Propiedades de materiales
    % Acero
fy = 4200;          %kg/cm2 | Esfuerzo de fluencia de acero
Es = 2000000;       %kg/cm2 | Módulo de elasticidad acero
Ep_y = fy/Es;       %Deformación unitaria de fluencia

    %Concreto
fc = 250;           %kg/cm2 | Resistencia a compresión de concreto
fcc = 0.85*fc;      %kg/cm2
Ep_cu = 0.003;      %Deformación unitaria max útil del concreto (Norma)

%B1 (Valor por normativa)
if fc <= 280
    B1 = 0.85;
else
    B1 = 1.05-(fc/1400);
    if B1 >= 0.65
        B1;
    else
        B1 = 0.65;
    end
end

% ---------------  Geometría | Define d -> h -----------
b = input("Base: ");     %cm | Base de viga
r = input("Recubrimiento: ");      %cm | Recubrimiento
d = input("Peralte efectivo: ");
h = d+r; %cm
L = input("Largo viga(m): ")*100;  %cm

%   Caso
FRf = 0.90;     %Factor de seguridad a flexión
FRc = 0.75;     %Factor de seguridad a cortante

% --------------- Área de acero de refuerzo longitudinal -------------
tip_var = input("¿Cuántos tipos de varillas tienes? ");
As = zeros(tip_var);
a_var = 0;
d_var = 0;

for i = 1:tip_var
    cant_var = input("Cantidad de varillas: \n");
    no_var = input("No. de varilla: ");
        
    for j = 1:7
        if no_var == Var(j,1)
            a_var = Var(j,2);
            d_var = Var(j,3);
        end
    end
    As(i) = cant_var * a_var;
end
As = sum(As);  %cm2 | Área de acero de refuerzo
As = As(1,1)


%% Cálculo por normativa 
a = (As*fy) / (fc*b);
c = a/B1;
Ep_s = Ep_cu*((d/c)-1);

% ------------ Comprobación fluencia ----------------
if Ep_s > Ep_y
    p = As/(b*d);   %Porcentaje de refuerzo
    q = p*(fy/fcc); %Cuantia de refuerzo
    MR = FRf * fcc * q * b *(d^2) * (1-0.5*q);
    MR_ton = MR/100000
else
    disp("El acero no fluye")
end

Mu = input("Momento último en ton-m: ");
if MR_ton>= Mu
    formatSpec = 'El MR resistente al Mu en flexión de la viga simplemente reforzada es %4.2f ton-m\n\n';
    fprintf(formatSpec,MR_ton)
else
    disp("El MR de la viga no resiste el Mu")
end

%% Comparar área de acero real vs requerido
q = 1 - sqrt(1-((2*Mu*100000)/(FRf*fcc*b*(d^2)))); %Cuantia de refuerzo
p = q*(fcc/fy);     % Porcentaje de refuerzo
As_cal = p*b*d;         % Área de acero calculado

Desp = As - As_cal       %Desperdicio

pc = As /(b*d);

%% Cortante
Vu = input("Cortante último en ton: ");
Vu = Vu*1000;

%   Resistencia al corte de concreto (Vcr)
if (L/h)>5
    if pc < 0.015
        Vcr = FRc*(0.2+(20*pc))*sqrt(fc)*b*d;
    else
        Vcr = 0.5*FRc*sqrt(fc)*b*d;
    end
elseif (L/h) <4
    Vcr = FRc * (3.5-(2.5*(Mu/(Vu*d))))*0.5*(sqrt(fc))*b*d;
end

% Restricciones
Vmax_Vcr = 1.5*sqrt(fc)*b*d;
if Vcr <= Vmax_Vcr
    disp('El valor de Vcr es permisible')
else
    disp('El valor de Vcr no es permisible')
end

% Requerimientos minimos
% Se utilizan estribos del No.3
Est = [3 0.71 0.95];

%   Separación máxima
if Vcr < Vu && Vu <= (FRc*Vmax_Vcr)
    Smax_o = d/2;
    Smax = 5*floor(Smax_o/5);
    formatSpec = 'La separación máxima es %4.2f cm';
    fprintf(formatSpec,Smax)
    
elseif Vu > (FRc*Vmax_Vcr)
    Smax_o = d/4;
    Smax = 5*floor(Smax_o/5);
    formatSpec = 'La separación máxima es %4.2f cm\n';
    fprintf(formatSpec,Smax)
    
elseif Vu > 2.5*sqrt(fc)*b*d*FRc
    disp('No se permite el diseño')  
end

%   Separaciones necesarias en secciones críticas
Av = 2*Est(1,2);
Snec = (FRc*fy*Av*d)/(Vu-(Vcr));
Smin = 6;

if Snec > Smax_o
    Sfin = Smax;
    formatSpec = '\nLas separaciones necesarias en secciones críticas es %4.2f cm\n';
    fprintf(formatSpec,Sfin)
elseif Snec > Smin && Snec < Smax_o
    Sfin = 5*floor(Snec/5);
    formatSpec = '\nLas separaciones necesarias en secciones críticas es %4.2f cm\n';
    fprintf(formatSpec,Sfin)
elseif Snec < Smin
    disp("Cambiar sección")
end

%% Análisis
Vsr = (FRc*fy*Av*d)/Smax;   %Contribución de refuerzo en el alma de acero
VR = Vsr + Vcr;     %Resistencia al cortante kg
VR = VR/1000       %ton
disp("ton")

if VR < Vu/1000
    tipo_cor = input("Indica tipo de cortante (1=superior o 2=inferior): ");
    if tipo_cor == 1
        a = input("Dame el valor de a(Punto medio, lado der a izq): ");
        x2 = (VR*a)/(Vu/1000);
        if x2>a
            x = x2-a;
        else
            x = a-x2;
        end
        cant_est = (ceil((x*100)/Sfin))+1;
        formatSpec = '\nSe requieren %4.2f Est No.3 @ %4.2f cm\n';
        fprintf(formatSpec,cant_est,Sfin)

    elseif tipo_cor ==2
        a = input("Dame el valor de a(Punto medio, lado izq a der): ");
        x2 = (VR*a)/(Vu/1000);
        if x2>a
            x = x2-a;
        else
            x = a-x2;
        end
        cant_est = (ceil((x*100)/Sfin))+1;
        formatSpec = '\nSe requieren %4.2f Est No.3 @ %4.2f cm\n';
        fprintf(formatSpec,cant_est,Sfin)
    end
else
    disp("La separación de los estribos es igual a la Smax, la resistencia es mayor")
end

%% Límites de acero
Asmin = ((0.7*sqrt(fc))/fy)*(b*d);
Asbal = (fcc/fy)*((6000*B1)*(6000+fy))*b*d;
Asmax = 0.75*Asbal;     %Acero máximo con Ductilidad media

%    Comprobación de limites
if As >= Asmin && As <= Asmax
    disp('La sección de acero se encuentra en límites permisibles')
elseif As > Asmax
    disp('La sección de acero es mayor al límite')
elseif As < Asmin
    disp('La sección de acero es menor al límite')
else
    disp('La sección de acero no es aceptada')
end
