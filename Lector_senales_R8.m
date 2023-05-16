function [d_arq,d_central,d_food,i_arq,i_central,i_food,AY_arq,AY_central,AY_food,AZ_arq,AZ_central,AZ_food,e_arq1,e_arq2,e_cent_arq1,e_cent_arq2,e_central1,e_cent_food1,e_food1,e_food2,e_food3,e_food4,e_food5,e_food6,e_food7,e_food8,e_food9] = Lector_senales_R8(Data_val,vec_tiempo)
% Lee el archivo de señales ya importado y obtiene las gráficas generales
%   para los 4 tipos de sensores durante la prueba estática R8 (Únicamente)

% ----------Displacement---------------- (Convertir a mm)
d_arq = (Data_val(:,28))*25.4;
d_central = (Data_val(:,12))*25.4;
d_food = (Data_val(:,21))*25.4;

% Gráfico Prueba completa
figure('Name','Comportamiento pruebas')

subplot(3,2,1)
plot(vec_tiempo,d_arq,'color','#5b802a')
set(gca,'Color','#2b3436')

hold on
grid on
plot(vec_tiempo,d_central,'color','#de5a21')
plot(vec_tiempo,d_food,'color','#69c0d1')

legend('Arq','Central','Food','Color','w','Location','eastoutside')
title('LVDT') 
xlabel('Tiempo (s)')
ylabel('Desplazamiento (mm)')



% -------------Incline-----------------
i_arq = Data_val(:,2);
i_central = Data_val(:,17);
i_food = Data_val(:,15); % Se toma como perdido

% Gráfico Prueba completa
subplot(3,2,2)
plot(vec_tiempo,i_arq,'color','#5b802a')
set(gca,'Color','#2b3436')
hold on
grid on
plot(vec_tiempo,i_central,'color','#de5a21')
% plot(vec_tiempo,i_food,'color','#69c0d1')

legend('Arq','Central','Color','w','Location','eastoutside')
title('Inclinómetro') 
xlabel('Tiempo (s)') 
ylabel('Inclinación (grados)')


% ----------------Accelerometer----------------
% Acelerometros dirección Y
AY_arq = Data_val(:,3); % 3054 
AY_central = Data_val(:,27); % 3055, se toma como perdido
AY_food = Data_val(:,13); % 3053 

% Acelerometros dirección Z
AZ_arq = Data_val(:,4); % 3054, se toma como perdido
AZ_central = Data_val(:,26); % 3055, se toma como perdido
AZ_food = Data_val(:,14); % 3053

% Gráfico
% Acelerómetros en Y
subplot(3,2,3)
plot(vec_tiempo, AY_arq,'color','#5b802a')
set(gca,'Color','#2b3436')
hold on
grid on
% plot(vec_tiempo,AY_central,'color','#de5a21')
plot(vec_tiempo,AY_food,'color','#69c0d1')

title('Acelerómetros [Y]') %Titulo de Grafica
xlabel('Tiempo (s)') %Eje x
ylabel('G(s)') %Eje 
legend('Arq','Food','Color','w','Location','eastoutside')

% Acelerómetros en Z
subplot(3,2,4)
% plot(vec_tiempo, AZ_arq,'color','#5b802a')

% plot(vec_tiempo,AZ_central,'color','#de5a21')
plot(vec_tiempo,AZ_food,'color','#69c0d1')
set(gca,'Color','#2b3436')
hold on
grid on

title('Acelerómetros [Z]') 
legend('Food','Color','w','Location','eastoutside')
xlabel('Tiempo (s)')
ylabel('G(s)')

% -----------Strain-------------
e_arq1 = Data_val(:,1); % Más cercano a edificio arq
e_arq2 = Data_val(:,9); 

e_cent_arq1 = Data_val(:,10);
e_cent_arq2 = Data_val(:,25); %B9211_22A

e_central1 = Data_val(:,11);

e_cent_food1 = Data_val(:,20);

e_food1 = Data_val(:,5);
e_food2 = Data_val(:,6);
e_food3 = Data_val(:,7);
e_food4 = Data_val(:,8);
e_food5 = Data_val(:,16);
e_food6 = Data_val(:,18);
e_food7 = Data_val(:,19);   % B8107_20B
e_food8 = Data_val(:,22);
e_food9 = Data_val(:,23);

% Gráficos
subplot(3,2,[5,6])
p1 = plot(vec_tiempo, e_arq1,'r');
set(gca,'Color','#2b3436')
hold on
grid on
plot(vec_tiempo, e_arq2,'r')
p2 = plot(vec_tiempo, e_cent_arq1,'m');
plot(vec_tiempo, e_cent_arq2,'m')
p3 = plot(vec_tiempo, e_central1,'g');
p4 = plot(vec_tiempo, e_cent_food1,'color','#77AC30');
p5 = plot(vec_tiempo, e_food1,'b');
plot(vec_tiempo, e_food2,'b')
plot(vec_tiempo, e_food3,'b')
plot(vec_tiempo, e_food4,'b')
plot(vec_tiempo, e_food5,'b')
plot(vec_tiempo, e_food6,'b')
plot(vec_tiempo, e_food7,'b')
plot(vec_tiempo, e_food8,'b')
plot(vec_tiempo, e_food9,'b')

legend([p1 p2 p3 p4 p5],{'Arq','Cent - Arq','Central','Cent - Food','Food'},'Color','w','Location','eastoutside')
title('Extensómetros') 
xlabel('Tiempo (s)')
ylabel('ue (Microdeformaciones)')

end
