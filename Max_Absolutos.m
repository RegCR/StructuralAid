function [max_mat, p_max, min_mat, p_min, abs_matriz, abs_matrizV, t_abs] = Max_Absolutos(mes_i,mes_f,freq_ad,d_arq,d_central,d_food,i_arq,i_central,i_food,AY_arq,AY_central,AY_food,AZ_arq,AZ_central,AZ_food,e_arq1,e_arq2,e_cent_arq1,e_cent_arq2,e_central1,e_cent_food1,e_food1,e_food2,e_food3,e_food4,e_food5,e_food6,e_food7,e_food8,e_food9)
% Obtiene los valores específicados de la señal
% Utilizado en pruebas dinámicas para encontrar valor máximo y mínimo,
%   para luego definir el max absoluto y su posición

mes = ((mes_i*freq_ad):(mes_f*freq_ad));
l_mes = length(mes);

mes_d_arq = d_arq(mes);
mes_d_central = d_central(mes);
mes_d_food = d_food(mes);

mes_i_arq = i_arq(mes);
mes_i_central = i_central(mes);
mes_i_food = i_food(mes);

mes_AY_arq = AY_arq(mes);
mes_AY_central = AY_central(mes);
mes_AY_food = AY_food(mes);

mes_AZ_arq = AZ_arq(mes);
mes_AZ_central = AZ_central(mes);
mes_AZ_food = AZ_food(mes);

mes_e_arq1 = e_arq1(mes);
mes_e_arq2 = e_arq2(mes);
mes_e_cent_arq1 = e_cent_arq1(mes);
mes_e_cent_arq2 = e_cent_arq2(mes);
mes_e_central1 = e_central1(mes);
mes_e_cent_food1 = e_cent_food1(mes);
mes_e_food1 = e_food1(mes);
mes_e_food2 = e_food2(mes);
mes_e_food3 = e_food3(mes);
mes_e_food4 = e_food4(mes);
mes_e_food5 = e_food5(mes);
mes_e_food6 = e_food6(mes);
mes_e_food7 = e_food7(mes);
mes_e_food8 = e_food8(mes);
mes_e_food9 = e_food9(mes);

gen_matriz = [mes_AY_arq, mes_AZ_arq, mes_AY_food, mes_AZ_food, mes_AZ_central, mes_AY_central,mes_d_food, mes_d_central, mes_d_arq,mes_i_arq, mes_i_food, mes_i_central,mes_e_arq1, mes_e_food1, mes_e_food7, mes_e_cent_food1, mes_e_food8, mes_e_food9, mes_e_cent_arq2, mes_e_food2, mes_e_food3, mes_e_food4, mes_e_arq2, mes_e_cent_arq1, mes_e_central1, mes_e_food5, mes_e_food6];

% gen_matriz = [AY_arq, AZ_arq, AY_food, AZ_food, AZ_central, AY_central,d_food, d_central, d_arq,i_arq, i_food, i_central,e_arq1, e_food1, e_food7, e_cent_food1, e_food8, e_food9, e_cent_arq2, e_food2, e_food3, e_food4, e_arq2, e_cent_arq1, e_central1, e_food5, e_food6];
[~, width_gen] = size(gen_matriz);
[max_mat, p_max] = max(gen_matriz);
[min_mat, p_min] = min(gen_matriz);

% Revisar valores máximos absolutos
abs_min = abs(min_mat);

abs_matriz = zeros(2,width_gen);

for i = 1:width_gen
    if max_mat(i) > abs_min(i)
        abs_matriz(1,i) = max_mat(i);
        abs_matriz(2,i) = p_max(i);
    elseif abs_min(i) > max_mat(i)
        abs_matriz(1,i) = min_mat(i);
        abs_matriz(2,i) = p_min(i);
    end
end

abs_matrizV = transpose(abs_matriz);

t_abs = table(abs_matrizV);
t_abs.Properties.VariableNames = {'Max en Pruebas - No. dato'};
t_abs.Properties.RowNames = {'BA3054Y_20A','BA3054Z_20A','BA3053Y_20A','BA3053Z_20A','BA3055Z_20A','BA3055Y_20A','LV219992_20A','LV219991_20A','LV219993_20A','ET1100_20A','ET1102_20A','ET1101_20A','B9210_22A','B8113_20B','B8107_20B','B9213_22A','B8110_20B','B8116_20B','B9211_22A','B8104_20B','B8108_20B','B8109_20B','B9209_22A','B9214_22A','B8111_20B','B8102_20B','B9212_22A'};

end
