%% Diseño de columnas | Flexocompresión
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

%   Caso
FRf = 0.90;     %Factor de seguridad a flexión
FRc = 0.75;     %Factor de seguridad a cortante y columnas

%% Predimensionamiento

%   Geometría | Define h -> d
b = 60; %cm |Base
r = 4;  %cm |Recubrimiento inferior
rp = 4; %cm |Recubrimiento superior
h = 60; %cm |Altura
d = h-r; %cm|Peralte efectivo

%   Concreto
Ag = b*h;

%   Acero
lech = input("¿Cuántos lechos hay? ");
As = zeros(lech,1);

for k = 1:lech
    promptString = sprintf('¿Cuántos tipos de varillas tienes en la sección (%d) ?: ', k);
    tip_var = input(promptString);
    As_temp = zeros(tip_var);
    
    for i = 1:tip_var
        cant_var = input("Cantidad de varillas\n");
        no_var = input("No. de varilla: ");

        for j = 1:7
            if no_var == Var(j,1)
                a_var = Var(j,2);
                d_var = Var(j,3);
            end
        end
        As_temp(i) = cant_var * a_var;
    end
    As_temp = sum(As_temp);  %cm2 | Área de acero de refuerzo
    As(k) = As_temp(1,1);
end

As_t = sum(As);  %cm2 | Área de acero de refuerzo
As_t = As_t(1,1);

%% Cálculos | 3 lechos
%    Resistencia a compresión
Poc = FRc * ((fcc*(Ag-As_t)) + (As_t*fy));
Poc_ton = Poc/1000

%   Resistencia a tensión
Pot = FRc * (As_t*fy);
Pot_ton = Pot/1000

%  --------------- Punto D (Falla balanceada) -------------
c_cent = d/((Ep_y/Ep_cu)+1);
a_cent = B1*c_cent;
delta_lech = (h/2)-r;

Cc_cent = fcc*a_cent*b;      %Cc central
Cc_cent_ton = Cc_cent/1000;

Eps_cent = zeros(lech);
fs_cent = zeros(lech);
F_cent = zeros(lech);
F_cent_ton = zeros(lech);

Eps_cent(1) = Ep_cu*(1-(rp/c_cent));
Eps_cent(2) = ((c_cent-rp-delta_lech)/c_cent) * Ep_cu;
Eps_cent(3) = Ep_y;

for i = 1:lech
    if Eps_cent(i) >= Ep_y
        fs_cent(i) = fy;
    else
        fs_cent(i) = Es * Eps_cent(i);
    end
    
    % Fuerzas
    F_cent(i) = As(i)*fs_cent(i);
    F_cent_ton(i) = F_cent(i)/1000;
end

Cs1_cton = F_cent_ton(1)
Cs2_cton = F_cent_ton(2)
Ts3_cton = -F_cent_ton(3)

P_cent = Cc_cent_ton + Cs1_cton + Cs2_cton + Ts3_cton;
Mc_cent = (Cc_cent_ton*(((h/2)-(a_cent/2))/100))+((Cs1_cton + abs(Ts3_cton))*(delta_lech/100));

P_centFR = P_cent*FRc
Mc_centFR = Mc_cent*FRc

