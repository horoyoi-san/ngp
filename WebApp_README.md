# Ananta Gateway Control - Aplicação Web

Este documento descreve a aplicação web completa do Ananta Gateway Control.

## Visão Geral

O Ananta Gateway Control é uma aplicação web completa desenvolvida para fornecer controle em tempo real sobre o servidor do jogo Ananta. A aplicação foi construída com tecnologias modernas e oferece uma interface amigável para gerenciar milhares de comandos do jogo.

## Estrutura da Aplicação

A aplicação web segue uma arquitetura baseada em páginas com um layout consistente:

- **Layout Principal**: Barra de navegação superior com logo, menu e rodapé
- **Página Inicial**: Apresentação da aplicação e função de spawn rápida
- **Painel de Comandos do Jogo**: Interface avançada com múltiplas abas para diferentes tipos de comandos
- **Página Sobre**: Informações sobre a aplicação e suas funcionalidades

## Funcionalidades Disponíveis

### 1. Home Page
- Apresentação da aplicação
- Formulário rápido para invocação de veículos
- Links para as demais funcionalidades

### 2. Comandos do Jogo
- **Teletransporte**: Movimentação instantânea de personagens
- **Itens e Dinheiro**: Gestão de inventário e moedas
- **Veículos**: Invocação de diferentes tipos de veículos
- **Buffs e Efeitos**: Aplicação de buffs e modificadores
- **Armas**: Troca e gerenciamento de armas

### 3. Sobre
- Informações sobre a aplicação
- Tecnologias utilizadas
- Detalhes de integração
- Informações de desenvolvimento

## Tecnologias Utilizadas

- **Frontend**: React com TypeScript
- **UI Components**: Ant Design
- **Framework**: Umi/Max.js
- **Backend**: C# com HttpListener
- **Comunicação**: API REST em JSON

## Navegação

A aplicação oferece navegação consistente através de uma barra de menu superior:
- Home: Página inicial com funções básicas
- Comandos do Jogo: Painel avançado com todos os comandos
- Sobre: Informações sobre a aplicação

## Integração com o Servidor

A aplicação se comunica com o servidor do jogo através de uma API REST na porta 9011:
- Comandos são enviados via requisições HTTP POST
- O servidor processa os comandos e os distribui para as conexões ativas
- Feedback é retornado em formato JSON

## Execução

Para executar a aplicação web:

1. Certifique-se de que o servidor do jogo está em execução
2. Execute o script `start_gateway_control.cmd`
3. Acesse `http://localhost:8000` no seu navegador

## Desenvolvimento

A aplicação foi projetada para facilitar a adição de novas funcionalidades:
- Estrutura modular baseada em páginas
- Componentes reutilizáveis
- Código bem documentado
- Separação clara entre frontend e backend