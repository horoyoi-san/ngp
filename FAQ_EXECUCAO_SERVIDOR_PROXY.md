# FAQ - Execução do Servidor e Proxy do AnantaTestGameServer

## 1. Como executar o Servidor do Jogo?

### Método Simples:
Execute o arquivo `start_server.cmd` clicando duas vezes nele ou executando-o no prompt de comando.

### Manualmente via linha de comando:
1. Abra o prompt de comando e navegue até o diretório raiz do projeto
2. Execute: `start_server.cmd`

### Requisitos:
- Ter o .NET SDK instalado
- As portas 5200, 5201, 5202 e 9011 devem estar disponíveis
- Firewall deve permitir conexões nestas portas

### O que o servidor faz:
- Escuta por conexões de clientes do jogo nas portas 5200, 5201 e 5202
- Aceita comandos do gateway control na porta 9011
- Usa criptografia RC4 para comunicação com os clientes

## 2. Como executar o Proxy?

### Pré-requisitos:
Antes de executar o proxy pela primeira vez, é necessário configurar os certificados e entradas do hosts como administrador:

1. Execute o script `Ananta_Proxy\SETUP_PROXY_AS_ADMIN.ps1` como administrador
   - Isso criará um certificado local
   - Adicionará entradas no arquivo hosts do Windows
   - Instalará o certificado na store de autoridades raiz confiáveis

### Execução do Proxy:
Execute o script `Ananta_Proxy\Start-Proxy.ps1` (também como administrador).

### Portas usadas pelo proxy:
- 80 (HTTP)
- 443 (HTTPS)
- 5801 (lista de login)
- 5803 (ligação TCP de login)
- 5804 (ligação TCP do jogo)
- 8013

### Requisitos:
- Node.js instalado
- Ter privilégios de administrador
- O certificado do proxy deve estar presente em `Ananta_Proxy\proxy\certs\`

## 3. Como executar o Gateway Control?

### Método Simples:
Execute o arquivo `start_gateway_control.cmd`.

### Manualmente via linha de comando:
1. Navegue até o diretório `ananta-gateway-control`
2. Execute: `npm run dev -- --port=8000`

### Requisitos:
- Node.js instalado
- As dependências do projeto serão instaladas automaticamente (ou execute `npm install` manualmente)

### Acesso:
Após iniciar, acesse `http://localhost:8000` no seu navegador.

## 4. Como executar todos os componentes de uma vez?

Execute o script `setup_and_start_all_as_admin.cmd` como administrador. Este script:

1. Inicia o servidor do jogo
2. Inicia o proxy
3. Inicia o gateway control

**ATENÇÃO:** Este script requer privilégios de administrador devido às necessidades do proxy.

## 5. Quais são as portas usadas por cada componente?

- **Servidor do Jogo (`AnantaTestGameServer`)**:
  - Portas de conexão: 5200, 5201, 5202
  - Porta HTTP para Gateway Control: 9011

- **Proxy (`Ananta_Proxy`)**:
  - Portas variáveis conforme configuração: 80, 443, 5801, 5803, 5804, 8013

- **Gateway Control (`ananta-gateway-control`)**:
  - Porta de desenvolvimento: 8000

## 6. O que fazer se aparecer erro de certificado?

Se encontrar erros relacionados a certificados:

1. Execute novamente `Ananta_Proxy\SETUP_PROXY_AS_ADMIN.ps1` como administrador
2. Certifique-se de que o certificado `l50.update.netease.com.pfx` exista no diretório `Ananta_Proxy\proxy\certs\`
3. Verifique se o certificado está instalado corretamente na store de autoridades raiz confiáveis

## 7. Por que preciso executar os scripts como administrador?

O proxy precisa de privilégios administrativos para:
- Modificar o arquivo hosts do sistema
- Instalar o certificado SSL local
- Associar-se às portas privilegiadas (80 e 443)

## 8. Como verificar se as portas necessárias estão livres?

Você pode usar o comando Windows:
```
netstat -ano | findstr :<porta>
```

Substitua `<porta>` pelas portas necessárias (5200, 5201, 5202, 9011, 80, 443, 8000).

## 9. Onde posso encontrar os logs de execução?

- **Servidor do Jogo**: Os logs aparecem diretamente na janela do console
- **Proxy**: Localizados em `Ananta_Proxy\proxy\logs\proxy.log`
- **Gateway Control**: Mensagens aparecem na janela do terminal onde foi iniciado

## 10. Como solucionar problemas comuns?

### Erro "Invalid config keys: devServer":
- Remova esta configuração do arquivo de configuração ou especifique a porta diretamente no comando de inicialização

### Avisos de dependência do NPM:
- Estes avisos não afetam o funcionamento do sistema
- São resultado de versões diferentes de bibliotecas como React e ReactDOM

### Problemas de conexão:
1. Verifique se as portas necessárias estão livres
2. Confirme que o firewall não está bloqueando as portas
3. Execute o script `setup_and_start_all_as_admin.cmd` como administrador

### Se o proxy não redirecionar corretamente:
- Verifique se as entradas no arquivo hosts foram criadas corretamente
- Confirme que o certificado SSL está instalado corretamente
- Execute `ipconfig /flushdns` para limpar o cache DNS

## 11. Como parar os serviços?

Para parar cada componente:
- Servidor: Feche a janela do console onde está rodando
- Proxy: Feche a janela do PowerShell onde está rodando
- Gateway Control: Pressione Ctrl+C na janela do terminal ou feche a aba do navegador

## 12. O que são os scripts adicionais no diretório ananta-gateway-control?

O diretório `ananta-gateway-control` contém vários scripts auxiliares:

- `run_gateway.cmd`: Inicia o servidor de desenvolvimento
- `build_gateway.cmd`: Cria uma build da aplicação
- `serve_gateway.cmd`: Serve a aplicação a partir dos arquivos buildados
- `clean_gateway.cmd`: Remove arquivos temporários
- `status_gateway.cmd`: Verifica o status da instalação
- `quick_start.cmd`: Inicia rapidamente o servidor
- `safe_start.cmd`: Inicia com verificação de portas
- `install_deps.cmd`: Instala as dependências necessárias
- `setup_and_run.cmd`: Instala e inicia em um único comando
- `diagnose.cmd`: Diagnóstico completo do ambiente
- `backup.cmd`: Cria backup da aplicação
- `restore.cmd`: Restaura a aplicação de um backup
- `check_port.cmd`: Verifica se as portas estão em uso
- `help_gateway.cmd`: Mostra informações de ajuda