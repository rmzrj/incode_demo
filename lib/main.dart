import 'package:flutter/material.dart';
import 'package:onboarding_flutter_wrapper/onboarding_flutter_wrapper.dart';

import 'advanced_usage.dart';
import 'incode_button.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeView(),
      routes: {'advanced': (_) => AdvancedUsage()},
    );
  }
}

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  OnboardingStatus? status;
  late Future<bool> future;
  bool initSuccess = false;
  bool isOnboarding = false;

  @override
  void initState() {
    super.initState();

    IncodeOnboardingSdk.init(
      apiKey: '3a9264b3cdec06942821657097c7843b1c6eee30',
      apiUrl: 'https://demo-api.incodesmile.com/',
      testMode: true,
      loggingEnabled: true,
      onError: (String error) {
        print('Incode SDK init failed: $error');
        setState(() {
          initSuccess = false;
        });
      },
      onSuccess: () {
        // Update UI, safe to start Onboarding
        print('Incode initialize successfully!');
        setState(() {
          initSuccess = true;
        });
      },
    );

    // IncodeOnboardingSdk.setTheme(theme: theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incode Omni'),
        actions: [
          if (initSuccess)
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('advanced'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Advanced',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.navigate_next_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildChildren(),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> children;
    switch (status) {
      case OnboardingStatus.success:
        children = [
          _buildInfoMessage(
            title: 'Thank you!',
            subtitle: 'You\'ve successfully completed the onboarding process.',
          ),
          _buildRestartOnoardingButton(),
        ];
        break;
      case OnboardingStatus.failure:
        children = [
          Flexible(
            child: _buildInfoMessage(
              title: 'Process was not completed',
              subtitle:
                  'We\'re unable to onboard you remotely, please proceed to the nearest branch.',
            ),
          ),
          Flexible(child: _buildRestartOnoardingButton()),
        ];
        break;
      case null:
        children = [
          IncodeButton(
            text: 'START ONBOARDING',
            onPressed: initSuccess && !isOnboarding ? onStartOnboarding : null,
          ),
          IncodeButton(
            text: 'START FACE LOGIN',
            onPressed: initSuccess && !isOnboarding ? onFaceLogin : null,
          ),
        ];
        break;
    }
    return children;
  }

  Widget _buildRestartOnoardingButton() {
    return IncodeButton(
      text: 'RESTART ONBOARDING',
      onPressed: () {
        setState(() {
          status = null;
        });
      },
    );
  }

  Widget _buildInfoMessage({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        Text(
          subtitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void onStartOnboarding() {
    OnboardingSessionConfiguration sessionConfig =
        OnboardingSessionConfiguration();
    OnboardingFlowConfiguration flowConfig = OnboardingFlowConfiguration();

    // flowConfig.addPhone();
    flowConfig.addIdScan();
    flowConfig.addSelfieScan();
    flowConfig.addFaceMatch();
    // flowConfig.addGeolocation();
    // flowConfig.addVideoSelfie();

    // flowConfig.addApproval();
    // flowConfig.addGovernmentValidation();
    // flowConfig.addDocumentScan(documentType: DocumentType.medicalDoc);
    // flowConfig.addSignature();
    // flowConfig.addUserScore(mode: UserScoreFetchMode.fast);
    // flowConfig.addCaptcha();
    // flowConfig.addCurpValidation();
    // flowConfig.addIdScan(scanStep: ScanStepType.front);
    // flowConfig.addIdScan(scanStep: ScanStepType.back);
    // flowConfig.addProcessId();

    setState(() {
      isOnboarding = true;
    });

    IncodeOnboardingSdk.startOnboarding(
      sessionConfig: sessionConfig,
      flowConfig: flowConfig,
      onError: (String error) {
        print('Incode onboarding error: $error');
        setState(() {
          status = OnboardingStatus.failure;
          isOnboarding = false;
        });
      },
      onSuccess: () {
        print('Incode Onboarding completed!');
        setState(() {
          status = OnboardingStatus.success;
          isOnboarding = false;
        });
      },
      onSelfieScanCompleted: (SelfieScanResult result) {
        print(result);
      },
      onIdFrontCompleted: (IdScanResult result) {
        print(result);
      },
      onIdBackCompleted: (IdScanResult result) {
        print(result);
      },
      onIdProcessed: (String ocrData) {
        print(ocrData);
      },
      onAddPhoneNumberCompleted: (PhoneNumberResult result) {
        print(result);
      },
      onGeolocationCompleted: (GeoLocationResult result) {
        print(result);
      },
      onFaceMatchCompleted: (FaceMatchResult result) {
        print(result);
      },
      onVideoSelfieCompleted: (VideoSelfieResult result) {
        print(result);
      },
      onOnboardingSessionCreated: (OnboardingSessionResult result) {
        print(result);
        setState(() {
          isOnboarding = false;
        });
      },
      onUserScoreFetched: (UserScoreResult result) {
        print(result);
      },
      onApproveCompleted: (ApprovalResult result) {
        print(result);
      },
      onDocumentScanCompleted: (DocumentScanResult result) {
        print(result);
      },
      onSignatureCollected: (SignatureResult result) {
        print(result);
      },
      onUserCancelled: () {
        print('User cancelled');
        setState(() {
          isOnboarding = false;
        });
      },
      onGovernmentValidationCompleted: (GovernmentValidationResult result) {
        print(result);
      },
      onCaptchaCompleted: (CaptchaResult result) {
        print(result);
      },
      onCurpValidationCompleted: (CurpValidationResult result) {
        print(result);
      },
    );
  }
}

void onFaceLogin() {
  IncodeOnboardingSdk.startFaceLogin(
    faceLogin: FaceLogin(),
    onSuccess: (FaceLoginResult result) {
      print(result);
    },
    onError: (String error) {
      print(error);
    },
  );
}

enum OnboardingStatus {
  success,
  failure,
}

Map<String, dynamic> theme = {
  "buttons": {
    "primary": {
      "states": {
        "normal": {
          "cornerRadius": 32,
          "textColor": "#ffffff",
          "backgroundColor": "#ff0000"
        },
        "highlighted": {
          "cornerRadius": 32,
          "textColor": "#ffffff",
          "backgroundColor": "#5b0000"
        },
        "disabled": {
          "cornerRadius": 32,
          "textColor": "#ffffff",
          "backgroundColor": "#f7f7f7"
        }
      }
    }
  },
  "labels": {
    "title": {"textColor": "#ff0000"},
    "secondaryTitle": {"textColor": "#ff0000"},
    "subtitle": {"textColor": "#ff0000"},
    "secondarySubtitle": {"textColor": "#ff0000"},
    "smallSubtitle": {"textColor": "#ff0000"},
    "info": {"textColor": "#ff0000"},
    "secondaryInfo": {"textColor": "#ff0000"},
    "body": {"textColor": "#ff0000"},
    "secondaryBody": {"textColor": "#ff0000"},
    "code": {"textColor": "#ff0000"}
  }
};