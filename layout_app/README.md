## Respostas Conceituais

### 1. Diferença de Arquiteturas: Nativo x Cross-Platform (Flutter)
No desenvolvimento **Nativo**, o app é escrito na linguagem e no SDK específicos de cada plataforma 
(Kotlin/Java + Android SDK para Android, Swift/Objective-C + UIKit/SwiftUI para iOS). Isso dá acesso total 
aos recursos da plataforma e melhor performance, mas exige manter dois códigos-fonte separados (um para 
cada sistema).

No **Cross-Platform/Híbrido**, como o Flutter, escreve-se um único código-fonte (em Dart) que é compilado 
para rodar em várias plataformas (Android, iOS, Web, Desktop). O Flutter não usa os componentes nativos 
da tela — ele desenha sua própria interface (widgets) diretamente através do seu motor gráfico (engine), 
o que garante visual consistente entre plataformas e reduz tempo/custo de desenvolvimento, ao custo de 
uma camada extra entre o código e o sistema operacional.

### 2. StatelessWidget x StatefulWidget
- **StatelessWidget**: é um widget imutável — depois de construído, seus dados/propriedades não mudam. 
  Ele é reconstruído apenas se os dados que vêm de fora (do widget pai) mudarem. 
  Exemplo de uso: um ícone, um texto fixo, um logotipo, ou um card que só exibe informações que não 
  mudam durante a vida daquele widget (ex: um `Text` com um título fixo).
  
- **StatefulWidget**: é um widget que possui um objeto de estado (`State`) associado, que pode mudar 
  durante o tempo de vida do widget, fazendo a interface se redesenhar quando isso acontece. 
  Exemplo de uso: um contador que incrementa ao clicar em um botão, um formulário com campos que o 
  usuário preenche, um checkbox que alterna entre marcado/desmarcado.

### 3. O que acontece quando chamamos setState()?
Quando `setState()` é chamado dentro de um StatefulWidget, o Flutter marca aquele widget como "sujo" 
(dirty) e agenda uma nova chamada ao método `build()` daquele widget. Ou seja, o framework reconstrói 
a árvore de widgets daquele trecho da tela com os novos valores das variáveis alteradas dentro do 
`setState()`, atualizando visualmente apenas o que mudou (o Flutter compara a árvore antiga com a nova 
e aplica só as diferenças na tela, de forma eficiente).
