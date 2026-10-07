import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grana_mais/main.dart';
import 'package:grana_mais/screens/adicionar_screen.dart';

void main() {
  testWidgets('login valida e percorre as abas sem crashar', (tester) async {
    await tester.pumpWidget(const GranaMaisApp());

    // Formulário vazio -> validator reclama
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe seu nome de usuário.'), findsOneWidget);

    // Preenchido -> abre o Início
    await tester.enterText(find.byType(TextFormField).at(0), 'joao');
    await tester.enterText(find.byType(TextFormField).at(1), '1234');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, João'), findsOneWidget);

    // Lista -> detalhe -> volta
    final netflix = find.text('Netflix');
    await tester.scrollUntilVisible(netflix, 200);
    // Centraliza o item para não ficar atrás do menu inferior.
    await tester.runAsync(() => Scrollable.ensureVisible(
          tester.element(netflix),
          alignment: 0.5,
        ));
    await tester.pumpAndSettle();
    await tester.tap(netflix);
    await tester.pumpAndSettle();
    expect(find.text('Detalhe da movimentação'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Abas do menu inferior
    for (final aba in ['Análises', 'Calendário', 'Perfil', 'Início']) {
      await tester.tap(find.text(aba).last);
      await tester.pumpAndSettle();
    }

    // Botão + abre Adicionar
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('Novo lançamento'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Salvar despesa'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(AdicionarScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Salvar despesa'));
    await tester.pump();
    expect(find.text('Informe o valor.'), findsOneWidget);
  });
}
