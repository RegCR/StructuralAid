        %Método de Rigideces | Análisis de armadura
clc;

%%      Datos iniciales

E = 20000000;   %Módulo de elasticidad (ton/m2)
A = 0.00755;    %Área de la sección transversal (m2)

filename = 'Rig_Armadura.xlsx';
sheet = 'Nodos';
    %Declarar nodos con sus coordenadas y GDL correspondientes
nodos = (xlsread(filename,sheet));  %Matriz
nodos_T = table(nodos(:,1),nodos(:,2),nodos(:,3),nodos(:,4),nodos(:,5));
nodos_T.Properties.VariableNames = {'Nodos','x(m)','y(m)','GDL x','GDL y'}

sheet = 'Elementos';

    %Declarar elementos
elem = (xlsread(filename,sheet));   %Matriz
elem_T = table(elem(:,1),elem(:,2),elem(:,3));
elem_T.Properties.VariableNames = {'Elemento','Nodo N','Nodo F'}

n_num = length(nodos(:,1));

e_num = length(elem(:,1));
ei = 1:e_num;
e = ei(:);

L = 0;

xn = 0;
yn = 0;

xf = 0;
yf = 0;

gxn = 0;
gyn = 0;

gxf = 0;
gyf = 0;

%%      Determinar longitud de elemento y GDL correspondientes

for i = 1:e_num
    for j = 1:n_num
        if elem(i,2) == nodos(j,1)
            xn(i) = nodos(j,2);
            yn(i) = nodos(j,3);
            
            gxn(i) = nodos(j,4);
            gyn(i) = nodos(j,5);
            
        end
    end
end

for i = 1:e_num
    for j = 1:n_num
        if elem(i,3) == nodos(j,1)
            xf(i) = nodos(j,2);
            yf(i) = nodos(j,3);
            
            gxf(i) = nodos(j,4);
            gyf(i) = nodos(j,5);

            L(i) = sqrt(((xf(i)-xn(i))^2)+((yf(i)-yn(i))^2));
        end
    end
end

L = L(:);

xn = xn(:);
yn = yn(:);

xf = xf(:);
yf = yf(:);

%%  Determinar cosenos directores

lamx = 0;
lamy = 0;

for i = 1:e_num
    lamx(i) = (xf(i)-xn(i))/L(i);
    lamy(i) = (yf(i)-yn(i))/L(i);
end

%% Análisis de elementos

kp_1 = [1 -1;-1 1];    %Matriz a multiplicar en k'

g_num = n_num*2;    %Grados de libertad

%Gk_F = zeros(g_num+1);
prompt = '¿Cuál es el último grado de libertad libre de movimiento? ';
gdl_l = input(prompt);  %Grados de libertad libres de mov
gt = [1:gdl_l];
gt_c1 = [0; transpose(gt)];
gt_c2 = [0; transpose([(gdl_l+1):g_num])];

Gk11 = zeros(gdl_l,gdl_l);   %k11
Gk11 = [gt; Gk11];
Gk11 = [gt_c1, Gk11];

Gk21 = zeros((g_num-gdl_l),gdl_l);   %k21
Gk21 = [gt; Gk21];
Gk21 = [gt_c2, Gk21];

[r,s] = size(Gk11);
[u,v] = size(Gk21);

for i = 1:e_num
    
    M = struct('GDL_c',{},'GDL',{},'FR',{},'kp',{},'T',{},'TT',{},'k',{},'Gk',{},'Gk_F',{});
        
    for ind = 1:e_num
            %Factor de rigidez del elemento
        M(ind).FR = (E*A)/L(ind);
        
            %Matriz de rigidez local
        M(ind).kp = M(ind).FRkp_1;
        
            %Matriz de transformación de coord.
        M(ind).T = [lamx(ind) lamy(ind) 0 0;
            0 0 lamx(ind) lamy(ind)];
        
            %Transpuesta Matriz de trans(T)
        M(ind).TT = transpose(M(ind).T);
        
            %Matriz de rigidez global
        M(ind).k = (M(ind).TT)*(M(ind).kp)*(M(ind).T);
        
            %Grados de libertad
        M(ind).GDL = [gxn(ind) gyn(ind) gxf(ind) gyf(ind)];
        M(ind).GDL_c = [0; transpose(M(ind).GDL)];
            
            %Matriz de rigidez global con GDL
        M(ind).k = [M(ind).GDL; M(ind).k];
        M(ind).k = [M(ind).GDL_c, M(ind).k];

    end
end

    %Matriz de rigidez global de la estructura

[x,y] = size(M(ind).k);
 
for ind=1:e_num
    for p = 2:r%    Gk 11 (Matriz Global estructura)
        for q = 2:s 
            for m = 2:x%    k (Matriz Global elemento)
                for n = 2:y
                    if Gk11(1,q)==M(ind).k(1,n) && Gk11(p,1)==M(ind).k(m,1)
                        a(ind) = M(ind).k(m,n);
                        Gk11(p,q) = Gk11(p,q) + a(ind);
                    end
                end
            end
        end
    end
    
    for p = 2:u%    Gk 12 (Matriz Global estructura)
        for q = 2:v 
            for m = 2:x%    k (Matriz Global elemento)
                for n = 2:y
                    if Gk21(1,q)==M(ind).k(1,n) && Gk21(p,1)==M(ind).k(m,1)
                        a(ind) = M(ind).k(m,n);
                        Gk21(p,q) = Gk21(p,q) + a(ind);
                    end
                end
            end
        end
    end
end

Gk11(1,:) = [];
Gk11(:,1) = [];

Gk21(1,:) = [];
Gk21(:,1) = [];

%%  Vector de Cargas externas y desplazamientos

    %Vector de Cargas externas
sheet = 'Cargas';

Q = (xlsread(filename,sheet));
Q(:,1) = [];
Q(isnan(Q)) = [];

    %Vector de desplazamientos
D = zeros((g_num-gdl_l),1); %No existen asentamientos

%%  Desplazamientos desconocidos

Gk11_i = pinv(Gk11);     %Inversa Gk11
Du = Gk11_i*Q;  %Desplazamientos
Du_T = [Du, transpose(gt)];
Du_Tt = table(Du_T(:,1),Du_T(:,2));
Du_Tt.Properties.VariableNames = {'Desplazamientos','GDL'}

Qu = Gk21*Du;   %Reacciones
Qu_T = [Qu,transpose([(gdl_l+1):g_num])];
Qu_Tt = table(Qu_T(:,1),Qu_T(:,2));
Qu_Tt.Properties.VariableNames = {'Reacciones','GDL'}

%%  Fuerzas internas

[m,n] = size(M(1).GDL);

FI = struct('q_du',{},'b',{},'q',{});

for z = 1:e_num

    FI(z).q_du = [transpose(M(z).GDL)];
    FI(z).b = zeros(n,1);
end

for r = 1:gdl_l %    Desplazamientos Du
    for s = 1:n %    Elementos FI
        for z = 1:e_num
            if FI(z).q_du(s,1) == Du_T(r,2)
                FI(z).b(s,1) = Du_T(r,1);
            end
        end
    end
end

for z = 1:e_num
    FI(z).q = (M(z).kp * M(z).T)*FI(z).b;
    c(z) = z;
    formatSpec = 'Las fuerzas internas del elemento %4.1f es %4.2f y %4.2f\n';
    fprintf(formatSpec,c(z),FI(z).q)
end


