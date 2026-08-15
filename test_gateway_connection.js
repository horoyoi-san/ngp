// Script de teste para verificar a conexão com o gateway control e servidor
const http = require('http');

console.log('Testando conexão com o servidor do jogo na porta 9011...');

// Testar se o servidor está escutando na porta 9011
const testServer = () => {
    const postData = JSON.stringify({
        methodId: 62541429, // TELEPORT
        position: {
            x: 0,
            y: 0,
            z: 0
        }
    });

    const options = {
        hostname: '127.0.0.1',
        port: 9011,
        path: '/command',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(postData)
        }
    };

    const req = http.request(options, (res) => {
        console.log(`Status da resposta: ${res.statusCode}`);
        
        res.on('data', (chunk) => {
            console.log(`Corpo da resposta: ${chunk}`);
        });
        
        res.on('end', () => {
            console.log('Teste concluído com sucesso!');
            console.log('O gateway control está se comunicando corretamente com o servidor do jogo.');
            console.log('Certifique-se de que:');
            console.log('- O servidor do jogo está em execução');
            console.log('- A porta 9011 está disponível e não bloqueada por firewall');
            console.log('- O servidor foi iniciado com permissões de administrador');
        });
    });

    req.on('error', (e) => {
        console.error(`Erro na requisição: ${e.message}`);
        console.log('\nPossíveis causas:');
        console.log('- Servidor do jogo não está em execução');
        console.log('- Firewall está bloqueando a porta 9011');
        console.log('- Servidor não foi iniciado com permissões de administrador');
        console.log('- Porta 9011 está sendo usada por outro processo');
    });

    req.write(postData);
    req.end();
};

// Aguardar um pouco antes de testar para dar tempo do servidor iniciar
setTimeout(testServer, 2000);