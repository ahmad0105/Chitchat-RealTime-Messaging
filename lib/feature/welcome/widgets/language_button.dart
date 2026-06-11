import 'package:chitchat/common/extension/custom_theme_extension.dart';
import 'package:chitchat/common/utils/coloors.dart';
import 'package:chitchat/common/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({
    super.key,
  });

  showBottomSheet(context){
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 100,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 30,
                  decoration: BoxDecoration(
                    color: context.theme.greyColor!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    CustomIconButton(onPressed: () => Navigator.of(context).pop(),
                      icon: Icons.close_outlined,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'App Language',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color: context.theme.greyColor!.withOpacity(0.3),
                  thickness: .5,
                ),
                RadioListTile(
                    value: true,
                    groupValue: true,
                    onChanged: (value) {},
                    activeColor: Coloors.greenDark,
                    title: const Text('English'),
                    subtitle: Text(
                      "(phone's language)",
                      style: TextStyle(
                        color: context.theme.greyColor,
                      ),
                    ),
                ),
                RadioListTile(
                  value: true,
                  groupValue: false,
                  onChanged: (value) {},
                  activeColor: Coloors.greenDark,
                  title: const Text('Türkçe'),
                  subtitle: Text(
                    "Turkish",
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
                RadioListTile(
                  value: true,
                  groupValue: false,
                  onChanged: (value) {},
                  activeColor: Coloors.greenDark,
                  title: const Text('العربية'),
                  subtitle: Text(
                    "Arabic",
                    style: TextStyle(
                      color: context.theme.greyColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.langBtnBgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => showBottomSheet(context),
        borderRadius: BorderRadius.circular(20),
        splashFactory: NoSplash.splashFactory,
        highlightColor: context.theme.langBtnHighlightColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.language,
                color: Color(0xFF396453),
              ),
              SizedBox(width: 10),
              Text(
                'English',
                style: TextStyle(
                  color: Color(0xFF396453),
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF396453),
              ),
            ],
          ),
        ),
      ),
    );
  }
}