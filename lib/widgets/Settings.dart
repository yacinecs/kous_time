import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // For version info
import 'package:url_launcher/url_launcher.dart'; // For opening links

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appName = '';
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // About Section
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Information about the app'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          Divider(),
          // Feedback Section
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Send Feedback'),
            subtitle: Text('Report issues or share your suggestions'),
            onTap: _sendFeedback,
          ),
          Divider(),
          // Privacy Policy Section
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            subtitle: Text('Learn how we handle your data'),
            onTap: _openPrivacyPolicy,
          ),
          Divider(),
          // Version Section
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('Version: $_version (Build $_buildNumber)'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About $_appName'),
        content: Text('$_appName\nVersion: $_version (Build $_buildNumber)\n\nDeveloped by: Oumouadene Yacine'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      query: 'subject=Feedback for $_appName',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _openPrivacyPolicy() async {
    const url = 'https://example.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
