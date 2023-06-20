%% Diseño de columnas Acero| Flexocompresión
clc; 
clear;
% Cálculo acorde a AISC
% Cap. B | Design Requirements
% Cap. E | Design of members for compression (E3/E4)
% Cap. F | Design of members for flexure (F2)
% Cap. H | Design of members for combined forces and torsion (H1)

filename = "D:\Users\Regina\Documents\Semestre 8\Proyecto Integrador\aisc-shapes-database-v15.0.xlsx";
sheet = "Database v15.0";
[num,txt,raw] = xlsread(filename,sheet);
[x,y] = size(raw);

E = 29000;         %[ksi] Módulo de Elasticidad de acero
G = 11200;         %[ksi] Módulo de elasticidad de cortante de acero
fy = 50;           %Esfuerzo de fluencia [ksi] (ASTM A572)
FS_c = 0.90;       %[φ] FS Compresión
FS_b = 0.90;       %[φ] FS 

% %% Check
% % Considerando que estamos en el primer caso
% Pr_min = Pu/0.5;    %[kips] La cantidad mínima de resistencia última
% 
% %    ------ Cantidades mínimas requeridas ---------
% RE_min = (k*L)/r;               %Relación Esbeltez
% Fe_min = ((pi^2*E)/(RE_min^2));     %[ksi] Esfuerzo
% Fcr_min = (0.658^(fy/Fe_min))*fy;    % Esfuerzo crítico de pandeo
% Ag_min = Pr_min/(FS_c*Fcr_min);        %[in2] Área bruta mínima de acero
% 
% if Ag>= Ag_min
%     disp("El perfil seleccionado cumple el área mínima de acero")
% else
%     disp("Seleccionar otro perfil con el siguiente área mínima de acero")
%     disp(" ")
%     disp(Ag_min)
% end


%% Datos iniciales
L_m = 2.8;           %[m] Longitud
L_in = L_m*39.3701;      %[in] Longitud Real

% --- Datos STAAD.Pro ---
Pu = 317.117;        %[kips] Carga axial de estructuras
Vu = 44.68;      %[kips] Cortante max
Mu = 4875.706;       %[kips-in] Momento max | Flexion
MA = 942;       %[in*kips] Momento a 1/4 del segmento no arriostrado
MB = 2207;       %[in*kips] Momento a 1/2 del segmento no arriostrado
MC = 3535;       %[in*kips] Momento a 3/4 del segmento no arriostrado
M_max = Mu;         %[in*kips] Momento máximo

    % Propuesta de Perfil
Propuesta = "W18X143";

%% DISEÑO y REVISIÓN DE PERFIL
% En base a datos iniciales
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
            h_tw = cell2mat(raw(i,36));
            bf_2tf = cell2mat(raw(i,33));
            d = cell2mat(raw(i,7));         %[in] Peralte incluyendo patines
            tw = cell2mat(raw(i,17));       %[in] Espesor alma
        end
    end
end

Kz = 1;     % Factor de longitud efectiva para
            %   torsional buckling
c = 1;     % Cte. = 1 en perfiles W, en canales c = (h0/2)*sqrt(Iy/Cw);
k = 1;      % Condición de frontera registrinda se toma como empotramiento
l_patin = bf_2tf;
l_alma = h_tw;

if rx < ry  %[in] Radio de Giro mínimo (Caso Crítico)
    r = rx;
else
    r = ry;
end

L = L_in;            %[in] Longitud real
Lb = (L_in)*k;       %[in] Longitud efectiva


    %------ Cantidades mínimas requeridas ---------
RE_min = (k*L)/r;               %Relación Esbeltez

    %------------Comprobación de Perfil---------
if RE_min < 200
    disp('La esbeltez del perfil de columna si es aceptable')
    Pandeo = 4.71*(sqrt(E/fy));   %Determinación de tipo de pandeo
        
    if RE_min <= Pandeo
        disp('El pandeo de la columna es inelástico')
        
        % ------- CASO PERFIL W  y  MONTENES TIPO C -------
        % --- Análisis de relación de esbeltez ---
        % Tabla Ba4.1a.- Elementos de miembros a compresión 
        %                 sujetos a compresión axial
        % Límite de esbelto / no esbelto
        l_rflange = 0.56*sqrt(E/fy);
        l_rweb = 1.49*sqrt(E/fy);

        % Tabla Ba4.1a.- Elementos de miembros a compresión 
        %                   sujetos a flexión
        % Límite de compacto / no compacto / esbelto
        %--- Caso 10 --- Patín
        l_pf = 0.38*sqrt(E/fy); % Límite de compacidad
        l_rf = 1*sqrt(E/fy);    
        %---Caso 15 --- Alma
        l_pw = 3.76*sqrt(E/fy); % Límite de compacidad 
        l_rw = 5.70*sqrt(E/fy);
        
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

        if (comp_patin == "compacto") && (comp_alma == "compacto")
            caso_comp = 1;  %[F2-AISC] Pandeo Lateral Torsional
        elseif (comp_patin == "no compacto") && (comp_alma == "compacto")
            caso_comp = 2;  %[F3-AISC] Pandeo Local del Patín a compresión
        else
            disp('Hay un elemento esbelto, seleccionar otro perfil')
        end

        
        % PERFIL W y MONTENES TIPO C
        % Cálculo de resistencia a compresión axial
        if bf_2tf < l_rflange &&  h_tw< l_rweb
            disp("El perfil no es esbelto por compresión")
            % E3 / E4 .- Seleccionar más crítico  
            %[E3] Resistencia a la compresión por pandeo flexionante global
            RE_fg = (k*L)/r;       %[in]
            Fe_fg = ((pi^2*E)/(RE_fg^2));     %[ksi] Esfuerzo
            Fcr_fg = (0.658^(fy/Fe_fg))*fy;    % Esfuerzo crítico por pandeo
            Pr_fg = FS_c*Ag*Fcr_fg;          %[kips] Resistencia por compresión

            %[E4] Resistencia a la compresión por flexotorsión
            Fe_ft = (((pi^2*E*Cw)/((Kz*L)^2))+(G*J))*(1/(Ix+Iy));   %[ksi]
            if fy/Fe_ft <=2.25
                Fcr_ft = (0.658^(fy/Fe_ft))*fy;     %[ksi]
                Pr_ft = FS_c*Ag*Fcr_ft;            %[kips]
            else
                disp("Seleccionar otro perfil")
            end

            %Seleccionar la menor de las dos capacidades (Fuerza dominante)
            if Pr_ft < Pr_fg
                disp(['La compresión requerida es ',num2str(Pu),'kips, el perfil resiste ',num2str(Pr_ft),'kips; por lo que es resistente a compresión. Acorde al caso E4'])
                Pr = Pr_ft;
            else
                disp(['La compresión requerida es ',num2str(Pu),'kips, el perfil resiste ',num2str(Pr_fg),'kips; por lo que es resistente a compresión. Acorde al caso E3'])
                Pr = Pr_fg;
            end  
        else
            disp("El perfil es esbelto por compresión, revisar capítulo E7")
        end

        % -----------------------------------------------------------------
        % Cálculo de resistencia a flexión 
        % Mn: Momento nominal a flexión
        if caso_comp == 1
            % --- [F2.1-AISC] ---
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
%                 if Mn <= Mp
%                     disp('El Mn calculado pasa')
%                 else
%                     disp('El Mn calculado no pasa')
%                 end
            elseif Lb > Lr
                Fcr = ((Cb*pi^2*E)/((Lb/rts)^2))*sqrt(1+0.078*((J*c)/(Sx*h0))*((Lb/rts)^2));
                Mn = Fcr*Sx;
%                 if Mn <= Mp
%                     disp('El Mn calculado pasa')
%                 else
%                     disp('El Mn calculado no pasa')
%                 end  
            end
        elseif caso_comp == 2
            Mp = fy * Zx;       %Resistencia nominal a flexión
            Lp = 1.76*ry*sqrt(E/fy);
            Lr = 1.95*rts*(E/(0.7*fy))*sqrt(((J*c)/(Sx*h0))+(sqrt((((J*c)/(Sx*h0))^2)+(6.76*((0.7*fy)/E)^2))));

            % --- [F2.2] Pandeo lateral-torsional ---
            if Lb <= Lp
                disp('No aplica el estado límite de Pandeo lateral-torsional')
            elseif (Lp < Lb) && (Lb <= Lr)
                % Cb: Factor de modificación de pandeo lateral-torsional
                Cb = (12.5*abs(M_max))/(2.5*abs(M_max) + 3*MA + 4*MB + 3*MC);
                Mn = 0.9*Cb*(Mp-(Mp-0.7*fy*Sx)*((Lb-Lp)/(Lr-Lp)));
%                 if Mn <= Mp
%                     disp('El Mn calculado pasa')
%                 else
%                     disp('El Mn calculado no pasa')
            end
            elseif Lb > Lr
                Fcr = ((Cb*pi^2*E)/((Lb/rts)^2))*sqrt(1+0.078*((J*c)/(Sx*h0))*((Lb/rts)^2));
                Mn = Fcr*Sx;
%                 if Mn <= Mp
%                     disp('El Mn calculado pasa')
%                 else
%                     disp('El Mn calculado no pasa')
%                 end  
        end

            % ---[F3-AISC] Efecto de pandeo local del patín a compresión---
            if comp_patin == "no compacto"
                lambda = l_patin;
                Mn = Mp-(Mp-0.7*fy*Sx)*((lambda-l_pf)/(l_rf-l_pf));
                caso_Mn = "F3";
            end
    end

        %---------Comprobación final----------
        MR = Mn*FS_b ;        %[kips-in] Resistencia final
        if MR >= Mu
            disp(['El momento requerido es ',num2str(Mu),'kips-in, el perfil resiste ',num2str(MR),'kips-in; por lo que resiste e a flexión.'])
        else
            disp(['El momento requerido es ',num2str(Mu),'kips-in, el perfil resiste ',num2str(MR),'kips-in; por lo que NO resiste a flexión, selecciona otro perfil.'])
        end
        
        disp(['Trabaja a un ',num2str((Mu/MR)*100),'% de su capacidad a flexión'])
        disp(['Trabaja a un ',num2str((Pu/Pr)*100),'% de su capacidad a compresión'])
        
        % Revisión de capacidad:
        % Efecto de flexocompresión uniaxial
        if (Pu/Pr)>=0.2
            res = (Pu/Pr)+((8/9)*(Mu/(MR)));
            if res <= 1.0
                disp("La capacidad es suficiente")
                if res > 0.95
                    disp("El perfil es más óptimo")
                else
                    disp("El perfil tiene más del 10% de pérdida de capacidad")
                end
            else
                disp("Proponer otro perfil")
            end
        else
            res = (Pu/(2*Pr))+(Mu/(MR));
            if res <= 1.0
                disp("La capacidad es suficiente")
            else
                disp("Proponer otro perfil")
            end
        end
        
    %else 
%         Fcr_E3 = 0.877*Fe_E3;     %[ksi] Esfuerzo Crítico
        disp('El pandeo de la columna es elástico')
    %end    
else
    disp('La esbeltez del perfil de columna no es aceptable')
end

%% DISEÑO POR CORTANTE | Vu <= Vn*FS
Aw = d*tw;          %[in2] Área

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