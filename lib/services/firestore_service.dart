import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_editor/components/draggable_text.dart';


Future<void> saveDataToFirestore(
    String documentId,
    List<List<DraggableText>> pages,
    List<List<List<DraggableText>>> undoStack,
    List<List<List<DraggableText>>> redoStack) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Convert the data to maps
    List<List<Map<String, dynamic>>> serializedPages = pages
        .map((page) => page.map((text) => text.toMap()).toList())
        .toList();

    List<List<List<Map<String, dynamic>>>> serializedUndoStack = undoStack
        .map((undo) =>
            undo.map((page) => page.map((text) => text.toMap()).toList()).toList())
        .toList();

    List<List<List<Map<String, dynamic>>>> serializedRedoStack = redoStack
        .map((redo) =>
            redo.map((page) => page.map((text) => text.toMap()).toList()).toList())
        .toList();

    // Save to Firestore
    await firestore.collection('your_collection').doc(documentId).set({
      'pages': serializedPages,
      'undoStack': serializedUndoStack,
      'redoStack': serializedRedoStack,
    });

    print("Data saved successfully!");
  } catch (e) {
    print("Error saving data: $e");
  }
}

