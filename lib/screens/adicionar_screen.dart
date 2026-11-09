// Tela 3 — Adicionar (entrada, saída ou cartão)
// Responsável: Theo Purcino

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dados_fake.dart';
import '../providers/cotacoes_provider.dart';
import '../providers/transacoes_provider.dart';
import '../theme/app_theme.dart';

class AdicionarScreen extends StatefulWidget {
  const AdicionarScreen({super.key});

  @override
  State<AdicionarScreen> createState() => _AdicionarScreenState();
}

class _AdicionarScreenState extends State<AdicionarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool _isDespesa = true;
  String? _categoria;
  Moeda _moeda = moedas.first;
  String _pagamento = 'Pix';
  String? _cartao;

  static const _formasPagamento = [
    'Pix',
    'Dinheiro',
    'Débito',
    'Crédito',
    'Transferência',
    'Boleto',
  ];

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  double? get _valorDigitado =>
      double.tryParse(_valorController.text.replaceAll(',', '.'));

  void _escolherMoeda() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: moedas.length,
            itemBuilder: (context, i) {
              final m = moedas[i];
              final selecionada = m.codigo == _moeda.codigo;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    m.simbolo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(m.codigo),
                subtitle: Text(m.nome),
                trailing: selecionada
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _moeda = m);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final valor = _valorDigitado!;
    final taxa = context.read<CotacoesProvider>().valorEmReais(_moeda);
    final emReais = valor * taxa;
    final hoje = DateTime.now();
    final data = '${hoje.day.toString().padLeft(2, '0')}/'
        '${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';

    final transacao = Transacao(
      titulo: _descricaoController.text.trim(),
      categoria: _categoria!,
      data: data,
      valor: _isDespesa ? -emReais : emReais,
      formaPagamento: _pagamento,
      cartao: _pagamento == 'Crédito' ? _cartao : null,
      icone: iconeDaCategoria(_categoria!),
      moeda: _moeda.codigo,
      valorOriginal: _moeda.codigo == 'BRL' ? null : valor,
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // Provider adiciona na lista e salva no SharedPreferences.
    await context.read<TransacoesProvider>().adicionar(transacao);

    messenger.showSnackBar(
      SnackBar(
        content: Text(_isDespesa ? 'Despesa lançada.' : 'Receita lançada.'),
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cotacoes = context.watch<CotacoesProvider>();
    final categorias = _isDespesa ? categoriasDespesa : categoriasReceita;
    final valor = _valorDigitado;
    final taxa = cotacoes.valorEmReais(_moeda);
    final aoVivo = cotacoes.temCotacaoAoVivo(_moeda.codigo);
    final convertido =
        (valor != null && _moeda.codigo != 'BRL') ? valor * taxa : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo lançamento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Despesa'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Receita'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_isDespesa},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((estados) {
                  if (!estados.contains(WidgetState.selected)) return null;
                  return _isDespesa ? AppColors.error : AppColors.success;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((estados) {
                  return estados.contains(WidgetState.selected)
                      ? Colors.white
                      : AppColors.mutedForeground;
                }),
              ),
              onSelectionChanged: (selecao) {
                setState(() {
                  _isDespesa = selecao.first;
                  _categoria = null;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: _Rotulo('Valor')),
                TextButton.icon(
                  onPressed: _escolherMoeda,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.expand_more, size: 18),
                  label: Text(_moeda.codigo),
                ),
              ],
            ),
            TextFormField(
              controller: _valorController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0,00',
                prefixText: '${_moeda.simbolo} ',
              ),
              onChanged: (_) => setState(() {}),
              validator: (texto) {
                if (texto == null || texto.trim().isEmpty) {
                  return 'Informe o valor.';
                }
                final numero = double.tryParse(texto.replaceAll(',', '.'));
                if (numero == null || numero <= 0) {
                  return 'Digite um valor maior que zero.';
                }
                return null;
              },
            ),
            if (convertido != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '≈ ${formatarReais(convertido)} · '
                  '${aoVivo ? 'Cotação de hoje (AwesomeAPI)' : 'Taxa de referência (API indisponível)'}: '
                  '1 ${_moeda.codigo} = ${formatarReais(taxa)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const _Rotulo('Descrição'),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                hintText: 'Ex: Mercado, Uber, Salário…',
              ),
              validator: (texto) {
                if (texto == null || texto.trim().isEmpty) {
                  return 'Informe uma descrição.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const _Rotulo('Categoria'),
            DropdownButtonFormField<String>(
              // A key força recriar o campo ao trocar despesa/receita.
              key: ValueKey(_isDespesa),
              initialValue: _categoria,
              hint: const Text('Selecione'),
              items: [
                for (final c in categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (c) => setState(() => _categoria = c),
              validator: (c) => c == null ? 'Escolha uma categoria.' : null,
            ),
            const SizedBox(height: 20),
            const _Rotulo('Forma de pagamento'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final forma in _formasPagamento)
                  ChoiceChip(
                    label: Text(forma),
                    selected: _pagamento == forma,
                    onSelected: (_) => setState(() => _pagamento = forma),
                  ),
              ],
            ),
            if (_pagamento == 'Crédito') ...[
              const SizedBox(height: 20),
              const _Rotulo('Cartão'),
              DropdownButtonFormField<String>(
                initialValue: _cartao,
                hint: const Text('Selecione o cartão'),
                items: [
                  for (final c in cartoes)
                    DropdownMenuItem(value: c.nome, child: Text(c.nome)),
                ],
                onChanged: (c) => setState(() => _cartao = c),
                validator: (c) => c == null ? 'Escolha o cartão.' : null,
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _salvar,
              child: Text(_isDespesa ? 'Salvar despesa' : 'Salvar receita'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
