# Ananta Gateway Control

Esta é uma aplicação web completa desenvolvida para fornecer controle em tempo real sobre o servidor do jogo Ananta.

## Visão Geral

O Ananta Gateway Control é uma aplicação web que permite enviar comandos em tempo real para o servidor do jogo. A aplicação foi construída com React, TypeScript, Ant Design e Umi/Max.js.

## Scripts Disponíveis

Este diretório contém vários scripts para gerenciar a aplicação:

- `run_gateway.cmd`: Inicia o servidor de desenvolvimento
- `build_gateway.cmd`: Cria uma build otimizada da aplicação
- `serve_gateway.cmd`: Serve a aplicação a partir dos arquivos buildados
- `clean_gateway.cmd`: Remove arquivos temporários e diretorios de build
- `status_gateway.cmd`: Verifica o status da instalação e arquivos
- `quick_start.cmd`: Inicia rapidamente o servidor de desenvolvimento
- `check_port.cmd`: Verifica se as portas 8000 e 8080 estão em uso
- `safe_start.cmd`: Inicia o servidor com verificação de portas
- `install_deps.cmd`: Instala as dependências globais e locais
- `setup_and_run.cmd`: Combina instalação de dependências e inicialização
- `diagnose.cmd`: Realiza verificação completa do ambiente
- `backup.cmd`: Cria um backup do estado atual da aplicação
- `help_gateway.cmd`: Mostra esta mensagem de ajuda

## Funcionalidades

A aplicação oferece diversas funcionalidades para controle do jogo:

- **Teletransporte**: Movimentação instantânea de personagens
- **Itens e Dinheiro**: Gestão de inventário e moedas
- **Veículos**: Invocação de diferentes tipos de veículos
- **Buffs e Efeitos**: Aplicação de buffs e modificadores
- **Armas**: Troca e gerenciamento de armas

## Execução

### Modo de Desenvolvimento

Execute `run_gateway.cmd` para iniciar o servidor de desenvolvimento. A aplicação estará disponível em `http://localhost:8000`.

Alternativamente, execute `quick_start.cmd` para uma inicialização mais rápida ou `safe_start.cmd` para uma inicialização com verificação de portas.

Para uma instalação completa e início automático, execute `setup_and_run.cmd`.

### Build para Produção

Execute `build_gateway.cmd` para criar uma build otimizada da aplicação. Os arquivos serão gerados no diretório `/dist`.

### Servir em Produção

Execute `serve_gateway.cmd` para servir a aplicação a partir dos arquivos buildados. A aplicação estará disponível em `http://localhost:8080`.

## Instalação de Dependências

Execute `install_deps.cmd` para instalar todas as dependências globais e locais necessárias para o funcionamento do gateway control.

## Diagnóstico

Execute `diagnose.cmd` para realizar uma verificação completa do ambiente e identificar possíveis problemas com soluções recomendadas.

## Backup

Execute `backup.cmd` para criar um backup do estado atual da aplicação, preservando arquivos importantes para recuperação futura.

## Limpeza de Arquivos

Execute `clean_gateway.cmd` para remover arquivos temporários, diretórios de build e limpar o cache do npm. Após a limpeza, você precisará executar `npm install` novamente.

## Verificação de Status

Execute `status_gateway.cmd` para verificar o status da instalação, versões de dependências e presença de arquivos essenciais.

## Inicialização Rápida

Execute `quick_start.cmd` para uma inicialização simplificada do servidor de desenvolvimento.

## Verificação de Portas

Execute `check_port.cmd` para verificar se as portas 8000 e 8080 estão em uso, o que pode ajudar a diagnosticar problemas de conexão.

## Inicialização Segura

Execute `safe_start.cmd` para iniciar o servidor com verificação prévia de portas e confirmação se a porta já estiver em uso.

## Instalação Completa e Início Automático

Execute `setup_and_run.cmd` para combinar a instalação de dependências com a inicialização do servidor em um único script.

## Integração com o Servidor

A aplicação se comunica com o servidor do jogo através de uma API REST na porta 9011:

- Comandos são enviados via requisições HTTP POST
- O servidor processa os comandos e os distribui para as conexões ativas
- Feedback é retornado em formato JSON

## Estrutura de Páginas

- **Home**: Página inicial com funções básicas
- **Comandos do Jogo**: Painel avançado com todos os comandos
- **Sobre**: Informações sobre a aplicação

## Tecnologias

- **Frontend**: React com TypeScript
- **UI Components**: Ant Design
- **Framework**: Umi/Max.js
- **Build Tool**: Webpack
- **API**: REST em JSON