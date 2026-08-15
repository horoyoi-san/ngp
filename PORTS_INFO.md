# Informações sobre Portas - AnantaTestGameServer

Este documento descreve a alocação de portas utilizadas pelos diferentes componentes do sistema AnantaTestGameServer para evitar conflitos.

## Alocação de Portas

### Servidor do Jogo (`AnantaTestGameServer`)
- **Portas de Conexão**: 5200, 5201, 5202
  - Usadas para conexões de clientes do jogo
- **Porta HTTP para Gateway Control**: 9011
  - Usada para receber comandos do Ananta Gateway Control
  - Implementada com HttpListener no arquivo `Server.cs`

### Proxy (`Ananta_Proxy`)
- **Portas Variáveis**: Conforme configuração do proxy
  - Tipicamente inclui portas para interceptação de tráfego
  - Consulte `Ananta_Proxy/proxy/server.js` para detalhes específicos

### Gateway Control (`ananta-gateway-control`)
- **Porta de Desenvolvimento**: 8000
  - Usada para a interface web do gateway control
  - Acessível via navegador em `http://localhost:8000`

## Comunicação entre Componentes

### Gateway Control → Servidor do Jogo
- O gateway control envia comandos para o servidor do jogo através da porta 9011
- Utiliza requisições HTTP POST para endpoints específicos:
  - `/command` - para comandos gerais
  - `/spawn` - para comandos de spawn de veículos

### Servidor do Jogo → Clientes
- O servidor do jogo comunica-se com os clientes pelas portas 5200, 5201 e 5202
- Usa protocolo TCP/IP personalizado com criptografia RC4

## Importante

- Certifique-se de que nenhuma outra aplicação esteja usando estas portas antes de iniciar os componentes
- A porta 9011 é crítica para a funcionalidade do gateway control
- A porta 8000 é usada exclusivamente para a interface web do gateway control
- As portas 5200, 5201 e 5202 são necessárias para conexão dos clientes do jogo

## Solução de Problemas Comuns

### Erro "Invalid config keys: devServer"
- Este erro ocorre quando tentamos usar a configuração `devServer` no Umi/Max.js
- A solução é remover esta configuração e especificar a porta diretamente no comando de inicialização
- O script `start_gateway_control.cmd` agora inclui o parâmetro `--port=8000` para definir a porta de desenvolvimento

### Avisos de Dependência do NPM
- Os avisos de dependência durante a instalação não afetam o funcionamento do sistema
- São resultado de versões diferentes de bibliotecas como React e ReactDOM
- O sistema continua funcionando normalmente apesar desses avisos

## Troubleshooting

Se encontrar problemas de conexão:
1. Verifique se as portas necessárias estão livres
2. Confirme que o firewall não está bloqueando as portas
3. Execute o script `setup_and_start_all_as_admin.cmd` como administrador