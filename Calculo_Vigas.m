clc; clear;
%% Datos iniciales
FS = 0.9;        %Factor de Seguridad para flexión LRFD(AISC)
fy = 50;           %Esfuerzo de fluencia [ksi] (ASTM A572)
E = 29000;           %[ksi] Módulo de Elasticidad

    %Carga en viga (B 2-3) de Marco B | Con peso propio
M_max = 732.55;     %[in*kips] Momento máximo|DATOS RAM
MA = 1;        %[in*kips] Momento a 1/4 del segmento no arriostrado
MB = 1;        %[in*kips] Momento a 1/2 del segmento no arriostrado
MC = 1;        %[in*kips] Momento a 3/4 del segmento no arriostrado

Vu = 12.979;      %[kips] Cortante max. | RAM


    %PROPUESTA: Perfil: W 12x26
Propuesta = "W12X26";

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
    

Sviga = Sx;      %in^3
c = 1;

L = 3;              %[] Longitud
Lb = L/3;           %[] Longitud arriostrada

% L1 = 13*12;     %[in] Claro viga 1-2
% L2 = 26*12;     %[in] Claro viga 2-3 y 3-4

% d1_techo = 0.013;       %[in] RAM
% d2_techo = 0.353;       %[in] RAM
% d3_techo = 0.445;       %[in] RAM

%% CLASIFICACIÓN DEL PERFIL ESTRUCTURAL
% --- Compacidad del elemento ---
lp_patin = 0.38*sqrt(E/fy); %λp Patín
lp_alma = 3.76*sqrt(E/fy);  %λp Alma

lr_patin = 1*sqrt(E/fy); %λr Patín
lr_alma = 5.70*sqrt(E/fy);  %λr Alma

% -- Compacidad de patín
if (l_patin < lp_patin)
    disp('El patín de la viga si es compacto, el pandeo lateral torsional no aplica')
    comp_patin = "compacto";
elseif (l_patin > lr_patin)
    disp('El patín de la viga es esbelto')
    comp_patin = "esbelto";
else
    disp('El patín de la viga es no compacto')
    comp_patin = "no compacto";
end

% -- Compacidad de alma
if (l_alma < lp_alma)
    disp('El alma de la viga si es compacto, el pandeo lateral torsional no aplica')
    comp_alma = "compacto";
elseif (l_alma > lr_alma)
    disp('El alma de la viga es esbelto')
    comp_alma = "esbelto";
else
    disp('El alma de la viga es no compacto')
    comp_alma = "no compacto";
end

if (comp_patin == "compacto") && (comp_alma == "compacto")
    caso_comp = 1;
elseif (comp_patin == "no compacto") && (comp_alma == "compacto")
    caso_comp = 2;
else
    disp('Revisar caso en Manual AISC')
end

%% RESISTENCIA A FLEXIÓN
% Mn: Momento nominal a flexión

if caso_comp == 1
    % --- [F2-AISC] ---
    Mp = fy * Zx;       %Resistencia nominal a flexión
    Lp = 1.76*ry*sqrt(E/fy);
    Lr = 1.95*rts*(E/(0.7*fy))*sqrt(((J*c)/(Sx*h0))+(sqrt((((J*c)/(Sx*h0))^2)+(6.76*((0.7*fy)/E)^2))));
    
    % --- [F2.2-AISC] Pandeo lateral-torsional ---
    if Lb <= Lp
        disp('No aplica el estado límite de Pandeo lateral-torsional')
        Mn = Mp;
        caso_Mn = "F2";
    elseif (Lp < Lb) && (Lb <= Lr)
        % Cb: Factor de modificación de pandeo lateral-torsional
        Cb = (12.5*abs(M_max))/(2.5*abs(M_max) + 3*MA + 4*MB + 3*MC);
        Mn = 0.9*Cb*(Mp-(Mp-0.7*fy*Sx)*((Lb-Lp)/(Lr-Lp)));
        if Mn <= Mp
            disp('El Mn calculado pasa')
        else
            disp('El Mn calculado no pasa')
        end
    elseif Lb > Lr
        Fcr = ((Cb*pi^2*E)/((Lb/rts)^2))*sqrt(1+0.078*((J*c)/(Sx*h0))*((Lb/rts)^2));
        Mn = Fcr*Sx;
        if Mn <= Mp
            disp('El Mn calculado pasa')
        else
            disp('El Mn calculado no pasa')
        end  
    end
elseif caso_comp == 2
    Mp = fy * Zx;       %Resistencia nominal a flexión
    Lp = 1.76*ry*sqrt(E/fy);
    Lr = 1.95*rts*(E/(0.7*fy))*sqrt(((J*c)/(Sx*h0))+(sqrt((((J*c)/(Sx*h0))^2)+(6.76*((0.7*fy)/E)^2))));
    
    % --- F2.2 Pandeo lateral-torsional ---
    if Lb <= Lp
        disp('No aplica el estado límite de Pandeo lateral-torsional')
    elseif (Lp < Lb) && (Lb <= Lr)
        % Cb: Factor de modificación de pandeo lateral-torsional
        Cb = (12.5*abs(M_max))/(2.5*abs(M_max) + 3*MA + 4*MB + 3*MC);
        Mn = 0.9*Cb*(Mp-(Mp-0.7*fy*Sx)*((Lb-Lp)/(Lr-Lp)));
        if Mn <= Mp
            disp('El Mn calculado pasa')
        else
            disp('El Mn calculado no pasa')
        end
    elseif Lb > Lr
        Fcr = ((Cb*pi^2*E)/((Lb/rts)^2))*sqrt(1+0.078*((J*c)/(Sx*h0))*((Lb/rts)^2));
        Mn = Fcr*Sx;
        if Mn <= Mp
            disp('El Mn calculado pasa')
        else
            disp('El Mn calculado no pasa')
        end  
    end
    
    % ---[F3-AISC] Efecto de pandeo local del patín a compresión---
    if comp_patin == "no compacto"
        lambda = l_patin;
        l_pf = lp_patin;
        l_rf = lr_patin;
        Mn = Mp-(Mp-0.7*fy*Sx)*((lambda-l_pf)/(l_rf-l_pf));
        caso_Mn = "F3";
    end
end

if Mn >= M_max
    disp("La viga es resistente a flexión")
else
    disp("La viga no resiste a flexión")
end

    

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
        disp('El perfil de viga no aplica')
    end
end

%---------Comprobación final----------
Vn = 0.6*fy*Aw*Cv;  %[kips] Resistencia nominal al cortante
VR = Vn*FS_c ;        %[kips] Resistencia final

if Vu <= VR
    disp('El perfil de viga si cumple por cortante')
else
    disp('El perfil de viga no cumple por cortante')
end


%% CÁLCULO VIGA | Flexión
    %Carga en viga de Marco B | Sin cargas de viga
% eperm = (fy/FS);    %Esfuerzo permisible [ksi]
% 
%     %Sección (S = Momento max. / Esfuerzo permisible)
% Sreq = (M_max)/eperm;   %in^3
% 
% %SECCIÓN FINAL
% Sreq_final = (Mv_max)/eperm  %in^3
% 
% if Sreq_final <= Sviga
%     disp('El perfil de viga si cumple por flexión')
% else
%     disp('EL perfil de viga no cumple por flexión')
% end

%% DEFLEXIÓN EN VIGAS
% D1_techo = L1/240;   %[in] Deflexión techo Claro 1 |ASCE
% D2_techo = L2/240;   %[in] Dfelexión techo Claro 2 y 3 |ASCE
% 
% if d1_techo<D1_techo && d2_techo<D2_techo && d3_techo<D2_techo
%     disp('La deflexión si es adecuada')
% else
%     disp('La deflexión no es adecuada')
% end
