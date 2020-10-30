clear all
close all
clc 

%% Leitura, Pre-Processamento e Alocação de Variáveis

% Lê Imagem:
% imagem = imread('peppers_RGB_tiled.tif');
imagem = imread('dog.jpeg');

% Calcula as dimensões imgVal imagem
[linhas,colunas,d] = size(imagem); 
    
% Calcula limite para não-compressão e converte em double o valor imgVals cores    
% k = rank da Matrix SIGMA
% k representa o valor máximo do rank (imagem não comprimida)
% Quanquer número abaixo deste limite vai descartar Valores Singulares e 
% portanto, comprimir a imagem
kmax=floor((linhas*colunas)/(linhas+colunas+1));  
imgVal=double(imagem); 

% Inicializa Variáveis Para Melhor Desempenho
U=zeros(linhas,linhas);
S=zeros(linhas,colunas);
V=zeros(colunas,colunas);
e=zeros(kmax,d);
cr=zeros(kmax,1);
rmse=zeros(kmax,d); 


%% Calcula SVD para Cada Componente de Cor
for i=1:d 
    [U(:,:,i),S(:,:,i),V(:,:,i)]=svd(imgVal(:,:,i)); 
end


%% Gera Imagens Para Diferentes #k, Proporcionalmente Escolhidos (10:10:100)
old_dir = cd;

% percentuais de 5, 10, 15, .., 95, 100% do rank (k) utilizado: 
percentual_compressao_interesse = floor([1, (0.05:0.05:1)*kmax]); 

for k=1:kmax 
    ca = zeros(linhas,colunas,d); 
    percentual_compressao(k) = linhas*colunas/(k*(linhas+colunas+1)); 
    
    % Erro de norma L2 consiste em comparar os s, a partir do 2º [S(k+1,k+1,i)], 
    % com o dominante [s(1,1)]
    % Já o RMSE é a diferença entre a matriz reduzida e a original
    % e é calculado a cada acréscimo de 
    for i=1:d 
        cai = zeros(linhas,colunas,d); 
        [ca(:,:,i), cai(:,:,i)] = deal(U(:,1:k,i)*S(1:k,1:k,i)*V(:,1:k,i)'); 
        e(k,i) = S(k+1,k+1,i)/S(1,1,i);     
        rmse(k,i) = sqrt(sum(sum(((imgVal(:,:,i)-ca(:,:,i)).^2)))/(linhas*colunas)); 
        % Descomentar linha #55 para salvar os diferentes componentes RGB
        % imwrite(uint8(cai), sprintf('k=%d.jpg',k,i)); 
    end
    
    % Salva imagens no intervalo desejado
    if (sum(percentual_compressao_interesse == k) > 0)
     %if k < 50
        sprintf('Rank = %d',k) 
        cd(strcat(old_dir, '\Imagens_de_Saida'));
        imwrite(uint8(ca), sprintf('k=%d.jpg', k)); 
        cd(old_dir);
    end
end


%% Plota Erro L2
figure 
subplot(3,1,1)
p=plot(1:kmax,e,'MarkerEdgeColor','r','MarkerEdgeColor','g'); 
set(p,{'color'},{'red';'green';'blue'}) 
xlabel('Número Valores Singulares (Rank k)');  
ylabel('Erro L_2'); 
xlim([1 kmax]) 
legend('Red','Green','Blue') 
grid on 
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')


%% Plota RMSE
subplot(3,1,2)
p=plot(1:kmax,rmse,'MarkerEdgeColor','r','MarkerEdgeColor','g'); 
set(p,{'color'},{'red';'green';'blue'}) 
xlabel('Número Valores Singulares (Rank k)'); 
ylabel('RMSE');
xlim([1 kmax]) 
legend('Red','Green','Blue') 
grid on 
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')


%% Plota Percentual de Compressão
subplot(3,1,3)
plot(1:kmax,percentual_compressao); 
xlabel('Número Valores Singulares (Rank k)'); 
ylabel('Percentual Compressao (%)'); 
xlim([1 kmax]) 
grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gcf,'color','w');


%% ZOOM k = 0-100
% Plota Erro L2
new_lim = 50;
figure 
subplot(3,1,1)
p=plot(1:new_lim,e(1:new_lim,:),'MarkerEdgeColor','r','MarkerEdgeColor','g'); 
set(p,{'color'},{'red';'green';'blue'}) 
xlabel('Número Valores Singulares (Rank k)');  
ylabel('Erro L_2'); 
xlim([1 new_lim]) 
legend('Red','Green','Blue') 
grid on 
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')


% Plota RMSE
subplot(3,1,2)
p=plot(1:new_lim,rmse(1:new_lim,:),'MarkerEdgeColor','r','MarkerEdgeColor','g'); 
set(p,{'color'},{'red';'green';'blue'}) 
xlabel('Número Valores Singulares (Rank k)'); 
ylabel('RMSE');
xlim([1 new_lim]) 
legend('Red','Green','Blue') 
grid on 
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')


% Plota Percentual de Compressão
subplot(3,1,3)
plot(1:new_lim,percentual_compressao(:,1:new_lim)); 
xlabel('Número Valores Singulares (Rank k)'); 
ylabel('Percentual Compressao (%)'); 
xlim([1 new_lim]) 
grid on
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')
set(gcf,'color','w');