import 'package:chitchat/common/extension/custom_theme_extension.dart';
import 'package:chitchat/common/models/user_model.dart';
import 'package:chitchat/common/routes/routes.dart';
import 'package:chitchat/common/utils/coloors.dart';
import 'package:chitchat/common/widgets/custom_icon_button.dart';
import 'package:chitchat/feature/contact/controllers/contacts_controller.dart';
import 'package:chitchat/feature/contact/widgets/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  shareSmsLink(phoneNumber) async {
    Uri sms = Uri.parse(
        "sms:${phoneNumber}?body=Let's chat on ChitChat! it's a fast, simple, and secure app we can call each other for free. Get it at https://chitchat.com/dl/");
    if (await launchUrl(sms)) {
    } else {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Coloors.greenDark,
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected contact',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            ref.watch(contactsControllerProvider).when(
              data: (allContacts) {
                return Text(
                  "${allContacts[0].length} Contact${allContacts[0].length == 1 ? '' : 's'}",
                  style: const TextStyle(fontSize: 13),
                );
              },
              error: (e, t) {
                return SizedBox();
              },
              loading: () {
                return const Text(
                  'counting',
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ],
        ),
        actions: [
          CustomIconButton(onPressed: () {}, icon: Icons.search),
          CustomIconButton(onPressed: () {}, icon: Icons.more_vert)
        ],
      ),
      body: ref.watch(contactsControllerProvider).when(data: (allContacts) {
        return ListView.builder(
          itemCount: allContacts[0].length + allContacts[1].length,
          itemBuilder: (context, index) {
            //return Card(
            //child: Text(allContacts[1][index].username),
            //);
            late UserModel firebaseContacts;
            late UserModel phoneContacts;

            if (index < allContacts[0].length) {
              firebaseContacts = allContacts[0][index];
            } else {
              phoneContacts = allContacts[1][index - allContacts[0].length];
            }

            return index < allContacts[0].length
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            myListTile(
                              leading: Icons.group,
                              text: 'New Group',
                            ),
                            myListTile(
                              leading: Icons.contacts,
                              text: 'New Contact',
                              trailing: Icons.qr_code,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text(
                                'Contacts on ChitChat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.greyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ContactCard(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.chat,
                            arguments: firebaseContacts,
                          );
                        },
                        contactSource: firebaseContacts,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == allContacts[0].length)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            'Contacts on ChitChat',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.theme.greyColor,
                            ),
                          ),
                        ),
                      ContactCard(
                        contactSource: phoneContacts,
                        onTap: () => shareSmsLink(phoneContacts.phoneNumber),
                      ),
                    ],
                  );
          },
        );
      }, error: (e, t) {
        return null;
      }, loading: () {
        return Center(
          child: CircularProgressIndicator(
            color: context.theme.authAppbarTextColor,
          ),
        );
      }),
    );
  }

  ListTile myListTile({
    required IconData leading,
    required String text,
    IconData? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(top: 10, left: 20, right: 10),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Coloors.greenLight,
        child: Icon(
          leading,
          color: Colors.white,
        ),
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        trailing,
        color: Coloors.greyDark,
      ),
    );
  }
}
