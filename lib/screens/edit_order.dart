import 'package:flutter/material.dart';
import 'package:text_editor/components/draggable_text.dart';

class EditOrderPage extends StatefulWidget {
  final List<List<DraggableText>> pages;
  final List<Color> backgroundColors;
  final Function(List<List<DraggableText>>, List<Color>) onReorder;
  final Function(List<List<DraggableText>>, List<Color>) onUpdatePages;
  final Function() onAddPage;

  const EditOrderPage({
    super.key,
    required this.pages,
    required this.backgroundColors,
    required this.onReorder,
    required this.onUpdatePages,
    required this.onAddPage,
  });

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late List<List<DraggableText>> _pages;
  late List<Color> _backgroundColors;

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.pages);
    _backgroundColors = List.from(widget.backgroundColors);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final page = _pages.removeAt(oldIndex);
      final color = _backgroundColors.removeAt(oldIndex);
      _pages.insert(newIndex, page);
      _backgroundColors.insert(newIndex, color);
    });
    widget.onReorder(_pages, _backgroundColors);
  }

  void _addPage() {
    setState(() {
      _pages.add([]);
      _backgroundColors.add(Colors.white);
    });
    widget.onAddPage();
  }

  void _deletePage(int index) {
    setState(() {
      _pages.removeAt(index);
      _backgroundColors.removeAt(index);
    });
    widget.onUpdatePages(_pages, _backgroundColors);
  }

  void _saveOrder() {
    widget.onReorder(_pages, _backgroundColors);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // Ensure the icons are visible
        title: const Text('Edit Page Order', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              onReorder: _onReorder,
              children: List.generate(
                _pages.length,
                (index) {
                  return Container(
                    key: ValueKey(index),
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                                child: Container(
                                width: 40,
                                height: 60,
                                margin: const EdgeInsets.only(right: 8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 2),
                                  color: _backgroundColors[index],
                                ),
                                ),
                            ),
                            Text('Page ${index + 1}'),
                          ],
                        ),
                      ),
                      tileColor: Colors.white,
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_indicator),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePage(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addPage, child: Icon(Icons.add),backgroundColor: Colors.white,),
    );
  }
}