import 'package:chitchat/common/extension/custom_theme_extension.dart';
import 'package:chitchat/common/utils/coloors.dart';
import 'package:chitchat/common/widgets/custom_icon_button.dart';
import 'package:chitchat/feature/auth/pages/image_picker_page.dart';
import 'package:chitchat/feature/chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chitchat/common/enum/message_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatTextField extends ConsumerStatefulWidget {
  const ChatTextField({
    super.key,
    required this.receiverId,
    required this.scrollController,
  });

  final String receiverId;
  final ScrollController scrollController;

  @override
  ConsumerState<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends ConsumerState<ChatTextField> {
  late TextEditingController messageController;
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  bool isMessageIconEnabled = false;
  double cardHeight = 0;

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // طلب الأذونات الديناميكية
  Future<void> requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // إرسال الملفات من الجهاز
  void sendFileMessageFromDevice() async {
    await requestPermission(Permission.storage);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      sendFileMessage(result.files.first.path, MessageType.text);
      setState(() => cardHeight = 0);
    }
  }

  // إرسال صورة أو فيديو من الكاميرا
  void sendImageOrVideoFromCamera() async {
    await requestPermission(Permission.camera);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && pickedFile.path.isNotEmpty) {
      sendFileMessage(pickedFile.path, MessageType.image);
      setState(() => cardHeight = 0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image or video selected.')),
      );
    }
  }

  // إرسال صورة من المعرض
  void sendImageMessageFromGallery() async {
    final image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ImagePickerPage(),
      ),
    );

    if (image != null) {
      sendFileMessage(image, MessageType.image);
      setState(() => cardHeight = 0);
    }
  }

  // إرسال الموقع الحالي
  void sendLocationMessage() async {
    await requestPermission(Permission.location);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String locationUrl = "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    sendTextMessage(locationUrl);
    setState(() => cardHeight = 0);
  }

  // إرسال جهة اتصال
  void sendContactMessage() async {
    try {
      await requestPermission(Permission.contacts);
      Contact? contact = await _contactPicker.selectContact();
      if (contact != null) {
        String contactMessage =
            "${contact.fullName}: ${contact.phoneNumbers!.isNotEmpty ? contact.phoneNumbers?.first : ''}";
        sendTextMessage(contactMessage);
        setState(() => cardHeight = 0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick contact: $e')),
      );
    }
  }

  void sendFileMessage(String? filePath, MessageType messageType) async {
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File path is invalid.')),
      );
      return;
    }

    ref.read(chatControllerProvider).sendFileMessage(
          context,
          filePath,
          widget.receiverId,
          messageType,
        );
    await Future.delayed(const Duration(milliseconds: 500));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void sendTextMessage([String? text]) async {
    if (isMessageIconEnabled || text != null) {
      ref.read(chatControllerProvider).sendTextMessage(
            context: context,
            textMessage: text ?? messageController.text,
            receiverId: widget.receiverId,
          );
      messageController.clear();
    }

    await Future.delayed(const Duration(milliseconds: 100));
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  iconWithText({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required Color background,
  }) {
    return Column(
      children: [
        CustomIconButton(
          onPressed: () {
            onPressed();
            setState(() => cardHeight = 0);
          },
          icon: icon,
          background: background,
          minWidth: 50,
          iconColor: Colors.white,
          border: Border.all(
            color: context.theme.greyColor!.withOpacity(.2),
            width: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            color: context.theme.greyColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: cardHeight,
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: context.theme.receiverChatCardBg,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                iconWithText(
                  onPressed: sendFileMessageFromDevice,
                  icon: Icons.attach_file,
                  text: 'File',
                  background: const Color(0xFF7F66FE),
                ),
                iconWithText(
                  onPressed: sendImageOrVideoFromCamera,
                  icon: Icons.camera_alt,
                  text: 'Camera',
                  background: const Color(0xFFFE2E74),
                ),
                iconWithText(
                  onPressed: sendImageMessageFromGallery,
                  icon: Icons.photo,
                  text: 'Gallery',
                  background: const Color(0xFFC861F9),
                ),
                iconWithText(
                  onPressed: sendLocationMessage,
                  icon: Icons.location_on,
                  text: 'Location',
                  background: const Color(0xFF1FA855),
                ),
                iconWithText(
                  onPressed: sendContactMessage,
                  icon: Icons.person,
                  text: 'Contact',
                  background: const Color(0xFF009DE1),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  minLines: 1,
                  onChanged: (value) {
                    value.isEmpty
                        ? setState(() => isMessageIconEnabled = false)
                        : setState(() => isMessageIconEnabled = true);
                  },
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(color: context.theme.greyColor),
                    filled: true,
                    fillColor: context.theme.chatTextFieldBg,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        style: BorderStyle.none,
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: Material(
                      color: Colors.transparent,
                      child: CustomIconButton(
                        onPressed: () {},
                        icon: Icons.emoji_emotions_outlined,
                        iconColor: Theme.of(context).listTileTheme.iconColor,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RotatedBox(
                          quarterTurns: 45,
                          child: CustomIconButton(
                            onPressed: () => setState(
                              () => cardHeight == 0
                                  ? cardHeight = 90
                                  : cardHeight = 0,
                            ),
                            icon: cardHeight == 0
                                ? Icons.attach_file
                                : Icons.close,
                            iconColor:
                                Theme.of(context).listTileTheme.iconColor,
                          ),
                        ),
                        CustomIconButton(
                          onPressed: sendImageOrVideoFromCamera,
                          icon: Icons.camera_alt_outlined,
                          iconColor: Theme.of(context).listTileTheme.iconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              CustomIconButton(
                onPressed: sendTextMessage,
                icon: isMessageIconEnabled
                    ? Icons.send_outlined
                    : Icons.mic_none_outlined,
                background: Coloors.greenDark,
                iconColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}