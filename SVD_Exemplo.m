%% LIMPA O AMBIENTE
clear all
close all
clc

%% NOTAÇÕES:
% A: Matriz a ser decomposta e invertida
% S: SIGMA - Matriz Diagonal com os Auto Valores (mesmo tamanho de A)
% s: Matriz Diagonal com as Valores Singulares (sqrt(S))
% U: Vetor Singular Esquerdo
% V: Vetor Singular Direito (Ortonormal ao U = Transposto em relação a U)
% Adagger = B = Matriz Pseudoinversa


%% DEFINE MATRIZ A
A = [1 2]

%% i) Utilize SVD para a decomposição da matriz A em [U, s, V]; 
% Calculando Componentes U, S e V:
% COMO A TEM TAMANHO 1x2, S TERÁ O MESMO TAMANHO
% Base da pseudoinversa que é uma matriz quadrada que possibilita as operações
% SVD(A) = U*S*V'

Base = A.*A'

% Sabemos que S terá dimensão 1x2 e que U V são bases ortonormais e matrizes quadradas
% Logo, para possibilitar U*S*V', U é 1x1 e V é 2x2
% O calculo de S é um problema de auto valor da Matriz Base, então
% Cauculo de U e V é um prolema de Auto Vetor (substitui valores de S em M)

U = 1                           % Como U tem que ser ortonormal e é 1x1, U=1
[V, S] = eig(Base)              % Calcula Auto Valores e Vetores para A.A'

S_aux = [S(2,2), S(2,1);...     % Realinhando S em ordem decrescente
         S(1,2), S(1,1)]        
s = sqrt(S_aux)                 % Singular Value = Raíz Quadrada(Auto Valor) 

V_aux = [V(:,2), V(:,1)]        % O que nos obriga a realinhar V também        
V = V_aux


%% Compare os resultados com a função svd do Matlab;
% Temos então nossa matriz A.*A' decomposta em [U, S, V], 
% conferindo coma função do Malab, temos:

[U_, s_, V_] = svd(A)

% Notem que a pequena diferença numérica é relacionada com questões
% numéricas dos métodos, sendo ambos os valores iguais na prática.
Diff_U = U - U_
Diff_s = s - s_     
Diff_V = V - V_

% Reconstruindo A:
A_Matlab = U_*s_*V_'
A_SVD = U*s*V'

%% iii) Com as matrizes [U, s, V], calcule a pseudoinversa (dagger) de A;
% Sendo A = U*s*V; Adagger = V*([1./s(1) 0])'*U'
% OBS: O que fazemos aqui é obter a pseudo inversa de s, o que é obtido
%      invertendo cada valor de s ~= 0 e fazendo a transposta da matriz
Adagger_SVD = V*([1./s(1) 0])'*U'


%% iv) Compare o resultado com a função pinv do Matlab;
% 10E-9 corresponde ao termo de relaxação utilizado pelo Matlab e refere-se
% ao # de valores singulares utilizados na aproximação da matriz.
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


%% vi) Para uma entrada x no espaço nulo (N(A)) de A, calcule Adagger*A*x:
% Aqui a combinação de Autovalores e Autovetores mostra seu potencial
% Para descobrir os espaços nulos, e portanto, a solução completa de A, 
% basta considerar os Valores Singulares, onde eles forem ZERO, o Autovetor
% representam os espaços nulos da matriz. 
% De forma similar, todos os Autovetores correspondentes a valores 
% definidos positivos dos Autovalores representam o Espaço de Colunas de A
% onde diversas soluções triviais podem ser encontradas, dependendo do
% número de Autovalores

% Considerando s:
s

% Percebe-se que só há um Autovalor definido positivo, como U é 1, o modelo
% é projetado por V, que tem como descritor do Espaço Nulo a 2a Coluna:
V(:,2)                  % Simplificadamente [-2; 1]

% Portanto, para qualquer constante k multiplicada por V(:,2) deve levar a 
% um resultado no N(A). Abaixo alguns valores são testados:
x = [-2; 1]

for k=1:10
    N_A(:,k) = Adagger*A*x*(k-5);       % testa valores de -5 < k < 5
end

% Como esperado, todos os resultados encontram-se em N(A)

%% vii) Para um x no espaço de colunas (C(A)) de A, calcule dagger*A*x:
% Como s tem dimensão 2x2 e a 2a coluna é nula (representando o espaço nulo)
% o descritor do Espaço Couna encontra-se na 1a Coluna:
V(:,1)                  % Simplificadamente [1; 2]

% Portanto, qualquer constante k multiplicada por V(:,1) deve levar a 
% recuperação do valor de x. Abaixo alguns valores são testados:
x = [1; 2]


for k=1:10
    N_C(:,k) = Adagger*A*x*(k-5);       % testa valores de -5 < k < 5
end

% Como esperado, todos os resultados são x escalonado proporcionalemnte.


% Reparem que esta é a utilidade da utilização da pseudoinversa:
% 1) Quando a inversa existe ela é obtida pela operação que chega em x
% 2) Quando a inversa não existe ela pode ser aproximada em relação a x
%    através dos vetores em combinação com os Valores Singulares.
