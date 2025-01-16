import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noteapp/main.dart';

void main() {
  testWidgets('Add new note test', (WidgetTester tester) async {
    // Build the NoteApp and trigger a frame.
    await tester.pumpWidget(NoteApp());

    // Verify that the note list is initially empty.
    expect(find.text('No notes yet'), findsNothing);

    // Tap the FloatingActionButton to add a new note.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter text in the title and content fields.
    await tester.enterText(find.bySemanticsLabel('Title'), 'Test Note Title');
    await tester.enterText(find.bySemanticsLabel('Content'), 'Test Note Content');

    // Tap the 'Save' button.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify that the new note appears in the list.
    expect(find.text('Test Note Title'), findsOneWidget);
    expect(find.text('Test Note Content'), findsOneWidget);
  });
}
