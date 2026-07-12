# Shared Widgets

Shared widgets live in `lib/widgets/`. They keep feature modules focused on their own behaviour and prevent UI duplication.

## Shared Components

- Buttons: `app_button.dart`, `custom_button.dart`, and `app_icon_button.dart`
- Search: `app_search_bar.dart`
- Controls: `app_segmented_triple_control.dart` and `scroll_to_top_button.dart`
- Feedback: `confirm_dialog.dart` and `error_message.dart`
- Camera preview: `inline_camera_preview.dart`

Keep a widget inside its feature module when it is used only by that feature; move it to `lib/widgets/` only once it represents a reusable app-wide component.
