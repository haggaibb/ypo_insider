import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Lines { single, multi }

enum FieldType { text, link, email, phone, multi }

class RayBarTextField extends StatelessWidget {
  final TextEditingController controller;
  final Lines lines;
  final String label;
  final TextStyle? displayLabelStyle;
  final IconData? icon;
  final Widget? imageIcon;
  final bool? enableIcon;
  final FieldType? type;
  final double? fieldWidth;
  final bool editMode;
  final String? url;
  final int? maxLines;
  final int? minLines;
  final String? helperText;
  final String? hintText;
  final EdgeInsets? padding;

//
  const RayBarTextField({
    required this.controller,
    required this.lines,
    required this.label,
    this.displayLabelStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.icon,
    this.imageIcon,
    this.enableIcon = false,
    this.type = FieldType.text,
    this.fieldWidth = 200,
    required this.editMode,
    this.url,
    this.maxLines = 1,
    this.minLines = 1,
    this.helperText,
    this.hintText = '',
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (lines) {
      case Lines.single:
        return Padding(
          padding: padding ??
              const EdgeInsets.only(left: 0, right: 0, bottom: 8, top: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RayBarCustomFieldLabel(
                labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                label: label,
                icon: icon,
                imageIcon: imageIcon,
                enableIcon: enableIcon,
                editMode: editMode,
              ),
              SizedBox(
                width: fieldWidth,
                height: editMode ? 60 : 18,
                child: GestureDetector(
                  onTap: () {
                    print('click');
                    (type == FieldType.link && !editMode)
                        ? html.window.open(controller.text, 'new tab')
                        : null;
                  },
                  child: RayBarCustomTextField(
                      controller: controller,
                      enabled: editMode,
                      label: label,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      style: TextStyle(
                          color: type == FieldType.link
                              ? Colors.blue
                              : Colors.black),
                      helperText: helperText,
                      icon: icon,
                      hintText: hintText),
                ),
              )
            ],
          ),
        );
        break;
      case Lines.multi:
        return Padding(
          padding: padding ??
              const EdgeInsets.only(left: 8, right: 0, bottom: 8, top: 0),
          child: SizedBox(
            height: editMode ? maxLines! * 40 : maxLines! * 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RayBarCustomFieldLabel(
                  label: label,
                  icon: icon,
                  editMode: editMode,
                  enableIcon: true,
                ),
                RayBarCustomTextField(
                  controller: controller,
                  type: FieldType.multi,
                  label: label,
                  maxLines: maxLines!,
                  enabled: editMode,
                  helperText: helperText,
                  hintText: hintText,
                  icon: icon,
                )
              ],
            ),
          ),
        );
        break;
    }
  }
}

///
class RayBarDropdownMenu extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? initialSelection;
  final InputDecorationTheme? inputDecorationTheme;
  final List<DropdownMenuEntry> dropdownMenuEntries;
  final EdgeInsets? padding;
  final IconData? icon;
  final bool? enableIcon;
  final Widget? imageIcon;
  final double? fieldWidth;
  final bool editMode;
  final FieldType? type;
  final String? helperText;
  final String? hintText;
  final TextStyle? displayLabelStyle;
  final Function(dynamic) onSelected;

  ///
  const RayBarDropdownMenu({
    required this.controller,
    required this.label,
    required this.dropdownMenuEntries,
    required this.editMode,
    this.initialSelection,
    this.inputDecorationTheme,
    this.padding,
    this.icon,
    this.enableIcon = false,
    this.imageIcon,
    this.fieldWidth = 200,
    this.type = FieldType.text,
    this.helperText,
    this.hintText,
    this.displayLabelStyle,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.only(left: 8, right: 0, bottom: 8, top: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RayBarCustomFieldLabel(
            label: label,
            labelStyle: displayLabelStyle,
            icon: icon,
            enableIcon: enableIcon,
            editMode: editMode,
          ),
          SizedBox(
            width: editMode ? fieldWidth : fieldWidth! * 0.5,
            height: editMode ? 10 : 0,
            child: Padding(
              padding: editMode
                  ? EdgeInsets.only(left: 40, bottom: 0)
                  : EdgeInsets.only(),
              child: RayBarCustomDropdownMenu(
                onSelected: onSelected,
                  width: fieldWidth,
                  controller: controller,
                  dropdownMenuEntries: dropdownMenuEntries,
                  editMode: editMode,
                  label: label,
                  leadingIcon: icon,
                  style: TextStyle(
                      color: type == FieldType.link
                          ? Colors.blue
                          : Colors.black),
                  helperText: helperText,
                  //leadingIcon: enableIcon!?icon!:null,
                  hintText: hintText),
            ),
          )
        ],
      ),
    );
  }
}

///
typedef OnChangeCallback = void Function(List<String> selectedTags);

class RayBarMultiChipMenu extends StatefulWidget {
  final String label;
  final TextStyle? labelTextStyle;
  final List<String> tags;
  final List<String>? selectedTags;
  final bool editMode;
  final OnChangeCallback? onChange;
  final InputDecorationTheme? inputDecorationTheme;
  final EdgeInsets? padding;
  final IconData? icon;
  final String? helperText;
  final String? hintText;

  ///
  const RayBarMultiChipMenu({
    required this.tags,
    this.selectedTags = const [],
    required this.label,
    this.labelTextStyle,
    required this.editMode,
    this.onChange,
    this.inputDecorationTheme,
    this.padding,
    this.icon,
    this.helperText,
    this.hintText,
    super.key,
  });

  @override
  State<RayBarMultiChipMenu> createState() => _RayBarMultiChipMenuState();
}

class _RayBarMultiChipMenuState extends State<RayBarMultiChipMenu> {
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = widget.tags;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0, top: widget.editMode ? 50 : 0),
      child: SizedBox(
        width: 300,
        height: widget.tags.length / 3 * 200,
        child: Card(
          elevation: 5,
          child: Column(
            children: [
              ListTile(
                title: Text(widget.label, style: widget.labelTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Wrap(
                    runSpacing: 8,
                    spacing: 10,
                    children: List.generate(
                        widget.tags.length,
                        (tagIndex) => widget.editMode
                            ? ChoiceChip(
                                onSelected: (val) {
                                  if (widget.editMode) {
                                    setState(() {
                                      if (widget.selectedTags!
                                          .contains(_tags[tagIndex])) {
                                        widget.selectedTags!
                                            .remove(_tags[tagIndex]);
                                      } else {
                                        widget.selectedTags!
                                            .add(_tags[tagIndex]);
                                      }
                                    });
                                    widget.onChange!(widget.selectedTags!);
                                  }
                                },
                                label: Text(_tags[tagIndex]),
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                selected: widget.selectedTags!
                                    .contains(_tags[tagIndex]))
                            : widget.selectedTags!.contains(_tags[tagIndex])
                                ? ChoiceChip(
                                    onSelected: (val) {
                                      if (widget.editMode) {
                                        setState(() {
                                          if (widget.selectedTags!
                                              .contains(_tags[tagIndex])) {
                                            widget.selectedTags!
                                                .remove(_tags[tagIndex]);
                                          } else {
                                            widget.selectedTags!
                                                .add(_tags[tagIndex]);
                                          }
                                        });
                                      }
                                    },
                                    label: Text(_tags[tagIndex]),
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    selected: widget.selectedTags!
                                        .contains(_tags[tagIndex]))
                                : SizedBox(
                                    width: 1,
                                  ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
class RayBarCustomTextField extends TextField {
  RayBarCustomTextField(
      {super.key,
      required TextEditingController super.controller,
      FieldType type = FieldType.text,
      String label = '',
      int super.maxLines = 1,
      int super.minLines = 1,
      String? helperText,
      TextStyle? style = const TextStyle(color: Colors.black),
      TextStyle? labelStyle,
      TextAlign? textAlign,
      String? hintText,
      IconData? icon,
        bool? editMode,
      super.enabled,
      super.textDirection,
      BorderRadius? borderRadius})
      : super(
          style: style,
          textAlign: textAlign = TextAlign.start,
          decoration: InputDecoration(
            icon: enabled! ? Icon(icon) : null,
            contentPadding: enabled
                ? const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8)
                : maxLines > 1
                    ? const EdgeInsets.only(
                        left: 30, right: 30, top: 0, bottom: 0.0)
                    : EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0.0),
            isCollapsed: true,
            labelText: enabled ? label : '',
            labelStyle: labelStyle,
            helperText: enabled ? helperText : null,
            hintText: hintText,
            floatingLabelBehavior: enabled
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderSide: enabled ? BorderSide() : BorderSide.none,
              borderRadius: borderRadius = BorderRadius.circular(5.0),
            ),
          ),
        );
}

///
class RayBarCustomDropdownMenu extends DropdownMenu {
  RayBarCustomDropdownMenu(
      {super.key,
      required TextEditingController super.controller,
      required List<DropdownMenuEntry> dropdownMenuEntries,
      FieldType type = FieldType.text,
      String? label,
      String? helperText,
      TextStyle? style = const TextStyle(fontSize: 3, color: Colors.black),
      TextAlign? textAlign,
      String? hintText,
      IconData? leadingIcon,
        required editMode,
      Function(dynamic)? onSelected,
      double? width,
      BorderRadius? borderRadius})
      : super(
            width: width,
            dropdownMenuEntries: dropdownMenuEntries,
            onSelected: onSelected,
            textStyle: style,
            enabled: editMode,
            initialSelection: controller.text,
            label: editMode ? Text(label ?? '') : null,
            trailingIcon: editMode? Icon(Icons.arrow_drop_down) : null,
            leadingIcon: editMode ? Icon(leadingIcon) : null,
            inputDecorationTheme: InputDecorationTheme(
              filled: false,
              isDense: true,
              constraints: editMode
                  ? null
                  : BoxConstraints.tight(const Size.fromHeight(22)),
              disabledBorder: InputBorder.none,
              suffixIconColor: editMode ? Colors.black : Colors.transparent,
              border: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: borderRadius = BorderRadius.circular(5.0),
              ),
              contentPadding: editMode
                  ? EdgeInsets.symmetric(vertical: 5.0)
                  : EdgeInsets.only(right: 0, left: 0, top: 0, bottom: 0),
              //outlineBorder: BorderSide(color:  Colors.blue),
            )
            //inputDecorationTheme:
            );
}
///
class RayBarCustomFieldLabel extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? imageIcon;
  final bool? enableIcon;
  final bool editMode;
  final TextStyle? labelStyle;

  const RayBarCustomFieldLabel(
      {super.key,
      required this.label,
      this.icon,
        this.imageIcon,
      required this.editMode,
      this.labelStyle = const TextStyle(color: Colors.black, fontSize: 16),
      this.enableIcon = false});

  Widget build(BuildContext context) {
    return editMode
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: enableIcon!
                    ? imageIcon!=null?imageIcon:Icon(icon, color: Colors.blue.shade900,)
                    : const SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  style: labelStyle,
                  '$label:',
                ),
              ),
            ],
          );
  }
}

///
typedef OnChangeMultiFieldCallback = void Function(Map<String,dynamic> dataMap);

class RayBarMultiField extends StatefulWidget {
  final List<String> keysPerEntry;
  final List<Map<String,dynamic>>? entries;
  final String label;
  final bool editMode;
  final OnChangeMultiFieldCallback? onChangeMultiFieldCallback;
  final String? initialSelection;
  final InputDecorationTheme? inputDecorationTheme;
  final EdgeInsets? padding;
  final IconData? icon;
  final Color? iconColor;
  final bool? enableIcon;
  final double? fieldWidth;
  final FieldType? type;
  final String? helperText;
  final String? hintText;

  ///
  const RayBarMultiField({
    required this.keysPerEntry,
    this.entries = const [],
    required this.label,
    required this.editMode,
    this.onChangeMultiFieldCallback,
    this.initialSelection,
    this.inputDecorationTheme,
    this.padding,
    this.icon,
    this.iconColor,
    this.enableIcon = false,
    this.fieldWidth = 100,
    this.type = FieldType.text,
    this.helperText,
    this.hintText,
    super.key,
  });

  @override
  State<RayBarMultiField> createState() => _RayBarMultiFieldState();
}
class Field{
  String key;
  String value;
  String get validKey => key.toLowerCase().replaceAll(' ', '_');
  Field(this.key, this.value);
  @override
  String toString() {
    return '{ ${this.key}, ${this.value} }';
  }
}

class EntryDialog extends StatelessWidget {
  final List<String> keysPerEntry;
  final double? fieldWidth;
  const EntryDialog( {super.key, this.fieldWidth=100, required this.keysPerEntry});
  @override
  Widget build(BuildContext context) {
    List<TextEditingController> fieldsList = List.generate(
        keysPerEntry.length, (index) => TextEditingController());

    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 80.0, top: 20),
      title: const Text('Add Entry'),
      content:
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(keysPerEntry.length,
                (fieldIndex) =>
                SizedBox(
                  width: fieldWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextField(
                        controller: fieldsList[fieldIndex],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8),
                          isCollapsed: true,
                          labelText: keysPerEntry[fieldIndex],
                          //helperText: helperText:'',
                          //hintText:   widget.hintText,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        )

                    ),
                  ),
                )

        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, fieldsList),
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
///
class _RayBarMultiFieldState extends State<RayBarMultiField> {
  List<TextEditingController> controllerEntryFiledList =
      List.empty(growable: true);
  List<List<TextEditingController>> controllerEntryList =
      List.empty(growable: true);
  Map<String,dynamic> dataMap={};
  onAddEntry() async {
    List<TextEditingController>? res = await showDialog<List<TextEditingController>>(
          context: context,
          builder: (BuildContext context) =>
              EntryDialog(
                keysPerEntry:widget.keysPerEntry,
                fieldWidth: widget.fieldWidth,
              )
      );
    setState(() {
      if (res!=null) {
        controllerEntryList.add(res);
        dataMap = buildMap();
        widget.onChangeMultiFieldCallback!(dataMap);
      }
    });
  }
  onRemove(int entryIndex) {
    setState(() {
      controllerEntryList.removeAt(entryIndex);
    });
    dataMap = buildMap();
    widget.onChangeMultiFieldCallback!(dataMap);
  }
  Map<String,dynamic> buildMap() {
    String label = widget.label.toLowerCase().replaceAll(' ', '_');
    Map<String,dynamic> map = {
      label : []
    };
    for (var entryIndex=0; entryIndex<controllerEntryList.length;entryIndex++) {
      List<Field> entryFields = [];
      for (var fieldIndex=0; fieldIndex<controllerEntryList[entryIndex].length;fieldIndex++) {
        entryFields.add(Field(widget.keysPerEntry[fieldIndex],controllerEntryList[entryIndex][fieldIndex].text));
      }
      var map2 = {};
      for (var field in entryFields) {
        map2[field.validKey] = field.value;
      }
      //print(map2);
      map[label].add(map2);
    }
    dataMap = map;
    return map;
  }

  @override
  void initState() {

    super.initState();
    if (widget.entries!=null) {
      if (widget.entries!.isNotEmpty) {
        for (Map<String,dynamic> entry in widget.entries!) {
          List<TextEditingController> fieldsList = List.generate(
              widget.keysPerEntry.length, (index)  {
            TextEditingController ctx = TextEditingController();
            var key = widget.keysPerEntry[index].toLowerCase().replaceAll(' ', '_');
            ctx.text = entry[key];
            return ctx;
          } );
          controllerEntryList.add(fieldsList);
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0.0, right:0, top:0,bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(widget.icon, color: widget.iconColor,),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text(widget.label , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                ),
                widget.editMode?IconButton(
                    onPressed: () {
                      setState(() {
                        onAddEntry();
                      });
                      },
                    icon: Icon(Icons.add)):SizedBox()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:40.0),
            child: Column(
              children: List.generate(
                  controllerEntryList.length,
                  (entryIndex) => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.editMode?IconButton(
                          onPressed: () {
                            onRemove(entryIndex);
                          },
                          icon: Icon(color: Colors.red, Icons.remove_circle_outline_sharp)):SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(widget.keysPerEntry.length,
                                (fieldIndex) =>
                                    SizedBox(
                                      width: widget.fieldWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: TextField(
                                          onChanged: (val) {
                                            widget.onChangeMultiFieldCallback!(buildMap());
                                        },
                                          controller: controllerEntryList[entryIndex][fieldIndex],
                                            decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                                            isCollapsed: true,
                                            labelText: widget.keysPerEntry[fieldIndex],
                                            helperText: widget.editMode?widget.helperText:'',
                                            hintText:    widget.editMode?widget.hintText:'',
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                          )

                                        ),
                                      ),
                                    )

                            ),
                          ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
