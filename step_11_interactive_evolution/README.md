# Evolução Interativa de Harmonógrafos

Este módulo demonstra a utilização de um **Algoritmo Genético Interativo** para evoluir desenhos da SuperFórmula, onde os utilizadores atribuem manualmente a **aptidão** (fitness) aos desenhos que estão a evoluir. Esta abordagem permite uma avaliação estética subjetiva e a exploração criativa do espaço de design.  

## Principais Funcionalidades

- **Evolução Guiada pelo Utilizador**: Atribuição manual de fitness através da interação com o rato e teclado  
- **Feedback em Tempo Real**: Destaque visual dos indivíduos avaliados  
- **Avaliação Flexível**: Múltiplas formas de atribuir valores de fitness (clique, setas do teclado)  
- **Exploração Criativa**: Sem restrições de alvo, permitindo uma evolução estética aberta  
- **Capacidades de Exportação**: Guardar indivíduos interessantes em múltiplos formatos  

## Arquitetura

### Classes Principais

- **`Individual`**: Representa um array com múltiplos componentes da SuperFórmula  
- **`PopulationInd`**: Gere a evolução da população com atribuição de fitness guiada pelo utilizador  
- **`SuperFormula`**: Implementa a geração de curvas paramétricas usando a equação da superfórmula  
- **Interface Interativa**: Controlo por rato e teclado para atribuição de fitness  

### Processo de Evolução

1. **Inicialização**: Cria uma população aleatória com valores de fitness por defeito  
2. **Avaliação pelo Utilizador**: Atribuição manual de fitness através da interação  
3. **Seleção**: Seleção por roleta baseada na fitness atribuída pelo utilizador  
4. **Cruzamento**: OnePointFlexibleCrossover com direção configurável  
5. **Mutação**: Mutação controlada de parâmetros dentro de intervalos válidos  
6. **Geração**: Criação de nova população com base nas preferências do utilizador  

## Parâmetros

- **Tamanho da População**: 10 indivíduos (menor para avaliação mais manejável)  
- **Tamanho da Elite**: 0 (desativado para avaliação interativa)  
- **Taxa de Cruzamento**: 0.5 (50% de probabilidade de cruzamento)  
- **Taxa de Mutação**: 0.3 (30% de probabilidade de mutação do indivíduo)  
- **Taxa de Mutação do Gene**: 0.5 (50% de probabilidade de mutação de cada gene)  
- **Resolução**: 256x256 pixels para renderização do fenótipo  

## Controlo

Os utilizadores podem interagir com o programa usando os seguintes controlos:  

### Interação com o Rato
- **Clique num indivíduo**: Alterna a fitness entre alta (10) e baixa (1)  
- **Passar o cursor**: Destaque visual do indivíduo sob o cursor  

### Controlo por Teclado
- **Setas** (enquanto o cursor estiver sobre o indivíduo):  
  - `↑`: Aumentar fitness (máx. 10)  
  - `↓`: Diminuir fitness (mín. 1)  
  - `→`: Definir fitness mínima (1)  
  - `←`: Definir fitness nula (0)  
- **`Enter` ou `Espaço`**: Evoluir para a próxima geração  
- **`r`**: Reiniciar a população com novos indivíduos aleatórios  
- **`e`**: Exportar o indivíduo atualmente sob o cursor  

## Feedback Visual
 
- **Exibição da Fitness**: Valores numéricos de fitness mostrados abaixo de cada indivíduo  
- **Instruções de Controlo**: Texto de ajuda no ecrã na parte inferior da janela  

## Funcionalidade de Exportação

Os indivíduos podem ser exportados em múltiplos formatos:  
- **PNG**: Imagem raster de alta resolução (2000x2000)  
- **PDF**: Formato vectorial para gráficos escaláveis  
- **TXT**: Valores de parâmetros para reprodução  

## Benefícios da Evolução Interativa

- **Avaliação Subjetiva**: Os utilizadores podem avaliar com base em preferências estéticas  
- **Descoberta Criativa**: Sem restrições de alvo, permitindo resultados inesperados  
- **Controlo em Tempo Real**: Feedback e ajustes imediatos  
- **Exploração**: Os utilizadores podem guiar a evolução em direções interessantes  

## Desafios

- **Fadiga do Utilizador**: A avaliação manual pode tornar-se cansativa com populações grandes  
- **Consistência**: A avaliação do utilizador pode variar ao longo do tempo  
- **Escalabilidade**: Limitado a populações pequenas devido ao overhead de avaliação  
- **Abordagens Híbridas**: Combinar métodos automáticos e interativos de avaliação  
- **Interface de Utilizador**: Melhorar o design da interação para melhor experiência  

