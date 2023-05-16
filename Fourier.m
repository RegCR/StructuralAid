function [NFFT,X,A_X,f] = Fourier(ND,Datos,fs)
% Función para aplicar transformada de Fourier a datos seleccionados

NFFT = 2^nextpow2(ND);
X = fft(Datos,NFFT);
A_X = abs(X);
f = fs/2*linspace(0,1,NFFT/2);
A_X = A_X(1:NFFT/2);

end

