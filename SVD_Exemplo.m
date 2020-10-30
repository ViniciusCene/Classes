%% LIMPA O AMBIENTE
clear all
close all
clc

%% NOTA��ES:
% A: Matriz a ser decomposta e invertida
% S: SIGMA - Matriz Diagonal com os Auto Valores (mesmo tamanho de A)
% s: Matriz Diagonal com as Valores Singulares (sqrt(S))
% U: Vetor Singular Esquerdo
% V: Vetor Singular Direito (Ortonormal ao U = Transposto em rela��o a U)
% Adagger = B = Matriz Pseudoinversa


%% DEFINE MATRIZ A
A = [1 2]

%% i) Utilize SVD para a decomposi��o da matriz A em [U, s, V]; 
% Calculando Componentes U, S e V:
% COMO A TEM TAMANHO 1x2, S TER� O MESMO TAMANHO
% Base da pseudoinversa que � uma matriz quadrada que possibilita as opera��es
% SVD(A) = U*S*V'

Base = A.*A'

% Sabemos que S ter� dimens�o 1x2 e que U V s�o bases ortonormais e matrizes quadradas
% Logo, para possibilitar U*S*V', U � 1x1 e V � 2x2
% O calculo de S � um problema de auto valor da Matriz Base, ent�o
% Cauculo de U e V � um prolema de Auto Vetor (substitui valores de S em M)

U = 1                           % Como U tem que ser ortonormal e � 1x1, U=1
[V, S] = eig(Base)              % Calcula Auto Valores e Vetores para A.A'

S_aux = [S(2,2), S(2,1);...     % Realinhando S em ordem decrescente
         S(1,2), S(1,1)]        
s = sqrt(S_aux)                 % Singular Value = Ra�z Quadrada(Auto Valor) 

V_aux = [V(:,2), V(:,1)]        % O que nos obriga a realinhar V tamb�m        
V = V_aux


%% Compare os resultados com a fun��o svd do Matlab;
% Temos ent�o nossa matriz A.*A' decomposta em [U, S, V], 
% conferindo coma fun��o do Malab, temos:

[U_, s_, V_] = svd(A)

% Notem que a pequena diferen�a num�rica � relacionada com quest�es
% num�ricas dos m�todos, sendo ambos os valores iguais na pr�tica.
Diff_U = U - U_
Diff_s = s - s_     
Diff_V = V - V_

% Reconstruindo A:
A_Matlab = U_*s_*V_'
A_SVD = U*s*V'

%% iii) Com as matrizes [U, s, V], calcule a pseudoinversa (dagger) de A;
% Sendo A = U*s*V; Adagger = V*([1./s(1) 0])'*U'
% OBS: O que fazemos aqui � obter a pseudo inversa de s, o que � obtido
%      invertendo cada valor de s ~= 0 e fazendo a transposta da matriz
Adagger_SVD = V*([1./s(1) 0])'*U'


%% iv) Compare o resultado com a fun��o pinv do Matlab;
% 10E-9 corresponde ao termo de relaxa��o utilizado pelo Matlab e refere-se
% ao # de valores singulares utilizados na aproxima��o da matriz.
Adagger_Matlab = pinv(A)
Adagger_Matlab = pinv(A, 10E-9)    


%% v) Confirme as identidades a seguir consideraando B = dagger:
% A*Adagger = Adagger*A = I
% A*Adagger*A = A
% Adagger*A*Adagger = Adagger
% (A*Adagger)' = A*Adagger
% (Adagger*A)' = Adagger*A

Adagger = Adagger_Matlab
A*Adagger                           % = I

A*Adagger*A                         % = A
A
Adagger*A*Adagger                   % = Adagger
Adagger

(A*Adagger)'                        % = A*Adagger
(Adagger*A)'                        % = Adagger*A


%% vi) Para uma entrada x no espa�o nulo (N(A)) de A, calcule Adagger*A*x:
% Aqui a combina��o de Autovalores e Autovetores mostra seu potencial
% Para descobrir os espa�os nulos, e portanto, a solu��o completa de A, 
% basta considerar os Valores Singulares, onde eles forem ZERO, o Autovetor
% representam os espa�os nulos da matriz. 
% De forma similar, todos os Autovetores correspondentes a valores 
% definidos positivos dos Autovalores representam o Espa�o de Colunas de A
% onde diversas solu��es triviais podem ser encontradas, dependendo do
% n�mero de Autovalores

% Considerando s:
s

% Percebe-se que s� h� um Autovalor definido positivo, como U � 1, o modelo
% � projetado por V, que tem como descritor do Espa�o Nulo a 2a Coluna:
V(:,2)                  % Simplificadamente [-2; 1]

% Portanto, para qualquer constante k multiplicada por V(:,2) deve levar a 
% um resultado no N(A). Abaixo alguns valores s�o testados:
x = [-2; 1]

for k=1:10
    N_A(:,k) = Adagger*A*x*(k-5);       % testa valores de -5 < k < 5
end

% Como esperado, todos os resultados encontram-se em N(A)

%% vii) Para um x no espa�o de colunas (C(A)) de A, calcule dagger*A*x:
% Como s tem dimens�o 2x2 e a 2a coluna � nula (representando o espa�o nulo)
% o descritor do Espa�o Couna encontra-se na 1a Coluna:
V(:,1)                  % Simplificadamente [1; 2]

% Portanto, qualquer constante k multiplicada por V(:,1) deve levar a 
% recupera��o do valor de x. Abaixo alguns valores s�o testados:
x = [1; 2]


for k=1:10
    N_C(:,k) = Adagger*A*x*(k-5);       % testa valores de -5 < k < 5
end

% Como esperado, todos os resultados s�o x escalonado proporcionalemnte.


% Reparem que esta � a utilidade da utiliza��o da pseudoinversa:
% 1) Quando a inversa existe ela � obtida pela opera��o que chega em x
% 2) Quando a inversa n�o existe ela pode ser aproximada em rela��o a x
%    atrav�s dos vetores em combina��o com os Valores Singulares.
