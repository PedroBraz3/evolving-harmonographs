# Evolução Automática de Harmonógrafos

Este módulo demonstra a evolução automática de desenhos de harmonógrafos usando uma função de aptidão (fitness) que avalia os indivíduos com base na sua semelhança visual com uma imagem-alvo predefinida. O sistema utiliza indivíduos baseados na SuperFórmula, compostos por múltiplas curvas paramétricas que evoluem para corresponder à forma-alvo.


## Principais Funcionalidades

- **Avaliação Automática de Fitness**: Utiliza a classe `EvaluatorA` para comparar os fenótipos renderizados com imagens-alvo  
- **Indivíduos SuperFórmula**: Cada indivíduo contém múltiplos componentes da SuperFórmula  
- **Métricas de Avaliação Avançadas**: Combina RMSE ponderado e sobreposição binária com penalização para pixels extra  
- **Elitismo e Seleção por Roleta**: Preserva os melhores indivíduos e usa seleção proporcional à fitness  
- **Cruzamento Flexível**: OnePointFlexibleCrossover com seleção de direção para frente/atrás  
- **Mutação Controlada**: Taxas de mutação específicas por parâmetro com restrições de intervalo válidas  

## Arquitetura

### Classes Principais

- **`Individual`**: Representa um harmonógrafo com múltiplos componentes da SuperFórmula  
- **`PopulationInd`**: Gere a evolução da população com avaliação automática de fitness  
- **`SuperFormula`**: Implementa a geração de curvas paramétricas usando a equação da SuperFórmula  
- **`EvaluatorA`**: Fornece cálculo automático de fitness com base na semelhança com a imagem-alvo  

### Processo de Evolução

1. **Inicialização**: Cria uma população aleatória e avalia automaticamente a fitness  
2. **Seleção**: Usa seleção por roleta baseada nos valores de fitness  
3. **Cruzamento**: OnePointFlexibleCrossover com direção configurável  
4. **Mutação**: Mutação controlada de parâmetros dentro de intervalos válidos  
5. **Elitismo**: Preserva os melhores indivíduos entre gerações  
6. **Avaliação**: Cálculo automático de fitness usando RMSE ponderado e sobreposição binária  

## Parâmetros

- **Tamanho da População**: 50 indivíduos  
- **Tamanho da Elite**: 2 (melhores indivíduos preservados)  
- **Taxa de Cruzamento**: 0.5 (50% de probabilidade de cruzamento)  
- **Taxa de Mutação**: 0.3 (30% de probabilidade de mutação do indivíduo)  
- **Taxa de Mutação do Gene**: 1.0 (100% de probabilidade de mutação de cada gene)  
- **Máx. Gerações**: 2000  
- **Resolução**: 256x256 pixels para renderização do fenótipo  

## Controlo

Os utilizadores podem interagir com o programa usando os seguintes controlos:

- Pressionar `p` para alternar entre modos de visualização de fenótipo e genótipo  
- Pressionar `f` para alternar a visibilidade dos valores de fitness  
- Pressionar `e` para exportar o melhor indivíduo para ficheiro (formatos PNG, PDF, TXT)  

## Avaliação de Fitness

A classe `EvaluatorA` implementa uma função de fitness sofisticada que:

1. **RMSE Ponderado**: Compara o brilho dos pixels com maior peso para pixels mais escuros da imagem-alvo  
2. **Sobreposição Binária**: Mede a semelhança da forma com penalização para pixels extra  
3. **Pontuação Combinada**: `(1 - rmse) * overlap` para o valor final de fitness  

## Funcionalidade de Exportação

Os indivíduos podem ser exportados em múltiplos formatos:  
- **PNG**: Imagem raster de alta resolução (2000x2000)  
- **PDF**: Formato vetorial para gráficos escaláveis  
- **TXT**: Valores de parâmetros para reprodução  


