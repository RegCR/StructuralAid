% Pruebas estáticas (R8, R9, R10, R24)
clear; close all; clc;

%% R8, lector de Prueba 1
%      Prueba estática, claro Arq

filename8 = 'R8_table.mat';
Data8 = load(filename8);

No_puntos8 = table2array(Data8.R8(4,2));
freq_ad8 = table2array(Data8.R8(4,3));
l_width8 = width(Data8.R8);
l_height8 = height(Data8.R8);

delta8 = 1/freq_ad8;
t_ult8 = (No_puntos8-1)*delta8;

% Variables a llamar en función
Data_val8 = table2array(Data8.R8(20:l_height8,:));
vec_tiempo8 = 0 :delta8: t_ult8; % Definir tiempo

[d_arq_8, d_central_8, d_food_8, i_arq_8, i_central_8, i_food_8, AY_arq_8, AY_central_8, AY_food_8, AZ_arq_8, AZ_central_8, AZ_food_8, e_arq1_8, e_arq2_8, e_cent_arq1_8, e_cent_arq2_8, e_central1_8, e_cent_food1_8, e_food1_8, e_food2_8, e_food3_8, e_food4_8, e_food5_8, e_food6_8, e_food7_8, e_food8_8, e_food9_8] = Lector_senales(Data_val8,vec_tiempo8);


% ----------- Análisis Meseta ----------
mes_i8 = 440;       % Tiempo inicial a analizar
mes_f8 = 750;        % Tiempo final a analizar

[l_mes,mes_d_arq,mes_d_central,mes_d_food,mes_i_arq,mes_i_central,mes_i_food,mes_AY_arq,mes_AY_central,mes_AY_food,mes_AZ_arq,mes_AZ_central,mes_AZ_food,mes_e_arq1,mes_e_arq2,mes_e_cent_arq1,mes_e_cent_arq2,mes_e_central1,mes_e_cent_food1,mes_e_food1,mes_e_food2,mes_e_food3,mes_e_food4,mes_e_food5,mes_e_food6,mes_e_food7,mes_e_food8,mes_e_food9] = Meseta(mes_i8,mes_f8,freq_ad8, d_arq_8, d_central_8, d_food_8, i_arq_8, i_central_8, i_food_8, AY_arq_8, AY_central_8, AY_food_8, AZ_arq_8, AZ_central_8, AZ_food_8, e_arq1_8, e_arq2_8, e_cent_arq1_8, e_cent_arq2_8, e_central1_8, e_cent_food1_8, e_food1_8, e_food2_8, e_food3_8, e_food4_8, e_food5_8, e_food6_8, e_food7_8, e_food8_8, e_food9_8);



%% R9, lector de Prueba 2
%      Prueba estática, claro Food

filename9 = 'R9_table.mat';
Data9 = load(filename9);

No_puntos9 = table2array(Data9.R9(4,2));
freq_ad9 = table2array(Data9.R9(4,3));
l_width9 = width(Data9.R9);
l_height9 = height(Data9.R9);

delta9 = 1/freq_ad9;
t_ult9 = (No_puntos9-1)*delta9;

% Variables a llamar en función
Data_val9 = table2array(Data9.R9(20:l_height9,:));
vec_tiempo9 = 0 :delta9: t_ult9; % Definir tiempo

[d_arq_9, d_central_9, d_food_9, i_arq_9, i_central_9, i_food_9, AY_arq_9, AY_central_9, AY_food_9, AZ_arq_9, AZ_central_9, AZ_food_9, e_arq1_9, e_arq2_9, e_cent_arq1_9, e_cent_arq2_9, e_central1_9, e_cent_food1_9, e_food1_9, e_food2_9, e_food3_9, e_food4_9, e_food5_9, e_food6_9, e_food7_9, e_food8_9, e_food9_9] = Lector_senales(Data_val9,vec_tiempo9);

%% R10, lector de Prueba 3
%      Prueba estática claro Central

filename10 = 'R10_table.mat';
Data10 = load(filename10);

No_puntos10 = table2array(Data10.R10(4,2));
freq_ad10 = table2array(Data10.R10(4,3));
l_width10 = width(Data10.R10);
l_height10 = height(Data10.R10);

delta10 = 1/freq_ad10;
t_ult10 = (No_puntos10-1)*delta10;

% Variables a llamar en función
Data_val10 = table2array(Data10.R10(20:l_height10,:));
vec_tiempo10 = 0 :delta10: t_ult10; % Definir tiempo

[d_arq_10, d_central_10, d_food_10, i_arq_10, i_central_10, i_food_10, AY_arq_10, AY_central_10, AY_food_10, AZ_arq_10, AZ_central_10, AZ_food_10, e_arq1_10, e_arq2_10, e_cent_arq1_10, e_cent_arq2_10, e_central1_10, e_cent_food1_10, e_food1_10, e_food2_10, e_food3_10, e_food4_10, e_food5_10, e_food6_10, e_food7_10, e_food8_10, e_food9_10] = Lector_senales(Data_val10,vec_tiempo10);

%% R24, lector de Prueba 9
%      Prueba estática repetida, claro Food

filename = 'R24_table.mat';
Data = load(filename);

No_puntos = table2array(Data.R24(4,2));
freq_ad = table2array(Data.R24(4,3));
l_width = width(Data.R24);
l_height = height(Data.R24);

delta = 1/freq_ad;
t_ult = (No_puntos-1)*delta;

% Variables a llamar en función
Data_val = table2array(Data.R24(20:l_height,:));
vec_tiempo = 0 :delta: t_ult; % Definir tiempo

[d_arq,d_central,d_food,i_arq,i_central,i_food,AY_arq,AY_central,AY_food,AZ_arq,AZ_central,AZ_food,e_arq1,e_arq2,e_cent_arq1,e_cent_arq2,e_central1,e_cent_food1,e_food1,e_food2,e_food3,e_food4,e_food5,e_food6,e_food7,e_food8,e_food9] = Lector_senales(Data_val,vec_tiempo);

%% Análisis
% Creación de matriz compartida de meseta
l_height_tot = [l_height, l_height10, l_height8, l_height9];
% height_mes = max(l_height_tot);

n_mes = length(l_height_tot);
mes = zeros(1,n_mes);

for i = 1:n_mes
    

