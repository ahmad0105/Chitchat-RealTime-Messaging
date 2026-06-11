import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/feature/call/controller/call_controller.dart';
import 'package:chitchat/feature/call/model/call.dart';
import 'package:chitchat/feature/call/screens/call_pickup_screen.dart';
import 'package:chitchat/feature/call/screens/call_screen.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chitchat/common/extension/custom_theme_extension.dart';
import 'package:chitchat/common/helper/last_seen_message.dart';
import 'package:chitchat/common/models/user_model.dart';
import 'package:chitchat/common/widgets/custom_icon_button.dart';
import 'package:chitchat/common/routes/routes.dart';
import 'package:chitchat/feature/auth/controller/auth_controller.dart';
import 'package:chitchat/feature/chat/controllers/chat_controller.dart';
import 'package:chitchat/feature/chat/widgets/chat_text_field.dart';
import 'package:chitchat/feature/chat/widgets/message_card.dart';
import 'package:chitchat/feature/chat/widgets/show_date_card.dart';
import 'package:chitchat/feature/chat/widgets/yellow_card.dart';

final pageStorageBucket = PageStorageBucket();

class ChatPage extends ConsumerWidget {
  ChatPage({
    super.key,
    required this.user,
    required this.uid,
    required this.profileImageUrl,
  });

  final UserModel user;
  final ScrollController scrollController = ScrollController();
  final String uid;
  final String profileImageUrl;

  // دالة لإجراء المكالمة
  void makeCall(WidgetRef ref, BuildContext context) {
    debugPrint('Attempting to make a call to ${user.username}...');

    ref.read(callControllerProvider).makeCall(
          context,
          user.username,
          user.uid,
          user.profileImageUrl,
        );

    // التنقل إلى شاشة الاتصال
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelId: 'testChannelId',
          call: Call(
            callerId: FirebaseAuth.instance.currentUser!.uid,
            callerName: FirebaseAuth.instance.currentUser!.displayName ??
                'Unknown Caller',
            callerPic: FirebaseAuth.instance.currentUser!.photoURL ?? '',
            receiverId: user.uid,
            receiverName: user.username,
            receiverPic: user.profileImageUrl,
            callId: 'randomCallId', // يمكن تغييره إلى UUID
            hasDialled: true,
          ),
          isGroupChat: false,
        ),
      ),
    );

    debugPrint('Navigated to CallScreen.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
        backgroundColor: context.theme.chatPageBgColor,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                const Icon(Icons.arrow_back),
                Hero(
                  tag: 'profile',
                  child: Container(
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(user.profileImageUrl),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.profile,
                arguments: user,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  StreamBuilder(
                    stream: ref
                        .read(authControllerProvider)
                        .getUserPresenceStatus(uid: user.uid),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState != ConnectionState.active) {
                        return const Text(
                          'connecting',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        );
                      }

                      final singleUserModel = snapshot.data!;

                      final lastMessage =
                          lastSeenMessage(singleUserModel.lastSeen);

                      return Text(
                        singleUserModel.active ? "Online" : "$lastMessage ago",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CustomIconButton(
              onPressed: () => makeCall(ref, context),
              icon: Icons.video_call,
              iconColor: Colors.white,
            ),
            CustomIconButton(
              onPressed: () {},
              icon: Icons.call,
              iconColor: Colors.white,
            ),
            CustomIconButton(
              onPressed: () {},
              icon: Icons.more_vert,
              iconColor: Colors.white,
            )
          ],
        ),
        body: Stack(
          children: [
            Image(
              height: double.maxFinite,
              width: double.maxFinite,
              image: const AssetImage('assets/images/doodle_bg.png'),
              fit: BoxFit.cover,
              color: context.theme.chatPageDoodleColor,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: StreamBuilder(
                stream: ref
                    .watch(chatControllerProvider)
                    .getAllOneToOneMessage(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    return ListView.builder(
                      itemCount: 15,
                      itemBuilder: (_, index) {
                        final random = Random().nextInt(14);
                        return Container(
                          alignment: random.isEven
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: random.isEven ? 150 : 15,
                            right: random.isEven ? 15 : 150,
                          ),
                          child: ClipPath(
                            clipper: UpperNipMessageClipperTwo(
                              random.isEven
                                  ? MessageType.send
                                  : MessageType.receive,
                              nipWidth: 8,
                              nipHeight: 10,
                              bubbleRadius: 12,
                            ),
                            child: Shimmer.fromColors(
                              baseColor: random.isEven
                                  ? context.theme.greyColor!.withOpacity(.3)
                                  : context.theme.greyColor!.withOpacity(.2),
                              highlightColor: random.isEven
                                  ? context.theme.greyColor!.withOpacity(.4)
                                  : context.theme.greyColor!.withOpacity(.3),
                              child: Container(
                                height: 40,
                                width: 170 +
                                    double.parse(
                                      (random * 2).toString(),
                                    ),
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return PageStorage(
                    bucket: pageStorageBucket,
                    child: ListView.builder(
                      key: const PageStorageKey('chat_page_list'),
                      itemCount: snapshot.data!.length,
                      shrinkWrap: true,
                      controller: scrollController,
                      itemBuilder: (_, index) {
                        final message = snapshot.data![index];
                        final isSender = message.senderId ==
                            FirebaseAuth.instance.currentUser!.uid;

                        final haveNip = (index == 0) ||
                            (index == snapshot.data!.length - 1 &&
                                message.senderId !=
                                    snapshot.data![index - 1].senderId) ||
                            (message.senderId !=
                                    snapshot.data![index - 1].senderId &&
                                message.senderId ==
                                    snapshot.data![index + 1].senderId) ||
                            (message.senderId !=
                                    snapshot.data![index - 1].senderId &&
                                message.senderId !=
                                    snapshot.data![index + 1].senderId);
                        final isShowDateCard = (index == 0) ||
                            ((index == snapshot.data!.length - 1) &&
                                (message.timeSent.day >
                                    snapshot.data![index - 1].timeSent.day)) ||
                            (message.timeSent.day >
                                    snapshot.data![index - 1].timeSent.day &&
                                message.timeSent.day <=
                                    snapshot.data![index + 1].timeSent.day);

                        return Column(
                          children: [
                            if (index == 0) const YellowCard(),
                            if (isShowDateCard)
                              ShowDateCard(date: message.timeSent),
                            MessageCard(
                              isSender: isSender,
                              haveNip: haveNip,
                              message: message,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              alignment: const Alignment(0, 1),
              child: ChatTextField(
                receiverId: user.uid,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
