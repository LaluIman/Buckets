import 'package:flutter/material.dart';
import 'package:income_tracker/screens/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/services/localization_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/utils/app_localizations.dart';
import 'package:income_tracker/widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizationService = Provider.of<LocalizationService>(context);
    final user = authProvider.user;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    l10n.get('back'),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('account'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.email, color: primaryColor),
                title: Text(
                  user?.email ?? '-',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(l10n.get('email')),
              ),
            ),
            SizedBox(height: 24),
            Text(
              l10n.get('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.language, color: primaryColor),
                title: Text(localizationService.getCurrentLanguageName()),
                subtitle: Text(l10n.get('language')),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () =>
                    _showLanguageDialog(context, localizationService, l10n),
              ),
            ),
            SizedBox(height: 12),
            Text(
              l10n.get('other'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.apps, color: primaryColor),
                title: Text(l10n.get('info')),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () => _showAboutBottomSheet(context, l10n),
              ),
            ),
            Spacer(),
            CustomButton(
              text: l10n.get('logout'),
              icon: null,
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () async {
                // Show confirmation dialog
                bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(l10n.get('confirm_logout')),
                      content: Text(l10n.get('logout_message')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.get('cancel'), style: TextTheme.of(context).bodyMedium,),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(l10n.get('yes_logout'),  style: TextTheme.of(context).bodyMedium?.copyWith(
                              color: Colors.white
                            ),),
                          ),
                        ),
                      ],
                    );
                  },
                );
                if (shouldLogout == true) {
                  await authProvider.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => AuthScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocalizationService localizationService,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(l10n.get('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocalizationService.languageNames.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                leading: Radio<String>(
                  value: entry.key,
                  groupValue: localizationService.getCurrentLanguageCode(),
                  onChanged: (String? value) async {
                    if (value != null) {
                      await localizationService.changeLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () async {
                  await localizationService.changeLanguage(entry.key);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.get('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _showAboutBottomSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  l10n.get('info'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  l10n.get('app_version'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  l10n.get('developer'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Lalu Iman Abdullah",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
