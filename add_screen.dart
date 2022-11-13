import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sqflite_todos/models/todo_model.dart';
import 'package:flutter_sqflite_todos/extensions/string_extension.dart';
import 'package:flutter_sqflite_todos/services/database_service.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  final VoidCallback updateTodos;
  final Todo? todo;

  const AddTodoScreen({
    required this.updateTodos,
    this.todo,
  });

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;

  Todo? _todo;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _todo = widget.todo;
    } else {
      _todo = Todo(
        name: '',
        price: '',
        priorityLevel: PriorityLevel.Food,
        completed: false,
      );
    }

    _nameController = TextEditingController(text: _todo!.name);
    _priceController = TextEditingController(text: _todo!.price);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(!_isEditing ? 'Add item' : 'Update item'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 40.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 16.0),
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Please enter a name' : null,
                  onSaved: (value) => _todo = _todo!.copyWith(name: value),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _priceController,
                  style: const TextStyle(fontSize: 16.0),
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) =>
                  value!.trim().isEmpty ? 'Please enter the item price' : null,
                  onSaved: (value) => _todo = _todo!.copyWith(price: value),
                ),
                const SizedBox(height: 32.0),
                DropdownButtonFormField<PriorityLevel>(
                  value: _todo!.priorityLevel,
                  icon: const Icon(Icons.arrow_drop_down_circle),
                  iconSize: 22.0,
                  iconEnabledColor: Theme.of(context).primaryColor,
                  items: PriorityLevel.values
                      .map((priorityLevel) => DropdownMenuItem(
                            value: priorityLevel,
                            child: Text(
                              EnumToString.convertToString(priorityLevel)
                                  .capitalize(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          ))
                      .toList(),
                  style: const TextStyle(fontSize: 16.0),
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                  onChanged: (value) => setState(
                    () => _todo = _todo!.copyWith(priorityLevel: value),
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    primary: !_isEditing ? Colors.green : Colors.orange,
                    minimumSize: const Size.fromHeight(45.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    !_isEditing ? 'Add' : 'Save',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () {
                      DatabaseService.instance.delete(_todo!.id!);
                      widget.updateTodos();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (!_isEditing) {
        DatabaseService.instance.insert(_todo!);
      } else {
        DatabaseService.instance.update(_todo!);
      }

      widget.updateTodos();

      Navigator.of(context).pop();
    }
  }
}
