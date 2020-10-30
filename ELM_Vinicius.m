function [TrainingAccuracy, TestingAccuracy, labelELM, argMaxTreino, argMaxTeste] = ELM_Vinicius(Treino, Teste, funcaoELM, numHN, kernel, Regulariza, C)
                                                                                    

%% MACROS PARA A UTILIZAÇÃO DO ELM (funcaoELM)
REGRESSION=0;
CLASSIFIER=1;

%% LÊ DADOS RELATIVOS AO TREINO
labelTreino=Treino(:,1)';
dadosTreino=Treino(:,2:size(Treino,2))';
clear Treino;                                  

%% LÊ DADOS RELATIVOS AO TESTE
labelTeste=Teste(:,1)';
dadosTeste=Teste(:,2:size(Teste,2))';
clear Teste;                                    

%% AUTO-DEFINIÇÃO DOS HIPERPARÂMETROS DO MODELO BASEADO NO #HN
numAmostrasTR=size(dadosTreino,2);
numAmostrasTST=size(dadosTeste,2);
NumberofInputNeurons=size(dadosTeste,1);

%% PARSING INICIAL ADICIONAL SE A FUNÇÃO DE CLASSIFICAÇÃO FOR ESCOOLHIDA
% Atribui valores para os labels no intervalo [-1, 1]
if funcaoELM~=REGRESSION
    
    %%%%%%%%%%%% Preprocessing the data of classification
    classes = unique([labelTreino, labelTeste]);
    numClasses = length(classes);                         
    neoronsSaida = numClasses;
    matrizTreino = zeros(numClasses, length(dadosTreino));
    matrizTeste = zeros(numClasses, length(dadosTreino));
    
    for Classe=1:numClasses
        matrizTreino(Classe, find(labelTreino == Classe)) = 1;
    end    
    matrizTreino=matrizTreino*2-1;
    
    for Classe=1:numClasses
        matrizTeste(Classe, find(labelTeste == Classe)) = 1;
    end    
    matrizTeste=matrizTeste*2-1;

end                                                 


%% GERA ALEATORIAMENTE OS PESOS PARA A CAMADA DE ENTRADA E O BIAS DOS HN
% Cria pesos de entrada no intervalo [-1; +1]
InputWeight = rand(numHN, NumberofInputNeurons)*2-1;

% Cria pesos de entrada no intervalo [-1; +1]
BiasofHiddenNeurons=rand(numHN,1);                % Cria bias para 1a Coluna
ind=ones(1,numAmostrasTR);
BiasMatrix=BiasofHiddenNeurons(:,ind); 
tempH=(InputWeight*dadosTreino)+BiasMatrix;
clear dadosTreino;                                           


%% APLICA O KERNEL EM H PARA O CÁLCULO DA PSEUDOINVERSA
switch lower(kernel)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H = 1 ./ (1 + exp(-tempH));
    case {'sin','sine'}
        %%%%%%%% Sine
        H = sin(tempH);    
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H = double(hardlim(tempH));
    case {'tribas'}
        %%%%%%%% Triangular basis function
        H = tribas(tempH);
    case {'radbas'}
        %%%%%%%% Radial basis function
        H = radbas(tempH);
        %%%%%%%% More activation functions can be added here                
end
clear tempH;                                        %   Release the temparary array for calculation of hidden neuron output matrix H

%% CÁLCULO DOS PESOS DE SAÍDA (PSEUDOINVERSA / RIDGE-REGRESSION):

if Regulariza
    % RIDGE-REGRESSION (L2 NORM) FORMA #1
      OutputWeight=inv(eye(size(H,1))/C+H * H') * H * matrizTreino';  
    % RIDGE-REGRESSION (L2 NORM) FORMA #2
      %OutputWeight=(eye(size(H,1))/C+H * H') \ H * matrizTreino';     
else
    % PSEUDOINVERSA DE MOORE-PENROSE
      OutputWeight = pinv(H') * matrizTreino';                         
end


%% CÃLCULO DO arg max E RMSE DO TREINO
argMaxTreino = (H' * OutputWeight)';    

if funcaoELM == REGRESSION
    TrainingAccuracy = sqrt(mse(labelTreino - argMaxTreino))               %   Calculate training accuracy (RMSE) for regression case
end
clear H;


%% GERA MATRIZ H PARA OS DADOS DE TESTE
ind = ones(1,numAmostrasTST);
BiasMatrix = BiasofHiddenNeurons(:,ind); 

tempH = (InputWeight*dadosTeste) + BiasMatrix;
clear dadosTeste

switch lower(kernel)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H_test = 1 ./ (1 + exp(-tempH));
    case {'sin','sine'}
        %%%%%%%% Sine
        H_test = sin(tempH);        
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H_test = hardlim(tempH);        
    case {'tribas'}
        %%%%%%%% Triangular basis function
        H_test = tribas(tempH);        
    case {'radbas'}
        %%%%%%%% Radial basis function
        H_test = radbas(tempH);        
        %%%%%%%% More activation functions can be added here        
end


%% CÃLCULO DO arg max E RMSE DO TESTE
argMaxTeste = (H_test' * OutputWeight)';                % TY: the actual output of the testing data

if funcaoELM == REGRESSION
    TestingAccuracy=sqrt(mse(labelTeste - argMaxTeste)) % Calculate testing accuracy (RMSE) for regression case
end

if funcaoELM == CLASSIFIER
%%%%%%%%%% Calculate training & testing classification accuracy
    erroClassificacaoTreino=0;
    erroClassificacaoTeste=0;

    for i = 1 : size(labelTreino, 2)
       % [x, label_index_expected]=max(labelTreino(:,i));
        [x, label_index_actual]=max(argMaxTreino(:,i));
        if label_index_actual~=labelTreino(i)
            erroClassificacaoTreino = erroClassificacaoTreino+1;
        end
    end
    TrainingAccuracy = (1-erroClassificacaoTreino/size(labelTreino,2))*100
    
    for i = 1 : size(argMaxTeste, 2)
        %[x, label_index_expected]=max(argMaxTeste(:,i));
        [x, label_index_actual]=max(argMaxTeste(:,i));
        
        labelELM(i,1) = label_index_actual;
        
        if label_index_actual~=labelTeste(i)
            erroClassificacaoTeste=erroClassificacaoTeste+1;
        end
    end
    TestingAccuracy = (1-erroClassificacaoTeste/size(argMaxTeste,2))*100  
end

