import 'package:flutter/material.dart';

// Dados fixos do app (Etapa 2: sem API, sem SharedPreferences).
// Tudo aqui foi escrito no código, seguindo o protótipo do Figma Make.

class Transacao {
  final String titulo;
  final String categoria;
  final String data;
  final double valor; // positivo = entrada, negativo = saída
  final String formaPagamento;
  final String? cartao;
  final IconData icone;

  const Transacao({
    required this.titulo,
    required this.categoria,
    required this.data,
    required this.valor,
    required this.formaPagamento,
    required this.icone,
    this.cartao,
  });

  bool get isEntrada => valor >= 0;
}

class CartaoCredito {
  final String nome;
  final String banco;
  final String bandeira;
  final String finalNumero;
  final double limite;
  final double usado;
  final int fechamento;
  final int vencimento;
  final Color cor;
  final String status;
  final List<Transacao> transacoes;

  const CartaoCredito({
    required this.nome,
    required this.banco,
    required this.bandeira,
    required this.finalNumero,
    required this.limite,
    required this.usado,
    required this.fechamento,
    required this.vencimento,
    required this.cor,
    required this.status,
    required this.transacoes,
  });

  double get disponivel => limite - usado;
}

class ContaBancaria {
  final String banco;
  final String tipo;
  final double saldo;
  final Color cor;

  const ContaBancaria({
    required this.banco,
    required this.tipo,
    required this.saldo,
    required this.cor,
  });
}

class Moeda {
  final String codigo;
  final String nome;
  final String simbolo;
  final double cotacaoEmReais; // fixa nesta etapa (a API vem depois)

  const Moeda(this.codigo, this.nome, this.simbolo, this.cotacaoEmReais);
}

class ContaAgendada {
  final int dia;
  final String descricao;
  final double valor;
  final String tipo; // 'receita', 'despesa' ou 'vencimento'

  const ContaAgendada(this.dia, this.descricao, this.valor, this.tipo);
}

// ---------- Início ----------

const nomeUsuario = 'João';
const saldoTotal = 8450.32;
const entradasMes = 4850.00;
const saidasMes = 2430.50;
const cartaoMes = 1280.00;
const tendenciaMes = '+8,4%';

const transacoesRecentes = <Transacao>[
  Transacao(
    titulo: 'Salário',
    categoria: 'Salário',
    data: '05/10/2026',
    valor: 3200.00,
    formaPagamento: 'Transferência',
    icone: Icons.work_outline,
  ),
  Transacao(
    titulo: 'iFood',
    categoria: 'Alimentação',
    data: '05/10/2026',
    valor: -38.90,
    formaPagamento: 'Crédito',
    cartao: 'Nubank',
    icone: Icons.restaurant,
  ),
  Transacao(
    titulo: 'Netflix',
    categoria: 'Assinaturas',
    data: '04/10/2026',
    valor: -39.90,
    formaPagamento: 'Crédito',
    cartao: 'Nubank',
    icone: Icons.tv,
  ),
  Transacao(
    titulo: 'Uber',
    categoria: 'Transporte',
    data: '04/10/2026',
    valor: -24.50,
    formaPagamento: 'Pix',
    icone: Icons.directions_car,
  ),
  Transacao(
    titulo: 'Freelance',
    categoria: 'Freelance',
    data: '02/10/2026',
    valor: 500.00,
    formaPagamento: 'Pix',
    icone: Icons.laptop_mac,
  ),
];

// ---------- Adicionar ----------

const categoriasDespesa = [
  'Alimentação',
  'Transporte',
  'Lazer',
  'Saúde',
  'Moradia',
  'Educação',
  'Compras',
  'Assinaturas',
  'Outros',
];

const categoriasReceita = [
  'Salário',
  'Freelance',
  'Investimentos',
  'Venda',
  'Reembolso',
  'Presente',
  'Outros',
];

const moedas = <Moeda>[
  Moeda('BRL', 'Real brasileiro', 'R\$', 1),
  Moeda('USD', 'Dólar americano', 'US\$', 5.30),
  Moeda('EUR', 'Euro', '€', 5.80),
  Moeda('GBP', 'Libra esterlina', '£', 6.70),
  Moeda('ARS', 'Peso argentino', 'AR\$', 0.006),
  Moeda('JPY', 'Iene', '¥', 0.035),
  Moeda('CAD', 'Dólar canadense', 'CA\$', 3.90),
];

// ---------- Análises ----------

class ResumoMes {
  final String mes;
  final double receita;
  final double despesa;
  const ResumoMes(this.mes, this.receita, this.despesa);
}

const resumoPorPeriodo = <String, List<ResumoMes>>{
  'Mês': [
    ResumoMes('Sem 1', 3400, 620),
    ResumoMes('Sem 2', 0, 780),
    ResumoMes('Sem 3', 500, 540),
    ResumoMes('Sem 4', 0, 900),
  ],
  'Trimestre': [
    ResumoMes('Ago', 4900, 2900),
    ResumoMes('Set', 5200, 2840),
    ResumoMes('Out', 4850, 2430),
  ],
  'Semestre': [
    ResumoMes('Mai', 4800, 3100),
    ResumoMes('Jun', 4500, 2600),
    ResumoMes('Jul', 5100, 3400),
    ResumoMes('Ago', 4900, 2900),
    ResumoMes('Set', 5200, 2840),
    ResumoMes('Out', 4850, 2430),
  ],
  'Ano': [
    ResumoMes('T1', 13200, 8100),
    ResumoMes('T2', 13500, 8500),
    ResumoMes('T3', 15200, 9140),
    ResumoMes('T4', 4850, 2430),
  ],
};

class GastoCategoria {
  final String nome;
  final double valor;
  final Color cor;
  const GastoCategoria(this.nome, this.valor, this.cor);
}

const gastosPorCategoria = <GastoCategoria>[
  GastoCategoria('Moradia', 1200, Color(0xFF22C55E)),
  GastoCategoria('Alimentação', 820, Color(0xFF635BFF)),
  GastoCategoria('Transporte', 540, Color(0xFFFFC107)),
  GastoCategoria('Lazer', 320, Color(0xFFEF4444)),
  GastoCategoria('Outros', 280, Color(0xFF8B5CF6)),
  GastoCategoria('Saúde', 210, Color(0xFF3B82F6)),
];

// ---------- Calendário ----------

const contasAgendadas = <ContaAgendada>[
  ContaAgendada(3, 'Salário', 4500, 'receita'),
  ContaAgendada(10, 'Fatura Nubank', 1280, 'vencimento'),
  ContaAgendada(12, 'Mercado', 320, 'despesa'),
  ContaAgendada(15, 'Fatura Bradesco', 2340, 'vencimento'),
  ContaAgendada(20, 'iFood', 87.50, 'despesa'),
  ContaAgendada(22, 'Freelance', 500, 'receita'),
  ContaAgendada(25, 'Conta de luz', 180, 'vencimento'),
  ContaAgendada(28, 'Academia', 99.90, 'despesa'),
];

const coresTipoConta = <String, Color>{
  'receita': Color(0xFF22C55E),
  'despesa': Color(0xFFEF4444),
  'vencimento': Color(0xFFF59E0B),
};

// ---------- Perfil / Carteira ----------

const perfilNome = 'João Silva';
const perfilEmail = 'joao@email.com';
const perfilTelefone = '+55 11 99999-8888';
const perfilCep = '30140-071';
const perfilEndereco = 'Av. Afonso Pena, 1500 — Centro, Belo Horizonte/MG';
const perfilMoeda = 'BRL — Real';

const contasBancarias = <ContaBancaria>[
  ContaBancaria(
    banco: 'Nubank',
    tipo: 'Conta corrente',
    saldo: 2450.00,
    cor: Color(0xFF8A05BE),
  ),
  ContaBancaria(
    banco: 'Itaú',
    tipo: 'Conta corrente',
    saldo: 3820.00,
    cor: Color(0xFFEC7000),
  ),
  ContaBancaria(
    banco: 'Caixa',
    tipo: 'Poupança',
    saldo: 2180.32,
    cor: Color(0xFF005CA9),
  ),
];

const cartoes = <CartaoCredito>[
  CartaoCredito(
    nome: 'Nubank',
    banco: 'Nubank',
    bandeira: 'Mastercard',
    finalNumero: '4587',
    limite: 5000,
    usado: 1280,
    fechamento: 15,
    vencimento: 22,
    cor: Color(0xFF8A05BE),
    status: 'Ativo',
    transacoes: [
      Transacao(
        titulo: 'iFood',
        categoria: 'Alimentação',
        data: '20/09',
        valor: -87.50,
        formaPagamento: 'Crédito',
        icone: Icons.restaurant,
      ),
      Transacao(
        titulo: 'Spotify',
        categoria: 'Assinaturas',
        data: '18/09',
        valor: -21.90,
        formaPagamento: 'Crédito',
        icone: Icons.music_note,
      ),
      Transacao(
        titulo: 'Decathlon (3x)',
        categoria: 'Esporte',
        data: '15/09',
        valor: -249.00,
        formaPagamento: 'Crédito',
        icone: Icons.sports_soccer,
      ),
    ],
  ),
  CartaoCredito(
    nome: 'Bradesco Prime',
    banco: 'Bradesco',
    bandeira: 'Visa',
    finalNumero: '3291',
    limite: 8000,
    usado: 2340,
    fechamento: 10,
    vencimento: 17,
    cor: Color(0xFFCC0000),
    status: 'Ativo',
    transacoes: [
      Transacao(
        titulo: 'Supermercado Extra',
        categoria: 'Alimentação',
        data: '21/09',
        valor: -320.40,
        formaPagamento: 'Crédito',
        icone: Icons.shopping_cart,
      ),
      Transacao(
        titulo: 'Farmácia',
        categoria: 'Saúde',
        data: '19/09',
        valor: -65.00,
        formaPagamento: 'Crédito',
        icone: Icons.local_pharmacy,
      ),
      Transacao(
        titulo: 'Magazine Luiza (6x)',
        categoria: 'Compras',
        data: '14/09',
        valor: -1200.00,
        formaPagamento: 'Crédito',
        icone: Icons.shopping_bag,
      ),
    ],
  ),
  CartaoCredito(
    nome: 'Itaú Personnalité',
    banco: 'Itaú',
    bandeira: 'Visa',
    finalNumero: '7734',
    limite: 12000,
    usado: 3890,
    fechamento: 20,
    vencimento: 27,
    cor: Color(0xFFEC7000),
    status: 'Ativo',
    transacoes: [
      Transacao(
        titulo: 'Livelo',
        categoria: 'Viagem',
        data: '22/09',
        valor: -580.00,
        formaPagamento: 'Crédito',
        icone: Icons.flight,
      ),
      Transacao(
        titulo: 'Amazon (2x)',
        categoria: 'Compras',
        data: '12/09',
        valor: -450.00,
        formaPagamento: 'Crédito',
        icone: Icons.local_shipping,
      ),
    ],
  ),
  CartaoCredito(
    nome: 'C6 Bank',
    banco: 'C6 Bank',
    bandeira: 'Mastercard',
    finalNumero: '1103',
    limite: 3000,
    usado: 450,
    fechamento: 5,
    vencimento: 12,
    cor: Color(0xFF242424),
    status: 'Bloqueado',
    transacoes: [
      Transacao(
        titulo: 'Posto Shell',
        categoria: 'Transporte',
        data: '03/09',
        valor: -120.00,
        formaPagamento: 'Crédito',
        icone: Icons.local_gas_station,
      ),
    ],
  ),
];
