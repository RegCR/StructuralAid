clear; close all; clc;

%% R8, lector de Prueba 1
%      Prueba estática con carga posicionada sobre claro cercano a Arq

filename = 'R8_table.mat';
Data = load(filename);

No_puntos = table2array(Data.R8(4,2));
freq_ad = table2array(Data.R8(4,3));
l_width = width(Data.R8);
l_height = height(Data.R8);

delta = 1/freq_ad;
t_ult = (No_puntos-1)*delta;

% Variables a llamar en función
Data_val = table2array(Data.R8(20:l_height,:));
vec_tiempo = 0 :delta: t_ult; % Definir tiempo

% for i = 1:l_width
%     V_Names = cell2mat(Data.R8.Properties.VariableNames(i));
% end

% cant_strain = 16;
% cant_incli = 3;
% cant_acce = 6;
% cant_disp = 3;
% 
% base = 'Data.R8.';
% val_strain = 'Strain';
% val_incli = 'Incline';
% val_acce = 'Accelerometer';
% val_disp = 'Displacement';
% 
% plot(vec_tiempo,Data.R8.Displacement)
% hold on
% for i = 1:(cant_disp-1)
%     xplot = append(base,val_disp,num2str(i));
%     plot(vec_tiempo,eval(xplot))
%     xlim([-0.02 0.02])
% end
% 
% legend('D1','D2','D3')

%% Displacement
d_arq = Data_val(:,28);
d_central = Data_val(:,21);
d_food = Data_val(:,12);

% Gráficos
% Prueba completa
figure('Name','LVDT P1')
subplot(1,2,1)
plot(vec_tiempo,d_arq)
hold on
grid on

plot(vec_tiempo,d_central)
plot(vec_tiempo,d_food)
legend('Arq','Central','Food')
title('LVDT Prueba completa 1') 
xlabel('Tiempo (s)')
ylabel('Desplazamiento (mm)') 

% Meseta
% subplot(1,2,2)
% plot(vec_tiempo,d_arq)
% hold on
% grid on
% xlim([430 750])

% plot(vec_tiempo,d_central)
% plot(vec_tiempo,d_food)
% legend('Arq','Central','Food')
% title('LVDT Meseta P1') 
% xlabel('Tiempo (s)') 
% ylabel('Desplazamiento (mm)')

figure
plot(vec_tiempo,d_arq,'color','#5b802a')
set(gca,'Color','#2b3436')
hold on
grid on
xlim([430 750])
plot(vec_tiempo,d_central,'color','#de5a21')
plot(vec_tiempo,d_food,'color','#69c0d1')

legend('Arq','Central','Food','Color','w','Location','eastoutside')
title('LVDT Meseta Prueba 1') 
xlabel('Tiempo (s)')
ylabel('Desplazamiento (mm)') 


% Vector filtrado en meseta 
Mes_d_arq = d_arq(430:750);

%% Incline
i_arq = Data_val(:,2);
i_central = Data_val(:,17);
i_food = Data_val(:,15);

% Gráficos
% Prueba completa
figure('Name','Inclinómetros P1')
subplot(1,2,1)
plot(vec_tiempo,i_arq)
hold on
grid on

plot(vec_tiempo,i_central)
plot(vec_tiempo,i_food)
legend('Arq','Central','Food')
title('Inclinómetro Prueba completa 1') 
xlabel('Tiempo (s)') 
ylabel('Inclinación (grados)')

subplot(1,2,2)
plot(vec_tiempo,i_arq)
hold on
grid on
xlim([430 750])

% Meseta
plot(vec_tiempo,i_central)
plot(vec_tiempo,i_food)
legend('Arq','Central','Food')
title('Inclinómetro Meseta P1') 
xlabel('Tiempo (s)') 
ylabel('Inclinación (grados)')


% Vector nuevo 
Mes_i_arq = i_arq(430:750);

%% Accelerometer
% Acelerometros direccion Y
AY_arq = Data_val(:,3); % 3054 
AY_central = Data_val(:,27); % 3055 
AY_food = Data_val(:,13); % 3053 

% Acelerometros direccion Z
AZ_arq = Data_val(:,4); % 3054
AZ_central = Data_val(:,26); % 3055
AZ_food = Data_val(:,14); % 3053

% Gráfico
figure('Name','Acelerómetros P1')

% Acelerómetros en Y
subplot(1,2,1)
plot(vec_tiempo, AY_arq,'m')
hold on
grid on
plot(vec_tiempo,AY_central,'b')
plot(vec_tiempo,AY_food,'r')

title('Acelerómetros [Y] P1') %Titulo de Grafica
xlabel('Tiempo (s)') %Eje x
ylabel('G(s)') %Eje 
legend('Arq','Central','Food')

% Acelerómetros en Z
subplot(1,2,2)
plot(vec_tiempo, AZ_arq,'m')
hold on
grid on
plot(vec_tiempo,AZ_central,'b')
plot(vec_tiempo,AZ_food,'r')

title('Acelerómetros [Z] P1') 
legend('Arq','Central','Food')

%% Strain
e_arq1 = Data_val(:,1); % Más cercano a edificio
e_arq2 = Data_val(:,9); 

e_cent_arq1 = Data_val(:,10);
e_cent_arq2 = Data_val(:,25); %B9211_22A, Sensor que más se deflecta en
                                % general y en sentido negativo en meseta
                                % Ubicado a lado de la columna de concreto
                                % C5 (División claro arq y central)

e_central1 = Data_val(:,11);

e_cent_food1 = Data_val(:,20);

e_food1 = Data_val(:,5);
e_food2 = Data_val(:,6);
e_food3 = Data_val(:,7);
e_food4 = Data_val(:,8);
e_food5 = Data_val(:,16);
e_food6 = Data_val(:,18);
e_food7 = Data_val(:,19);   % B8107_20B, Sensor que más se deflecta en 
                            % sentido positivo en meseta
                            % Ubicado
e_food8 = Data_val(:,22);
e_food9 = Data_val(:,23);

% Gráficos
figure('Name','Extensómetros completos P1')
plot(vec_tiempo, e_arq1)
hold on
grid on
plot(vec_tiempo, e_arq2)
plot(vec_tiempo, e_cent_arq1)
plot(vec_tiempo, e_cent_arq2)   % Sensor que más se deflecta (negativo)
plot(vec_tiempo, e_central1)
plot(vec_tiempo, e_cent_food1)
plot(vec_tiempo, e_food1)
plot(vec_tiempo, e_food2)
plot(vec_tiempo, e_food3)
plot(vec_tiempo, e_food4)
plot(vec_tiempo, e_food5)
plot(vec_tiempo, e_food6)
plot(vec_tiempo, e_food7)   % Sensor que más se deflecta (positivo)
plot(vec_tiempo, e_food8)
plot(vec_tiempo, e_food9)

legend('Arq1','Arq2','Cent - arq1','Cent - arq2','Cent','Cent - food','Food1','Food2','Food3','Food4','Food5','Food6','Food7','Food8','Food9')
title('Extensómetros') 
xlabel('Tiempo (s)')
ylabel('ue (Microdeformaciones)') 

% Vector nuevo 
Mes_e_centarq = e_cent_arq2(430:750);
