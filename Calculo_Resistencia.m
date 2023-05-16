%% Diseño de vigas doblemente reforzadas | Flexión
clc; clear all;

%   Valores área varillas base [No., A(cm2), diam (cm)]
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

%   Geometría | Define d -> h
b = 30; %cm
r = 3;  %cm
rp = 3; %cm
d = 70; %cm
h = d+r; %cm

%   Caso
FRf = 0.90;     %Factor de seguridad a flexión
FRc = 0.75;     %Factor de seguridad a cortante

    %Área de acero de refuerzo Sección inferior
tip_var = input("¿Cuántos tipos de varillas tienes en la sección inferior? ");
As = zeros(tip_var);

for i = 1:tip_var
    cant_var = input("Cantidad de varillas (Sección inf): \n");
    no_var = input("No. de varilla (Sección inf.): ");
    
    for j = 1:7
        if no_var == Var(j,1)
            a_var = Var(j,2);
            d_var = Var(j,3);
        end
    end
    As(i) = cant_var * a_var;
end
As = sum(As);  %cm2 | Área de acero de refuerzo
As= As(1,1);


    %Área de acero de refuerzo Sección superior (prima)
tip_varp = input("¿Cuántos tipos de varillas tienes en la sección superior (prima)? ");
Asp = zeros(tip_varp);

for i = 1:tip_varp
    cant_var = input("Cantidad de varillas (Sección sup.): \n");
    no_var = input("No. de varilla (Sección sup.): ");
        
    for j = 1:7
        if no_var == Var(j,1)
            a_var = Var(j,2);
            d_var = Var(j,3);
        end
    end
    Asp(i) = cant_var * a_var;
end
Asp = sum(Asp);  %cm2 | Área de acero de refuerzo
Asp= Asp(1,1);


%% Cálculo por normativa 
a = ((As-Asp)*fy)/(fcc*b);
c = a/B1;
Ep_s = Ep_cu*((d/c)-1);
Ep_ps = Ep_cu*(1-(rp/c));

%   Comprobación fluencia Sección inferior
if Ep_s > Ep_y
    disp("El acero en la sección inferior si fluye")
    p = As/(b*d);   %Porcentaje de refuerzo
    q = p*(fy/fcc); %Cuantia de refuerzo
    MR = FRf * fcc * q * b *(d^2) * (1-0.5*q);
    MR_ton = MR/100000;
else
    disp("El acero en la sección inferior no fluye")
end


%   Comprobación fluencia Sección superior (prima)
if Ep_ps > Ep_y
    disp("El acero en la sección superior (prima) si fluye")
    MR = FRf*((Asp*fy*(d-rp)) + ((As-Asp)*fy*(d-(a/2))));
    MR_ton = MR/100000;
    formatSpec = 'El MR en flexión de la viga doblemente reforzada es %4.2f ton-m\n';
    fprintf(formatSpec,MR_ton)
    
else
    %Términos de ecuación general
    eq_a = fcc*b;
    eq_b = (Asp * Es * Ep_cu) - (As*fy);
    eq_c = Asp * Es * Ep_cu * B1 * rp;
    eq = [(eq_a), eq_b, (-1*eq_c)];
    
    %Solución de a
    [a] = roots(eq);
    a1 = a(1,1);
    a2 = a(2,1);
    if a1>0
        a = a1;
        c = a/B1;
        %Fuerzas resultantes
        Cs = Asp * (Es*(Ep_cu*(1-(rp/c))));
        Cc = fcc * a * b;
        
        %Momento de resistencia
        MR = FRf*((Cs*(d-rp)) + (Cc*(d-(a/2))));
        MR_ton = MR/100000;
        disp("El acero en la sección superior (prima) no fluye")
        formatSpec = 'El MR en flexión de la viga doblemente reforzada es %4.2f ton-m\n';
        fprintf(formatSpec,MR_ton)
        
    elseif a2>0
        a = a2;
        c = a/B1;
        %Fuerzas resultantes
        Cs = Asp * (Es*(Ep_cu*(1-(rp/c))));
        Cc = fcc * a * b;
        
        %Momento de resistencia
        MR = FRf*((Cs*(d-rp)) + (Cc*(d-(a/2))));
        MR_ton = MR/100000;
        disp("El acero en la sección superior (prima) no fluye")
        formatSpec = 'El MR en flexión de la viga doblemente reforzada es %4.2f ton-m\n';
        fprintf(formatSpec,MR_ton)
    else
        disp("Ninguna solución para la variable a es válida")
    end
end

%   Comprobación con Mu
Mu = input("Momento último en ton-m: ");

if MR_ton>= Mu
    formatSpec = 'El MR en flexión de la viga doblemente reforzada resiste el Mu';
    fprintf(formatSpec)
else
    disp("El MR de la viga no resiste el Mu")
end
