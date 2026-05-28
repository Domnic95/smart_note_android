import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Define DragSelectionUpdateCallback type
typedef DragSelectionUpdateCallback = void Function(
  DragStartDetails startDetails,
  DragUpdateDetails updateDetails,
);

// Implement TextInputClient methods
mixin CustomTextInputClient implements TextInputClient {
  @override
  void updateEditingValue(TextEditingValue value) {}

  @override
  void performAction(TextInputAction action) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void connectionClosed() {}

  @override
  void insertContent(KeyboardInsertedContent content) {}

  bool get liveTextInputEnabled => false;

  bool get lookUpEnabled => true;

  bool get searchWebEnabled => true;

  bool get shareEnabled => true;
}

// Implement RawEditorState class
class RawEditorState extends State<EditableText>
    with
        AutomaticKeepAliveClientMixin,
        CustomTextInputClient,
        TextSelectionDelegate {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(); // Replace with actual widget tree
  }

  @override
  bool get wantKeepAlive => true;

  @override
  TextEditingValue get currentTextEditingValue => const TextEditingValue();

  @override
  void bringIntoView(TextPosition position) {}

  @override
  void hideToolbar(
      [bool hideHandles = true]) {} // Updated to match the expected signature

  @override
  Future<void> pasteText(
      SelectionChangedCause
          cause) async {} // Updated to match the expected signature

  @override
  void cutSelection(SelectionChangedCause cause) {}

  @override
  void copySelection(SelectionChangedCause cause) {}

  @override
  void selectAll(SelectionChangedCause cause) {}

  @override
  void userUpdateTextEditingValue(
      TextEditingValue value, SelectionChangedCause cause) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
