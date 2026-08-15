import { Typography } from 'antd';
import React from 'react';

const { Title, Paragraph, Text } = Typography;

const AboutPage: React.FC = () => {
  return (
    <div>
      <Title level={2}>Sobre o Ananta Gateway Control</Title>
      
      <Paragraph>
        <Text strong>O Ananta Gateway Control</Text> é uma aplicação web desenvolvida para fornecer 
        controle em tempo real sobre o servidor do jogo Ananta. Esta ferramenta permite que 
        administradores e desenvolvedores gerenciem o jogo remotamente, enviando comandos 
        diretamente para o servidor.
      </Paragraph>
      
      <Title level={3}>Funcionalidades</Title>
      <Paragraph>
        A aplicação oferece diversas funcionalidades para controle do jogo:
      </Paragraph>
      <ul>
        <li>Teletransporte de personagens para posições específicas</li>
        <li>Gerenciamento de itens e dinheiro no jogo</li>
        <li>Invocação de veículos em tempo real</li>
        <li>Aplicação de buffs e efeitos especiais</li>
        <li>Troca de armas dos personagens</li>
        <li>E muito mais, com base nos milhares de comandos disponíveis</li>
      </ul>
      
      <Title level={3}>Tecnologia</Title>
      <Paragraph>
        A aplicação é construída com tecnologias modernas:
      </Paragraph>
      <ul>
        <li><Text code>React</Text> com <Text code>TypeScript</Text> para a interface</li>
        <li><Text code>Ant Design</Text> para componentes UI</li>
        <li><Text code>Umi/Max.js</Text> para o framework</li>
        <li><Text code>C#</Text> com <Text code>HttpListener</Text> para o backend</li>
      </ul>
      
      <Title level={3}>Integração</Title>
      <Paragraph>
        O gateway control se integra diretamente com o servidor do jogo através de uma API REST, 
        permitindo comandos em tempo real sem interrupção do serviço. A comunicação é feita 
        através de uma porta dedicada (9011) para evitar conflitos com outras funcionalidades.
      </Paragraph>
      
      <Title level={3}>Desenvolvimento</Title>
      <Paragraph>
        Esta ferramenta foi desenvolvida como parte do ecossistema do servidor Ananta, 
        proporcionando uma maneira eficiente e amigável de gerenciar o jogo em tempo real. 
        O código é estruturado para facilitar a adição de novos comandos e funcionalidades.
      </Paragraph>
    </div>
  );
};

export default AboutPage;