%% Diseño de Vigas C Acero | Flexión y Cortante
% clc; 
clear;
% Cálculo acorde a AISC
% Cap. B | Design Requirements
% Cap. F | Design of members for flexure (F2)
% Cap. G | Design of members for shear (G2)

filename = "D:\Users\Regina\Documents\Semestre 8\Proyecto Integrador\aisc-shapes-database-v15.0.xlsx";
sheet = "Database v15.0";
[num,txt,raw] = xlsread(filename,sheet);
[x,y] = size(raw);

E = 29000;         %[ksi] Módulo de Elasticidad de acero
G = 11200;         %[ksi] Módulo de elasticidad de cortante de acero
fy = 50;           %Esfuerzo de fluencia [ksi] (ASTM A572)
FS_c = 0.90;       %[φ] FS Cortante
FS_b = 0.90;       %[φ] FS Flexión

% %% Check
% % Variable Zx requerida
% Zx_min = Mu/(FS_b*fy);
% 2:284

%% Datos iniciales
Propuesta = "C8X18.75";

L_m = 5.787;          %[m] Longitud
L = L_m*39.3701;    %[in] Longitud

% --- Datos STAAD.Pro ---
Vu = 10.68;      %[kips] Cortante max.
Mu = 469.2;         %[in-kips] Momento max.
M_max = Mu;     %[in*kips] Momento máximo
MA = 397.868;        %[in*kips] Momento a 1/4 del segmento no arriostrado
MB = 469.2;        %[in*kips] Momento a 1/2 del segmento no arriostrado
MC = 280.94;        %[in*kips] Momento a 3/4 del segmento no arriostrado

% d1_techo = 0.013;       %[in] RAM
% d2_techo = 0.353;       %[in] RAM
% d3_techo = 0.445;       %[in] RAM
% L1 = 13*12;     %[in] Claro viga 1-2
% L2 = 26*12;     %[in] Claro viga 2-3 y 3-4
% Variable Zx calculada requerida
Zx_min = Mu/(FS_b*fy);

%% CLASIFICACIÓN DEL PERFIL ESTRUCTURAL
% En base a datos iniciales
    % Propuesta de Perfil

for i = 2:x
    for j = 3:y
        if isequal(raw(i,3),cellstr(Propuesta))
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
            l_patin = cell2mat(raw(i,33));  %λ Patín (bf/2tf) | MANUAL AISC
            l_alma = cell2mat(raw(i,36));   %λ Alma (h/tw) | MANUAL AISC
            d = cell2mat(raw(i,7));         %[in] Peralte incluyendo patines
            tw = cell2mat(raw(i,17));       %[in] Espesor alma
        end
    end
end

% c = 1;           % Cte. = 1 en perfiles W, en canales c = (h0/2)*sqrt(Iy/Cw);
c = (h0/2)*sqrt(Iy/Cw);
Lb = L;

% ----------------------------------------------------------------------
% Tabla Ba4.1a.- Elementos de miembros a compresión 
%                   sujetos a flexión
% Límite de compacto / no compacto / esbelto
%--- Caso 10 --- Patín / Flange
l_pf = 0.38*sqrt(E/fy); % λp Patín
l_rf = 1*sqrt(E/fy);    %λr Patín
%---Caso 15 --- Alma / Web
l_pw = 3.76*sqrt(E/fy); %λp Alma
l_rw = 5.70*sqrt(E/fy); %λr Alma

% -- Compacidad de patín
if (l_patin < l_pf)
    disp('El patín de la viga si es compacto, el pandeo lateral torsional no aplica')
    comp_patin = "compacto";
elseif (l_patin > l_rf)
    disp('El patín de la viga es esbelto')
    comp_patin = "esbelto";
else
    disp('El patín de la viga es no compacto')
    comp_patin = "no compacto";
end

% -- Compacidad de alma
if (l_alma < l_pw)
    disp('El alma de la viga si es compacto, el pandeo lateral torsional no aplica')
    comp_alma = "compacto";
elseif (l_alma > l_rw)
    disp('El alma de la viga es esbelto')
    comp_alma = "esbelto";
else
    disp('El alma de la viga es no compacto')
    comp_alma = "no compacto";
end

% if (comp_patin == "compacto") && (comp_alma == "compacto")
%     caso_comp = 1;  %[F2-AISC] Pandeo Lateral Torsional
% elseif (comp_patin == "no compacto") && (comp_alma == "compacto")
%     caso_comp = 2;  %[F3-AISC] Pandeo Local del Patín a compresión
% else
%     disp('Hay un elemento esbelto, seleccionar otro perfil')
%     caso_comp = 0
% end

%% RESISTENCIA A FLEXIÓN
% Mn: Momento nominal a flexión

% --- [F2.1-AISC] ---
Mp = fy * Zx;       %Resistencia nominal a flexión
Lp = 1.76*ry*sqrt(E/fy);
Lr = 1.95*rts*(E/(0.7*fy))*sqrt(((J*c)/(Sx*h0))+(sqrt((((J*c)/(Sx*h0))^2)+(6.76*((0.7*fy)/E)^2))));
% Cb: Factor de modificación de pandeo lateral-torsional
Cb = (12.5*abs(M_max))/(2.5*abs(M_max) + 3*MA + 4*MB + 3*MC);
% --- [F2.2-AISC] Pandeo lateral-torsional ---
if Lb <= Lp
    disp('No aplica el estado límite de Pandeo lateral-torsional')
    Mn = Mp;
    caso_Mn = "F2";
elseif (Lp < Lb) && (Lb <= Lr)
    Mn = 0.9*Cb*(Mp-(Mp-0.7*fy*Sx)*((Lb-Lp)/(Lr-Lp)));

elseif Lb > Lr
    Fcr = ((Cb*pi^2*E)/((Lb/rts)^2))*sqrt(1+0.078*((J*c)/(Sx*h0))*((Lb/rts)^2));
    Mn = Fcr*Sx;
end


%---------Comprobación final----------
MR = Mn*FS_b ;        %[kips-in] Resistencia final
if MR >= Mu
    D = ['El momento requerido es ',num2str(Mu),' kips-in, el perfil resiste ',num2str(MR),' kips-in; por lo que es resistente a flexión'];
    disp(D)
else
    D = ['El momento requerido es ',num2str(Mu),' kips-in, el perfil resiste ',num2str(MR),' kips-in; por lo que NO es resistente a flexión, selecciona otro perfil'];
    disp(D)
end   

disp(['Trabaja a un ',num2str((Mu/MR)*100),'% de su capacidad a flexión'])

%% DISEÑO POR CORTANTE | Vu <= Vn*FS
Aw = d*tw;          %[in2] Área
h_tw = l_alma;       %Relación ancho - espesor del alma

if h_tw <= 2.24*sqrt(E/fy)
    FS_c = 1;           %Factor de Seguridad cortante LRFD
    Cv = 1;
else
    if h_tw < 260
        kv = 5;
        %------Determinación de Cte. de Cortante-------
        if h_tw <= 1.10*sqrt((kv*E)/fy)
            Cv = 1;
        elseif 1.10*sqrt((kv*E)/fy) < h_tw <= 1.37*sqrt((kv*E)/fy)
            Cv = (1.10*sqrt((kv*E)/fy))/(h_tw);
        else
            Cv = (1.51*kv*E)/((h_tw^2)*fy);
        end
    else
        disp('El perfil de viga no aplica para criterio de cortante')
    end
end

%---------Comprobación final----------
Vn = 0.6*fy*Aw*Cv;  %[kips] Resistencia nominal al cortante
VR = Vn*FS_c ;        %[kips] Resistencia final

if Vu <= VR
    DP = ['El cortante requerido es ',num2str(Vu),'kips, el perfil resiste ',num2str(VR),'kips; por lo que es resistente a cortante.'];
    disp(DP)
else
    DP = ['El cortante requerido es ',num2str(Vu),'kips, el perfil resiste ',num2str(VR),'kips; por lo que NO es resistente a cortante.'];
    disp(DP)
end


%% DEFLEXIÓN EN VIGAS
% D1_techo = L1/240;   %[in] Deflexión techo Claro 1 |ASCE
% D2_techo = L2/240;   %[in] Dfelexión techo Claro 2 y 3 |ASCE
% 
% if d1_techo<D1_techo && d2_techo<D2_techo && d3_techo<D2_techo
%     disp('La deflexión si es adecuada')
% else
%     disp('La deflexión no es adecuada')
% end
