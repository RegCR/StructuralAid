%% Diseño de vigas simplemente reforzadas | Flexión
clc; clear;

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
FRc = 0.75;     %Factor de seguridad a cortante
Mu = input("Momento último en ton-m: ");
Mu = Mu*100000;

%% Predimensionamiento | Define h -> d
%   Geometría
b = input("Base: ");     %cm | Base de viga
r = input("Recubrimiento: ");      %cm | Recubrimiento
L = input("Largo viga(cm): ");    %cm | Largo de viga
% h_prop = L/12;  %Altura | cm
% h = 5*ceil(h_prop/5);
% d = h-r; %cm
d = input("d: ");
h = d+r;
% formatSpec = 'La altura calculada es %4.2f cm y el peralte efectivo es %4.2f cm\n\n';
% fprintf(formatSpec,h,d)

%% Calcular área de acero
q = 1 - sqrt(1-((2*Mu)/(FRf*fcc*b*(d^2)))); %Cuantia de refuerzo
p = q*(fcc/fy);     % Porcentaje de refuerzo
As = p*b*d         % Área de acero calculado

%% Propuesta
[m,n] = size(Var);
Var_pr = zeros(m,n);

cost_con = 1800;    % $ por m3
cost_ace = 32.9;    % $ por kg
peso_ace = 7800;    %Peso volumétrico de acero en kg/m3

for i = 1:7
    %Propuesta de varillas
    cant_var = ceil(As/Var(i,2));
    As_prop = cant_var*Var(i,2);
    desp = round((As_prop-As),2);
    Var_pr(i,1) = cant_var;
    Var_pr(i,2) = Var(i,1);
    Var_pr(i,3) = desp;
    
    %Costos
    %   Concreto
    Vol_con = (((b/100)*(h/100)-(As_prop/10000)*(L/100)));
    Vol_con = Vol_con*1.05;
    cf_con = cost_con*Vol_con;
    
    %   Acero
    Vol_ace = (As_prop/10000)*(L+2);
    pesof_ace = Vol_ace*peso_ace;
    cf_ace = pesof_ace * cost_ace;
    
    cost_f = cf_ace + cf_con;
    Var_pr(i,4) = cost_f;
    
end
    
El_Var = table(Var_pr(:,1),Var_pr(:,2),Var_pr(:,3));
El_Var.Properties.VariableNames = {'# Var','No. Var','Desperdicio (cm2)'}
