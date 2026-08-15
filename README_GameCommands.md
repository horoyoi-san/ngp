# Ananta Gateway Control - Comandos do Jogo

Este documento descreve como utilizar o painel avançado de comandos do jogo implementado no Ananta Gateway Control.

## Visão Geral

O Ananta Gateway Control agora inclui um painel avançado que permite enviar diversos comandos em tempo real para o servidor do jogo. Estes comandos são baseados nos IDs encontrados no arquivo `MethodId.cs` do servidor.

## Separação de Portas

Para evitar conflitos, os diferentes componentes do sistema utilizam portas distintas:

- **Servidor do Jogo**: Portas 5200, 5201, 5202 (conexões de clientes) e porta 9011 (comandos do gateway control)
- **Gateway Control**: Porta 8000 (interface web)
- **Proxy**: Portas conforme configuração específica

Consulte o arquivo `PORTS_INFO.md` para detalhes completos sobre a alocação de portas.

## Funcionalidades Disponíveis

### 1. Teletransporte
- Permite teletransportar o personagem para coordenadas específicas no mapa
- Utiliza o método `TELEPORT` (ID: 62541429)

### 2. Gerenciamento de Itens e Dinheiro
- Adicionar itens ao inventário
- Adicionar diferentes tipos de moedas/dinheiro
- Utiliza os métodos `ADD_ITEM` (ID: 62681822) e `ADD_MONEY` (ID: 62375638)

### 3. Invocação de Veículos
- Invocar diversos tipos de veículos no jogo
- Especificar localização e configurações do veículo
- Utiliza o método `ASK_SUMMON_VEHICLE` (ID: 67928941)

### 4. Gerenciamento de Buffs
- Aplicar buffs e efeitos especiais aos personagens
- Utiliza o método `GM_ADD_BUFF` (ID: 62622667)

### 5. Gerenciamento de Armas
- Trocar armas em tempo real
- Utiliza o método `SYNC_SPIRIT_SWITCH_WEAPON_ACTION` (ID: 68753590)

## Como Usar

### Pré-requisitos
1. Certifique-se de que o servidor do jogo está em execução
2. O servidor deve estar escutando na porta 9011 para comandos do gateway control

### Acessando o Painel
1. Inicie o Ananta Gateway Control
2. Acesse a página principal em `http://localhost:8000`
3. Clique no link "Acesse o Painel Avançado de Comandos do Jogo"

### Enviando Comandos
1. Selecione a aba correspondente ao tipo de comando desejado
2. Preencha os parâmetros necessários
3. Clique no botão para executar o comando

## Considerações Importantes

- Alguns comandos podem exigir privilégios especiais
- Nem todos os comandos produzem efeitos visíveis imediatos
- O uso indevido pode afetar a estabilidade do jogo
- Os IDs dos métodos são baseados no arquivo `MethodId.cs` do servidor

## Desenvolvimento

O sistema foi implementado com:
- Frontend: React com Ant Design (rodando na porta 8000)
- Backend: C# com HttpListener (recebendo comandos na porta 9011)
- Comunicação: API REST em JSON

## Scripts de Inicialização

- `start_gateway_control.cmd`: Inicia apenas o gateway control
- `setup_and_start_all_as_admin.cmd`: Inicia todos os componentes do sistema com separação adequada de portas

## Notas sobre Configuração

- O gateway control foi configurado para rodar na porta 8000
- A configuração do servidor foi ajustada para evitar conflitos de porta
- Os avisos de dependência durante a instalação do npm não afetam o funcionamento do sistema