import { Alert, Button, Card, Col, Form, Input, InputNumber, Row, Select, Typography } from 'antd';
import React, { useState } from 'react';
import { Link } from 'umi';

const { Title, Paragraph, Text } = Typography;

const VEHICLE_IDS = {
  TOW_TRUCK: 81000002,
  FIRE_TRUCK: 81000004,
  HACKER_VEHICLE: 81000005,
  POLICE_CAR: 81004002,
  MILK_VEHICLE: 81007009,
  TEST_SPADE: 81007023,
} as const;

type Notice = {
  type: 'success' | 'error' | 'info';
  message: string;
  description?: string;
};

const getErrorMessage = (error: unknown) => {
  return error instanceof Error ? error.message : 'Unknown error';
};

const IndexPage: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [notice, setNotice] = useState<Notice>({
    type: 'info',
    message: 'Gateway API',
    description: 'Start the game server gateway on http://127.0.0.1:9011 before sending commands.',
  });

  const handleSpawn = async (values: any) => {
    setLoading(true);
    setNotice({ type: 'info', message: 'Sending spawn command...' });

    try {
      const response = await fetch('http://127.0.0.1:9011/spawn', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          methodId: 67928941,
          entityConfigId: Number(values.entityConfigId),
          distance: Number(values.distance),
          seatCount: Number(values.seatCount),
          entityId: values.entityId,
          summonType: values.summonType,
          createSourceType: values.createSourceType,
          colorConfigId: Number(values.colorConfigId),
          position: {
            x: Number(values.positionX),
            y: Number(values.positionY),
            z: Number(values.positionZ),
          },
        }),
      });

      if (!response.ok) {
        throw new Error(`Gateway returned HTTP ${response.status}`);
      }

      const result = await response.json();
      console.log('Spawn result:', result);
      setNotice({
        type: 'success',
        message: 'Spawn command sent',
        description: 'The gateway accepted the request. Check the game server for the result.',
      });
    } catch (error) {
      console.error('Spawn error:', error);
      setNotice({
        type: 'error',
        message: 'Could not reach the gateway',
        description: `${getErrorMessage(error)}. Confirm the game server gateway is running on port 9011 and that your browser can access localhost.`,
      });
    } finally {
      setLoading(false);
    }
  };

  const handleQuickSelect = (vehicleId: number) => {
    form.setFieldsValue({
      entityConfigId: vehicleId,
    });
  };

  const vehicleButtons = [
    ['Tow Truck', VEHICLE_IDS.TOW_TRUCK],
    ['Fire Truck', VEHICLE_IDS.FIRE_TRUCK],
    ['Hacker Vehicle', VEHICLE_IDS.HACKER_VEHICLE],
    ['Police Car', VEHICLE_IDS.POLICE_CAR],
    ['Milk Vehicle', VEHICLE_IDS.MILK_VEHICLE],
    ['Test Spade', VEHICLE_IDS.TEST_SPADE],
  ] as const;

  return (
    <div>
      <Title level={2}>Ananta Gateway Control</Title>
      <Paragraph>
        Control panel for sending real-time commands to the Ananta game server.
      </Paragraph>

      <Alert
        message={notice.message}
        description={notice.description}
        type={notice.type}
        showIcon
        style={{ marginBottom: 24 }}
      />

      <Row gutter={[16, 16]}>
        <Col xs={24} lg={16}>
          <Card title="Quick Vehicle Spawn" bordered>
            <Paragraph>
              Pick a vehicle preset or enter an entity config ID manually.
            </Paragraph>

            <div className="quick-grid">
              {vehicleButtons.map(([label, id]) => (
                <Button key={id} onClick={() => handleQuickSelect(id)}>
                  {label} ({id})
                </Button>
              ))}
            </div>

            <Form
              form={form}
              layout="vertical"
              onFinish={handleSpawn}
              initialValues={{
                entityConfigId: VEHICLE_IDS.TOW_TRUCK,
                distance: 5,
                seatCount: 4,
                entityId: '123456789',
                summonType: 'NormalSummon',
                createSourceType: 'Online',
                colorConfigId: 1,
                positionX: 0,
                positionY: 0,
                positionZ: 0,
              }}
            >
              <Row gutter={16}>
                <Col xs={24} md={12}>
                  <Form.Item
                    label="Entity Config ID"
                    name="entityConfigId"
                    rules={[{ required: true, message: 'Enter an entity config ID.' }]}
                  >
                    <InputNumber style={{ width: '100%' }} />
                  </Form.Item>
                </Col>
                <Col xs={24} md={12}>
                  <Form.Item
                    label="Entity ID"
                    name="entityId"
                    rules={[{ required: true, message: 'Enter an entity ID.' }]}
                  >
                    <Input />
                  </Form.Item>
                </Col>
                <Col xs={24} sm={12} md={8}>
                  <Form.Item label="Distance" name="distance" rules={[{ required: true }]}>
                    <InputNumber style={{ width: '100%' }} min={0} />
                  </Form.Item>
                </Col>
                <Col xs={24} sm={12} md={8}>
                  <Form.Item label="Seat Count" name="seatCount" rules={[{ required: true }]}>
                    <InputNumber style={{ width: '100%' }} min={1} />
                  </Form.Item>
                </Col>
                <Col xs={24} sm={12} md={8}>
                  <Form.Item label="Color Config ID" name="colorConfigId">
                    <InputNumber style={{ width: '100%' }} min={0} />
                  </Form.Item>
                </Col>
                <Col xs={24} md={12}>
                  <Form.Item label="Summon Type" name="summonType">
                    <Select
                      options={[
                        { value: 'NormalSummon', label: 'Normal Summon' },
                        { value: 'ForceSummon', label: 'Force Summon' },
                      ]}
                    />
                  </Form.Item>
                </Col>
                <Col xs={24} md={12}>
                  <Form.Item label="Create Source Type" name="createSourceType">
                    <Select
                      options={[
                        { value: 'Online', label: 'Online' },
                        { value: 'Task', label: 'Task' },
                        { value: 'Summon', label: 'Summon' },
                        { value: 'MiniGame', label: 'Mini Game' },
                        { value: 'GM', label: 'GM' },
                      ]}
                    />
                  </Form.Item>
                </Col>
                <Col xs={24} sm={8}>
                  <Form.Item label="Position X" name="positionX">
                    <InputNumber style={{ width: '100%' }} />
                  </Form.Item>
                </Col>
                <Col xs={24} sm={8}>
                  <Form.Item label="Position Y" name="positionY">
                    <InputNumber style={{ width: '100%' }} />
                  </Form.Item>
                </Col>
                <Col xs={24} sm={8}>
                  <Form.Item label="Position Z" name="positionZ">
                    <InputNumber style={{ width: '100%' }} />
                  </Form.Item>
                </Col>
              </Row>

              <Form.Item>
                <div className="form-actions">
                  <Button type="primary" htmlType="submit" loading={loading}>
                    Spawn
                  </Button>
                  <Button onClick={() => setNotice({ type: 'info', message: 'Enter command selected' })}>
                    Enter
                  </Button>
                  <Button onClick={() => setNotice({ type: 'info', message: 'Exit command selected' })}>
                    Exit
                  </Button>
                  <Button onClick={() => setNotice({ type: 'info', message: 'Sync command selected' })}>
                    Sync
                  </Button>
                </div>
              </Form.Item>
            </Form>
          </Card>
        </Col>

        <Col xs={24} lg={8}>
          <Card title="Connection Checklist" bordered>
            <Paragraph>
              <Text strong>Web UI:</Text> run on port 8000 for development or 8080 when serving the build.
            </Paragraph>
            <Paragraph>
              <Text strong>Gateway API:</Text> the game server must listen on port 9011.
            </Paragraph>
            <Link to="/game-commands">
              <Button type="primary" block>
                Open Advanced Commands
              </Button>
            </Link>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default IndexPage;
