-- HardwareTech — Seed de dados mockados para dev
-- Senha padrão dos usuários: admin123 (BCrypt)

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE item;
TRUNCATE TABLE pedido;
TRUNCATE TABLE componente;
TRUNCATE TABLE caixa;
TRUNCATE TABLE categoria;
TRUNCATE TABLE usuario;
TRUNCATE TABLE funcao;
SET FOREIGN_KEY_CHECKS = 1;

-- ─────────────────── Funções (Roles) ───────────────────
INSERT INTO funcao (id_funcao, nome_funcao) VALUES
  (1, 'ADMIN'),
  (2, 'GERENTE'),
  (3, 'VENDEDOR');

-- ─────────────────── Usuários ───────────────────
-- Senha = admin123 (BCrypt $2y$10$...)
INSERT INTO usuario (nome, email, senha, foto, status, created_at, updated_at, fk_funcao) VALUES
  ('Diogo Polastrine',    'admin@hardwaretech.com',    '$2y$10$WzBcDeQn8VSFYVoy6GRaP.RD/bjtMT2bYQsjF18JlzMAnCbzvUfYy', NULL, 1, '2026-01-10', '2026-04-01', 1),
  ('Ana Gerente',         'gerente@hardwaretech.com',  '$2y$10$WzBcDeQn8VSFYVoy6GRaP.RD/bjtMT2bYQsjF18JlzMAnCbzvUfYy', NULL, 1, '2026-01-15', '2026-03-20', 2),
  ('Carlos Vendedor',     'vendedor@hardwaretech.com', '$2y$10$WzBcDeQn8VSFYVoy6GRaP.RD/bjtMT2bYQsjF18JlzMAnCbzvUfYy', NULL, 1, '2026-02-01', '2026-04-10', 3),
  ('Mariana Silva',       'mariana@hardwaretech.com',  '$2y$10$WzBcDeQn8VSFYVoy6GRaP.RD/bjtMT2bYQsjF18JlzMAnCbzvUfYy', NULL, 1, '2026-02-05', '2026-04-12', 3),
  ('Ricardo Costa',       'ricardo@hardwaretech.com',  '$2y$10$WzBcDeQn8VSFYVoy6GRaP.RD/bjtMT2bYQsjF18JlzMAnCbzvUfYy', NULL, 0, '2026-02-10', '2026-03-05', 3);

-- ─────────────────── Categorias ───────────────────
INSERT INTO categoria (id_categoria, nome_categoria) VALUES
  (1,  'Resistores'),
  (2,  'Capacitores'),
  (3,  'Microcontroladores'),
  (4,  'Transistores'),
  (5,  'Diodos'),
  (6,  'LEDs'),
  (7,  'Sensores'),
  (8,  'Conectores'),
  (9,  'Indutores'),
  (10, 'Reguladores de Tensão'),
  (11, 'Circuitos Integrados'),
  (12, 'Cristais e Osciladores');

-- ─────────────────── Caixas ───────────────────
INSERT INTO caixa (id_caixa, nome_caixa) VALUES
  (1, 'Caixa A1 - Prateleira Superior'),
  (2, 'Caixa A2 - Prateleira Superior'),
  (3, 'Caixa B1 - Prateleira Meio'),
  (4, 'Caixa B2 - Prateleira Meio'),
  (5, 'Caixa C1 - Prateleira Inferior'),
  (6, 'Caixa C2 - Prateleira Inferior'),
  (7, 'Caixa D1 - Estoque Extra'),
  (8, 'Caixa D2 - Estoque Extra');

-- ─────────────────── Componentes ───────────────────
INSERT INTO componente
  (id_hardwaretech, nome_componente, part_number, quantidade, codigo_ml, imagem,
   data_ultima_venda, created_at, updated_at, quantidade_vendido, flag_ml, flag_verificado,
   condicao, observacao, descricao, fk_caixa, fk_categoria, is_visible_catalog)
VALUES
  -- Resistores
  ('HT-R-0001', 'Resistor 1kΩ 1/4W',  'CFR-25JB-1K0',   500, 'MLB-101', NULL, '2026-04-15', '2026-01-10', '2026-04-15', 1200, 1, 1, 'BOM_ESTADO', NULL, 'Resistor de filme de carbono 1kΩ 5% 1/4W',   1, 1, 1),
  ('HT-R-0002', 'Resistor 10kΩ 1/4W', 'CFR-25JB-10K',   750, 'MLB-102', NULL, '2026-04-18', '2026-01-10', '2026-04-18',  900, 1, 1, 'BOM_ESTADO', NULL, 'Resistor de filme de carbono 10kΩ 5% 1/4W',   1, 1, 1),
  ('HT-R-0003', 'Resistor 220Ω 1/4W', 'CFR-25JB-220R',  420, 'MLB-103', NULL, '2026-04-10', '2026-01-10', '2026-04-10',  680, 1, 1, 'BOM_ESTADO', NULL, 'Resistor de filme de carbono 220Ω 5% 1/4W',   1, 1, 1),

  -- Capacitores
  ('HT-C-0001', 'Capacitor 100nF Cerâmico', '104-50V',   800, 'MLB-201', NULL, '2026-04-20', '2026-01-12', '2026-04-20', 450, 1, 1, 'BOM_ESTADO', NULL, 'Capacitor cerâmico 100nF 50V X7R',       2, 2, 1),
  ('HT-C-0002', 'Capacitor 10uF Eletrolítico', '10UF-25V', 320, 'MLB-202', NULL, '2026-04-16', '2026-01-12', '2026-04-16', 280, 1, 1, 'BOM_ESTADO', NULL, 'Capacitor eletrolítico 10uF 25V radial',   2, 2, 1),
  ('HT-C-0003', 'Capacitor 470uF Eletrolítico', '470UF-16V', 180, 'MLB-203', NULL, '2026-04-05', '2026-01-12', '2026-04-05', 160, 0, 1, 'BOM_ESTADO', NULL, 'Capacitor eletrolítico 470uF 16V',       2, 2, 1),

  -- Microcontroladores
  ('HT-MCU-0001', 'Arduino Uno R3',       'A000066',    45, 'MLB-301', NULL, '2026-04-22', '2026-01-15', '2026-04-22',  85, 1, 1, 'BOM_ESTADO',   NULL,                                  'Placa Arduino Uno R3 original com ATmega328P',      3, 3, 1),
  ('HT-MCU-0002', 'ESP32 DevKit v1',      'ESP-WROOM-32', 60, 'MLB-302', NULL, '2026-04-19', '2026-01-15', '2026-04-19', 120, 1, 1, 'BOM_ESTADO',   NULL,                                  'Microcontrolador ESP32 com Wi-Fi e Bluetooth',      3, 3, 1),
  ('HT-MCU-0003', 'ESP8266 NodeMCU',      'ESP-12E',     75, 'MLB-303', NULL, '2026-04-14', '2026-01-15', '2026-04-14', 150, 1, 1, 'BOM_ESTADO',   NULL,                                  'NodeMCU ESP8266 com Wi-Fi integrado',                3, 3, 1),
  ('HT-MCU-0004', 'Raspberry Pi Pico',    'RP2040',      30, 'MLB-304', NULL, '2026-04-11', '2026-01-15', '2026-04-11',  40, 1, 1, 'BOM_ESTADO',   NULL,                                  'Raspberry Pi Pico dual-core ARM Cortex-M0+',        3, 3, 1),
  ('HT-MCU-0005', 'Arduino Mega 2560',    'A000067',     18, 'MLB-305', NULL, '2026-03-28', '2026-01-15', '2026-03-28',  22, 1, 0, 'EM_OBSERVACAO', 'Alguns vieram com flash irregular', 'Arduino Mega 2560 com ATmega2560',                   3, 3, 1),

  -- Transistores
  ('HT-T-0001', 'Transistor BC547',   'BC547B',   600, 'MLB-401', NULL, '2026-04-17', '2026-02-01', '2026-04-17', 420, 1, 1, 'BOM_ESTADO', NULL, 'Transistor NPN BC547 TO-92',               4, 4, 1),
  ('HT-T-0002', 'Transistor BC557',   'BC557B',   550, 'MLB-402', NULL, '2026-04-12', '2026-02-01', '2026-04-12', 380, 1, 1, 'BOM_ESTADO', NULL, 'Transistor PNP BC557 TO-92',               4, 4, 1),
  ('HT-T-0003', 'Transistor 2N2222',  '2N2222A',  300, 'MLB-403', NULL, '2026-04-08', '2026-02-01', '2026-04-08', 210, 1, 1, 'BOM_ESTADO', NULL, 'Transistor NPN 2N2222A TO-18',             4, 4, 1),
  ('HT-T-0004', 'Mosfet IRFZ44N',     'IRFZ44N',   85, 'MLB-404', NULL, '2026-03-30', '2026-02-01', '2026-03-30',  65, 1, 1, 'BOM_ESTADO', NULL, 'Mosfet de potência IRFZ44N 49A 55V',       4, 4, 1),

  -- Diodos
  ('HT-D-0001', 'Diodo 1N4007',     '1N4007',    900, 'MLB-501', NULL, '2026-04-21', '2026-02-05', '2026-04-21', 540, 1, 1, 'BOM_ESTADO', NULL, 'Diodo retificador 1N4007 1000V 1A',        5, 5, 1),
  ('HT-D-0002', 'Diodo 1N4148',     '1N4148',    800, 'MLB-502', NULL, '2026-04-13', '2026-02-05', '2026-04-13', 470, 1, 1, 'BOM_ESTADO', NULL, 'Diodo de sinal 1N4148 100V 200mA',         5, 5, 1),
  ('HT-D-0003', 'Diodo Zener 5.1V', 'BZX85C5V1',  250, 'MLB-503', NULL, '2026-04-03', '2026-02-05', '2026-04-03', 180, 0, 1, 'BOM_ESTADO', NULL, 'Diodo Zener 5.1V 1W',                      5, 5, 1),

  -- LEDs
  ('HT-LED-0001', 'LED 5mm Vermelho',  'LED-5MM-RED',    1200, 'MLB-601', NULL, '2026-04-23', '2026-02-10', '2026-04-23', 880, 1, 1, 'BOM_ESTADO', NULL, 'LED difuso 5mm vermelho 2V 20mA',     6, 6, 1),
  ('HT-LED-0002', 'LED 5mm Verde',     'LED-5MM-GRN',     900, 'MLB-602', NULL, '2026-04-20', '2026-02-10', '2026-04-20', 640, 1, 1, 'BOM_ESTADO', NULL, 'LED difuso 5mm verde 2.1V 20mA',      6, 6, 1),
  ('HT-LED-0003', 'LED 5mm Azul',      'LED-5MM-BLU',     700, 'MLB-603', NULL, '2026-04-15', '2026-02-10', '2026-04-15', 420, 1, 1, 'BOM_ESTADO', NULL, 'LED difuso 5mm azul 3.2V 20mA',       6, 6, 1),
  ('HT-LED-0004', 'LED RGB 5mm',       'LED-RGB-CA',      450, 'MLB-604', NULL, '2026-04-18', '2026-02-10', '2026-04-18', 260, 1, 1, 'BOM_ESTADO', NULL, 'LED RGB 5mm cátodo comum',            6, 6, 1),

  -- Sensores
  ('HT-S-0001', 'Sensor DHT22',        'DHT22',      120, 'MLB-701', NULL, '2026-04-19', '2026-02-15', '2026-04-19',  95, 1, 1, 'BOM_ESTADO', NULL, 'Sensor de temperatura e umidade DHT22',   7, 7, 1),
  ('HT-S-0002', 'Sensor Ultrassônico', 'HC-SR04',    200, 'MLB-702', NULL, '2026-04-22', '2026-02-15', '2026-04-22', 170, 1, 1, 'BOM_ESTADO', NULL, 'Sensor ultrassônico HC-SR04 2-400cm',    7, 7, 1),
  ('HT-S-0003', 'Sensor MPU6050',      'MPU-6050',    90, 'MLB-703', NULL, '2026-04-16', '2026-02-15', '2026-04-16',  78, 1, 1, 'BOM_ESTADO', NULL, 'Acelerômetro e giroscópio MPU6050',      7, 7, 1),

  -- Reguladores
  ('HT-REG-0001', 'Regulador LM7805',  'LM7805CT',   180, 'MLB-801', NULL, '2026-04-10', '2026-03-01', '2026-04-10', 110, 1, 1, 'BOM_ESTADO', NULL, 'Regulador de tensão +5V 1A TO-220',       8, 10, 1),
  ('HT-REG-0002', 'Regulador LM317',   'LM317T',      95, 'MLB-802', NULL, '2026-04-06', '2026-03-01', '2026-04-06',  70, 1, 1, 'BOM_ESTADO', NULL, 'Regulador de tensão ajustável 1.2-37V',   8, 10, 1),

  -- Circuitos integrados
  ('HT-IC-0001', 'CI NE555',        'NE555P',   280, 'MLB-901', NULL, '2026-04-17', '2026-03-10', '2026-04-17', 190, 1, 1, 'BOM_ESTADO', NULL, 'Timer integrado NE555 DIP-8',                 3, 11, 1),
  ('HT-IC-0002', 'CI LM358',        'LM358N',   210, 'MLB-902', NULL, '2026-04-09', '2026-03-10', '2026-04-09', 140, 1, 1, 'BOM_ESTADO', NULL, 'Amplificador operacional duplo LM358',        3, 11, 1),
  ('HT-IC-0003', 'CI 74HC595',      '74HC595',  160, 'MLB-903', NULL, '2026-03-25', '2026-03-10', '2026-03-25', 105, 0, 1, 'BOM_ESTADO', NULL, 'Shift register 8-bit serial-in/parallel-out', 3, 11, 1),

  -- Componente não visível no catálogo (para teste)
  ('HT-X-0001', 'Protótipo Experimental',  'PROTO-001',  10, NULL, NULL, NULL, '2026-04-01', '2026-04-01', 0, 0, 0, 'EM_OBSERVACAO', 'Em desenvolvimento', 'Componente em fase de testes internos', 7, 11, 0);

-- ─────────────────── Pedidos ───────────────────
INSERT INTO pedido (codigo, nome_comprador, email_comprador, cnpj, tel_celular, status, valor, created_at, updated_at) VALUES
  ('PED-20260401-001', 'Empresa Alpha Eletrônica Ltda',  'compras@alphaeletronica.com.br', '12345678000190', '11987654321', 'CONCLUIDO',   '1250.50', '2026-04-01 10:30:00', '2026-04-03 14:20:00'),
  ('PED-20260405-002', 'Beta Componentes S.A.',          'compras@betacomp.com.br',        '23456789000181', '11912345678', 'CONCLUIDO',   '890.00',  '2026-04-05 09:15:00', '2026-04-07 16:45:00'),
  ('PED-20260412-003', 'Gama Robotics ME',               'contato@gamarobotics.com',       '34567890000172', '21998765432', 'EM_ANDAMENTO','2340.75', '2026-04-12 14:00:00', '2026-04-18 11:30:00'),
  ('PED-20260415-004', 'Delta Maker Space',              'pedidos@deltamaker.com.br',      '45678901000163', '31999887766', 'EM_ANDAMENTO','560.25',  '2026-04-15 16:20:00', '2026-04-20 09:10:00'),
  ('PED-20260420-005', 'Epsilon Automação Industrial',   'suprimentos@epsilonauto.com',    '56789012000154', '11955443322', 'PENDENTE',    '4100.00', '2026-04-20 08:45:00', '2026-04-20 08:45:00'),
  ('PED-20260422-006', 'João da Silva (PF)',             'joao.silva@email.com',           NULL,             '11944556677', 'PENDENTE',    '185.90',  '2026-04-22 19:30:00', '2026-04-22 19:30:00');

-- ─────────────────── Items (ligam pedido a componente) ───────────────────
-- Pedido 1 (CONCLUIDO)
INSERT INTO item (quantidade, fk_pedido, fk_componente) VALUES
  (50,  1, 1),   -- Resistor 1k
  (50,  1, 2),   -- Resistor 10k
  (2,   1, 7),   -- Arduino Uno
  (5,   1, 22),  -- DHT22
  (100, 1, 16);  -- LED vermelho

-- Pedido 2 (CONCLUIDO)
INSERT INTO item (quantidade, fk_pedido, fk_componente) VALUES
  (3,   2, 8),   -- ESP32
  (20,  2, 4),   -- Capacitor 100nF
  (10,  2, 26);  -- NE555

-- Pedido 3 (EM_ANDAMENTO)
INSERT INTO item (quantidade, fk_pedido, fk_componente) VALUES
  (5,   3, 8),   -- ESP32
  (3,   3, 10),  -- Raspberry Pi Pico
  (10,  3, 23),  -- HC-SR04
  (8,   3, 24),  -- MPU6050
  (50,  3, 12);  -- BC547

-- Pedido 4 (EM_ANDAMENTO)
INSERT INTO item (quantidade, fk_pedido, fk_componente) VALUES
  (1,   4, 9),   -- ESP8266
  (30,  4, 19),  -- LED verde
  (10,  4, 15);  -- Mosfet IRFZ44N

-- Pedido 5 (PENDENTE - valor alto)
INSERT INTO item (quantidade, fk_pedido, fk_componente) VALUES
  (20,  5, 7),   -- Arduino Uno
  (15,  5, 11),  -- Arduino Mega
  (30,  5, 8),   -- ESP32
  (5,   5, 25);  -- LM7805

-- Pedido 6 (PENDENTE - cliente PF)
INSERT INTO item (quantidade, fk_pedido, fk_componente) VALUES
  (10,  6, 1),   -- Resistor 1k
  (5,   6, 16),  -- LED vermelho
  (2,   6, 26);  -- NE555

SELECT '✓ Seed concluído' AS status,
       (SELECT COUNT(*) FROM funcao)     AS funcoes,
       (SELECT COUNT(*) FROM usuario)    AS usuarios,
       (SELECT COUNT(*) FROM categoria)  AS categorias,
       (SELECT COUNT(*) FROM caixa)      AS caixas,
       (SELECT COUNT(*) FROM componente) AS componentes,
       (SELECT COUNT(*) FROM pedido)     AS pedidos,
       (SELECT COUNT(*) FROM item)       AS items;
