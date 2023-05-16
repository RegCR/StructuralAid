clc; clear;

filename = "D:\Users\Regina\Documents\Semestre 8\Proyecto Integrador\aisc-shapes-database-v15.0.xlsx";
sheet = "Database v15.0";
[num,txt,raw] = xlsread(filename,sheet);
[x,y] = size(raw);

FS = 0.90;        %Factor de Seguridad para flexión (AISC)
E = 29000;         %[ksi] Módulo de Elasticidad
fy = 50;           %Esfuerzo de fluencia [ksi] (ASTM A572)

%% Datos iniciales
Pa = 54.68;        %[kips] Carga axial de estructuras | STAAD

    %PROPUESTA: Perfil: W 12x26
Propuesta = "W12X26";

for i = 2:x
    for j = 3:y
        if isequal(raw(i,3),cellstr(Propuesta))
            Ag = cell2mat(raw(i,6));    %[in2] Área de perfil seleccionado
            Cw = cell2mat(raw(i,51));
            Ix = cell2mat(raw(i,39));
            Iy = cell2mat(raw(i,43));
            Zx = cell2mat(raw(i,40));
            ry = cell2mat(raw(i,46));
            rx = cell2mat(raw(i,42));
            rts = cell2mat(raw(i,75));
            Sx = cell2mat(raw(i,41));
            h0 = cell2mat(raw(i,76));
            J = cell2mat(raw(i,50));
        end
    end
end
            

%[in] Radio de Giro mínimo (Caso Crítico)
if rx < ry
    r = rx;
else
    r = ry;
end

G = 1;      % Buscar e ingresar de forma manual
Kz = 1;     % Buscar ? | Factor de longitud efectiva para
            %   torsional buckling

Cb = 1;

k = 1;                     %Caso a (Relación esbeltez)-AISC
L = (145.669)*k;           %[in] Longitud efectiva

Lb = 1;


%% DISEÑO DE COLUMNAS 

% Fcr_i = (2/3)*fy;   %[ksi] Esfuerzo Crítico inicial
% Ag_i = (FS*Pa)/Fcr_i;   %[in2] Área mínima de perfil inicial


    %------Relación de esbeltez - Caso de soportes---------
RE = (k*L)/r;           %Relación Esbeltez

    %------------Comprobación de Perfil---------
if RE < 200
    disp('La esbeltez del perfil de columna si es aceptable')
    
    %--- [E3-AISC]---
    Pandeo = 4.71*(sqrt(E/fy));   %Determinación de tipo de pandeo
    Fe_E3 = ((pi^2)*E)/(RE^2);       %[ksi] Esfuerzo elástico
    
    if RE <= Pandeo
        Fcr_E3 = (0.658^(fy/Fe_E3))*fy;   %[ksi] Esfuerzo Crítico
        disp('El pandeo de la columna es inelástico')
    else 
        Fcr_E3 = 0.877*Fe_E3;     %[ksi] Esfuerzo Crítico
        disp('El pandeo de la columna es elástico')
    end
    Pn_E3 = (Fcr_E3*Ag);       %[kips] Carga soportada
    
    %--- [E4-AISC]---
    Fe_E4 = (((pi^2*E*Cw)/((Kz*L)^2))+(G*J))*(1/(Ix+Iy));
    
    if RE <= Pandeo
        Fcr_E4 = (0.658^(fy/Fe_E4))*fy;   %[ksi] Esfuerzo Crítico
        disp('El pandeo de la columna es inelástico')
    else 
        Fcr_E4 = 0.877*Fe_E4;     %[ksi] Esfuerzo Crítico
        disp('El pandeo de la columna es elástico')
    end    
    
    Pn_E4 = (Fcr_E4*Ag);       %[kips] Carga soportada
    
    
    if Pn_E3 > Pn_E4
        Pn = FS*Pn_E3;
    else
        Pn = FS*Pn_E4;
    end
    
    if Pn >= Pa
        disp('El perfil de la columna es aceptable')
    else
        disp('El perfil de la columna no es aceptable')
    end
    
else
    disp('La esbeltez del perfil de columna no es aceptable')
end


%% ANÁLISIS DE RELACIÓN DE ESBELTEZ
%--- Caso 10 ---
l_pf = 0.38*sqrt(E/fy);
l_rf = 1*sqrt(E/fy);

%---Caso 15 ---
l_pw = 3.76*sqrt(E/fy);
l_rw = 5.70*sqrt(E/fy);


% ----[F2-AISC]---
% Yielding
Mp_x = fy*Zx;
Mn_yi = Mp_x;

% Lateral Torsional Buckling
Lp = 1.76*ry*sqrt(E/fy);
Lr = 1.95*rts*(E/(0.7*fy))*sqrt((Jc/(Sx*h0))+sqrt(((Jc/(Sx*h0))^2)+6.76*(((0.7*fy)/E)^2)));

if Lp<Lb && Lb<Lr
    Mn_ltb = Cb*(Mp_x-(Mp_x-0.7*fy*Sx)*((Lb-Lp)/(Lr-Lp)));
    if Mn_ltb <= Mp_x
        disp("El perfil resiste momento por LTB")
    else
        disp("El perfil no resiste momento por LTB")
    end
else
    disp("Revisar F-AISC")
end

if Mn_yi < Mn_ltb
    Mrx = Mn_yi;
else
    Mrx = Mn_ltb;
end

Mp_y = fy*Zy;

if Mp_y <= (1.6*fy*Sy)
    Mry = Mp_y;
else
    disp("Revisar F-AISC")
end


% % ------ [H-AISC] ------
% if Pr/Pc > 0.2
    

