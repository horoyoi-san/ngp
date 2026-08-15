import { Button, Form, Input, InputNumber, Select, Space, Tabs, Typography } from 'antd';
import React, { useState } from 'react';

const { Title, Paragraph } = Typography;
const { Option } = Select;

// Definindo constantes para os IDs de métodos encontrados em MethodId.cs
const METHOD_IDS = {
  // Comandos de espírito
  SYNC_SPIRIT_WEAPON_DETAIL: 68396726,
  SYNC_SPIRIT_SWITCH_WEAPON_ACTION: 68753590,
  SYNC_ALL_SPIRITS: 64203304,
  
  // Comandos de buffs
  SYNC_UNIT_BUFF_LIST: 68974077,
  
  // Comandos de atributos
  SYNC_UNIT_ATTRS: 68642656,
  
  // Comandos de veículos
  ASK_SUMMON_VEHICLE: 67928941,
  
  // Comandos de habilidades
  GM_ADD_BUFF: 62622667,
  GM_ADD_ABILITY_EXP: 62005754,
  GM_ADD_JOB_EXP: 62743909,
  
  // Comandos de itens
  ADD_ITEM: 62681822,
  REMOVE_ITEM: 62624650,
  ADD_MONEY: 62375638,
  
  // Comandos de teleporte
  TELEPORT: 62541429,
  
  // Comandos de talentos
  GM_CHANGE_SPIRIT_JOB_TALENT_POINT: 62428500,
  
  // Comandos de espíritos
  GM_ADD_ALL_SPIRITS: 65712268,
  GM_UNLOCK_BADGE: 62737299,
  
  // Outros comandos úteis
  GM_ADD_FASHIONS: 62390823,
  GM_ADD_VEHICLE: 62601335,
  GM_FINISH_ACHIEVEMENT: 62570854,
} as const;

const WEAPON_IDS = {
  WEAPON_1: 98003184,
  WEAPON_2: 98005002,
  WEAPON_3: 98006006,
  WEAPON_4: 98003185,
} as const;

const BUFF_IDS = {
  SUPERMAN: 52606154,
  MULTIPLE_JUMP: 52607001,
  LONG_SWING: 52900002,
  CAN_SWING: 52606102,
  CAR_BUFF: 52853763,
} as const;

const getErrorMessage = (error: unknown) => {
  return error instanceof Error ? error.message : 'Unknown error';
};

const GameCommands: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  const handleSendCommand = async (methodId: number, params: any) => {
    setLoading(true);
    try {
      const response = await fetch('http://127.0.0.1:9011/command', { // Porta específica para o servidor C#
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          methodId,
          ...params
        }),
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const result = await response.json();
      console.log('Command result:', result);
      alert('Comando enviado com sucesso!');
    } catch (error) {
      console.error('Command error:', error);
      alert('Erro ao enviar comando: ' + getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleTeleport = (values: any) => {
    handleSendCommand(METHOD_IDS.TELEPORT, {
      position: {
        x: values.posX,
        y: values.posY,
        z: values.posZ,
      }
    });
  };

  const handleAddItem = (values: any) => {
    handleSendCommand(METHOD_IDS.ADD_ITEM, {
      itemId: values.itemId,
      count: values.count || 1
    });
  };

  const handleAddMoney = (values: any) => {
    handleSendCommand(METHOD_IDS.ADD_MONEY, {
      moneyType: values.moneyType || 1,
      amount: values.amount
    });
  };

  const handleSpawnVehicle = (values: any) => {
    handleSendCommand(METHOD_IDS.ASK_SUMMON_VEHICLE, {
      entityConfigId: values.vehicleId,
      position: {
        x: values.posX,
        y: values.posY,
        z: values.posZ,
      },
      distance: values.distance || 5,
      seatCount: values.seatCount || 4,
      summonType: values.summonType || 'NormalSummon',
      createSourceType: values.createSourceType || 'Online',
    });
  };

  const handleAddBuff = (values: any) => {
    handleSendCommand(METHOD_IDS.GM_ADD_BUFF, {
      buffId: values.buffId,
      entityId: values.entityId || 'current_spirit'
    });
  };

  const handleSwitchWeapon = (values: any) => {
    handleSendCommand(METHOD_IDS.SYNC_SPIRIT_SWITCH_WEAPON_ACTION, {
      weaponInstanceId: values.weaponInstanceId,
      reason: values.reason || 'Roulette'
    });
  };

  const tabItems = [
    {
      key: 'teleport',
      label: 'Teletransporte',
      children: (
        <Form
          form={form}
          layout="vertical"
          onFinish={handleTeleport}
        >
          <Form.Item
            label="Posição X"
            name="posX"
            rules={[{ required: true, message: 'Por favor insira a posição X!' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 0" />
          </Form.Item>

          <Form.Item
            label="Posição Y"
            name="posY"
            rules={[{ required: true, message: 'Por favor insira a posição Y!' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 0" />
          </Form.Item>

          <Form.Item
            label="Posição Z"
            name="posZ"
            rules={[{ required: true, message: 'Por favor insira a posição Z!' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 0" />
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading}>
              Teletransportar
            </Button>
          </Form.Item>
        </Form>
      ),
    },
    {
      key: 'items',
      label: 'Itens e Dinheiro',
      children: (
        <>
          <Title level={4}>Adicionar Item</Title>
          <Form
            layout="vertical"
            onFinish={handleAddItem}
          >
            <Form.Item
              label="ID do Item"
              name="itemId"
              rules={[{ required: true, message: 'Por favor insira o ID do item!' }]}
            >
              <InputNumber style={{ width: '100%' }} placeholder="Ex: 1001" />
            </Form.Item>

            <Form.Item
              label="Quantidade"
              name="count"
            >
              <InputNumber style={{ width: '100%' }} min={1} defaultValue={1} />
            </Form.Item>

            <Form.Item>
              <Button type="primary" htmlType="submit" loading={loading}>
                Adicionar Item
              </Button>
            </Form.Item>
          </Form>

          <Title level={4} style={{ marginTop: 24 }}>Adicionar Dinheiro</Title>
          <Form
            layout="vertical"
            onFinish={handleAddMoney}
          >
            <Form.Item
              label="Tipo de Dinheiro"
              name="moneyType"
            >
              <Select placeholder="Selecione o tipo de dinheiro">
                <Option value={1}>Moeda Principal</Option>
                <Option value={2}>Moeda Secundária</Option>
                <Option value={3}>Premium</Option>
              </Select>
            </Form.Item>

            <Form.Item
              label="Quantidade"
              name="amount"
              rules={[{ required: true, message: 'Por favor insira a quantidade!' }]}
            >
              <InputNumber style={{ width: '100%' }} min={1} placeholder="Ex: 1000" />
            </Form.Item>

            <Form.Item>
              <Button type="primary" htmlType="submit" loading={loading}>
                Adicionar Dinheiro
              </Button>
            </Form.Item>
          </Form>
        </>
      ),
    },
    {
      key: 'vehicles',
      label: 'Veículos',
      children: (
        <Form
          layout="vertical"
          onFinish={handleSpawnVehicle}
        >
          <Form.Item
            label="ID do Veículo"
            name="vehicleId"
            rules={[{ required: true, message: 'Por favor selecione ou insira um ID de veículo!' }]}
          >
            <Select placeholder="Selecione ou digite o ID do veículo">
              <Option value={81000002}>Caminhão de Guincho</Option>
              <Option value={81000004}>Caminhão de Bombeiros</Option>
              <Option value={81000005}>Veículo Hacker</Option>
              <Option value={81004002}>Viatura Policial</Option>
              <Option value={81007009}>Veículo Leiteiro</Option>
              <Option value={81007023}>Test Spade</Option>
              <Option value="">------- Outros IDs -------</Option>
              <Option value={81000001}>Carro Esportivo</Option>
              <Option value={81000003}>Caminhonete</Option>
              <Option value={81000006}>Helicóptero</Option>
            </Select>
          </Form.Item>

          <Form.Item
            label="Distância"
            name="distance"
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 5" defaultValue={5} />
          </Form.Item>

          <Form.Item
            label="Número de Assentos"
            name="seatCount"
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 4" defaultValue={4} />
          </Form.Item>

          <Form.Item
            label="Posição X"
            name="posX"
            rules={[{ required: true, message: 'Por favor insira a posição X!' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 0" />
          </Form.Item>

          <Form.Item
            label="Posição Y"
            name="posY"
            rules={[{ required: true, message: 'Por favor insira a posição Y!' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 0" />
          </Form.Item>

          <Form.Item
            label="Posição Z"
            name="posZ"
            rules={[{ required: true, message: 'Por favor insira a posição Z!' }]}
          >
            <InputNumber style={{ width: '100%' }} placeholder="Ex: 0" />
          </Form.Item>

          <Form.Item
            label="Tipo de Invocação"
            name="summonType"
          >
            <Select placeholder="Selecione o tipo de invocação">
              <Option value="NormalSummon">Invocação Normal</Option>
              <Option value="ForceSummon">Invocação Forçada</Option>
            </Select>
          </Form.Item>

          <Form.Item
            label="Fonte de Criacao"
            name="createSourceType"
          >
            <Select placeholder="Selecione a fonte de criacao">
              <Option value="Online">Online</Option>
              <Option value="Task">Tarefa</Option>
              <Option value="Summon">Invocacao</Option>
              <Option value="MiniGame">Mini Jogo</Option>
              <Option value="GM">GM</Option>
            </Select>
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading}>
              Invocar Veículo
            </Button>
          </Form.Item>
        </Form>
      ),
    },
    {
      key: 'buffs',
      label: 'Buffs e Efeitos',
      children: (
        <Form
          layout="vertical"
          onFinish={handleAddBuff}
        >
          <Form.Item
            label="ID do Buff"
            name="buffId"
            rules={[{ required: true, message: 'Por favor selecione ou insira um ID de buff!' }]}
          >
            <Select placeholder="Selecione ou digite o ID do buff">
              <Option value={BUFF_IDS.SUPERMAN}>Superman (52606154)</Option>
              <Option value={BUFF_IDS.MULTIPLE_JUMP}>Múltiplos Saltos (52607001)</Option>
              <Option value={BUFF_IDS.LONG_SWING}>Long Swing (52900002)</Option>
              <Option value={BUFF_IDS.CAN_SWING}>Pode Balançar (52606102)</Option>
              <Option value={BUFF_IDS.CAR_BUFF}>Buff de Carro (52853763)</Option>
              <Option value="">------- Outros IDs -------</Option>
              <Option value={52606155}>Velocidade Aumentada</Option>
              <Option value={52606156}>Invisibilidade</Option>
              <Option value={52606157}>Invencibilidade</Option>
            </Select>
          </Form.Item>

          <Form.Item
            label="ID da Entidade"
            name="entityId"
          >
            <Input placeholder="Deixe vazio para aplicar ao espírito atual" />
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading}>
              Aplicar Buff
            </Button>
          </Form.Item>
        </Form>
      ),
    },
    {
      key: 'weapons',
      label: 'Armas',
      children: (
        <Form
          layout="vertical"
          onFinish={handleSwitchWeapon}
        >
          <Form.Item
            label="ID da Instância da Arma"
            name="weaponInstanceId"
            rules={[{ required: true, message: 'Por favor selecione ou insira um ID de arma!' }]}
          >
            <Select placeholder="Selecione ou digite o ID da arma">
              <Option value={WEAPON_IDS.WEAPON_1}>Arma 1 ({WEAPON_IDS.WEAPON_1})</Option>
              <Option value={WEAPON_IDS.WEAPON_2}>Arma 2 ({WEAPON_IDS.WEAPON_2})</Option>
              <Option value={WEAPON_IDS.WEAPON_3}>Arma 3 ({WEAPON_IDS.WEAPON_3})</Option>
              <Option value={WEAPON_IDS.WEAPON_4}>Arma 4 ({WEAPON_IDS.WEAPON_4})</Option>
              <Option value="">------- Outros IDs -------</Option>
              <Option value={6000000000005}>Espada Lendária</Option>
              <Option value={6000000000006}>Fuzil de Assalto</Option>
              <Option value={6000000000007}>Sniper Premium</Option>
            </Select>
          </Form.Item>

          <Form.Item
            label="Motivo da Troca"
            name="reason"
          >
            <Select placeholder="Selecione o motivo da troca">
              <Option value="Roulette">Roleta</Option>
              <Option value="Manual">Manual</Option>
              <Option value="Combat">Combate</Option>
              <Option value="Skill">Habilidade</Option>
            </Select>
          </Form.Item>

          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading}>
              Trocar Arma
            </Button>
          </Form.Item>
        </Form>
      ),
    },
  ];

  return (
    <div>
      <Title level={2}>Controle de Comandos do Jogo - Ananta Gateway</Title>
      <Paragraph>
        Este painel permite enviar comandos em tempo real para o servidor do jogo.
      </Paragraph>
      
      <Tabs defaultActiveKey="teleport" items={tabItems} />
      
      <div style={{ marginTop: 24 }}>
        <Title level={4}>Informações Adicionais:</Title>
        <Paragraph>Os comandos são baseados nos IDs encontrados no arquivo MethodId.cs do servidor.</Paragraph>
        <Paragraph>Alguns comandos podem exigir privilégios especiais ou não produzir efeitos visíveis imediatos.</Paragraph>
        <Paragraph><strong>Nota:</strong> O gateway control se comunica com o servidor do jogo na porta 9011.</Paragraph>
      </div>
    </div>
  );
};

export default GameCommands;
