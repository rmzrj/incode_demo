import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onboarding_flutter_wrapper/onboarding_flutter_wrapper.dart';

import 'incode_button.dart';

class AdvancedUsage extends StatefulWidget {
  AdvancedUsage({Key? key}) : super(key: key);

  @override
  _AdvancedUsageState createState() => _AdvancedUsageState();
}

class _AdvancedUsageState extends State<AdvancedUsage> {
  OnboardingSectionStatus onboardingSectionStatus =
      OnboardingSectionStatus.none;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incode Omni Advanced Usage'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(key: _formKey, child: _buildButtons()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await IncodeOnboardingSdk.finishFlow();
          setState(() {
            onboardingSectionStatus = OnboardingSectionStatus.none;
          });
        },
        child: const Icon(Icons.restart_alt),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onboardingSectionStatus == OnboardingSectionStatus.none ||
            onboardingSectionStatus ==
                OnboardingSectionStatus.initializing) ...[
          _buildInitButtons(),
        ],
        if (onboardingSectionStatus == OnboardingSectionStatus.started)
          _buildStartSectionButtons(),
      ],
    );
  }

  Widget _buildInitButtons() {
    return Column(
      children: [
        SizedBox(height: 16),
        IncodeButton(
          text: 'Setup Onboarding Session',
          onPressed: onboardingSectionStatus == OnboardingSectionStatus.none
              ? setupOnboardingSession
              : null,
        ),
      ],
    );
  }

  Widget _buildStartSectionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IncodeButton(
          text: 'Start ID Scan',
          onPressed: startIdScan,
        ),
        SizedBox(height: 16),
        IncodeButton(
          text: 'Start Selfie Scan',
          onPressed: startSelfie,
        ),
        SizedBox(height: 16),
        IncodeButton(
          text: 'Start Face Match',
          onPressed: startFaceMatch,
        ),
        SizedBox(height: 16),
        IncodeButton(
          text: 'Finish Workflow',
          onPressed: finishFlow,
        ),
      ],
    );
  }

  void setupOnboardingSession() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      onboardingSectionStatus = OnboardingSectionStatus.initializing;
    });
    IncodeOnboardingSdk.setupOnboardingSession(
      sessionConfig: OnboardingSessionConfiguration(),
      onError: (String error) {
        print('Incode setup onboarding session error: $error');
        setState(() {
          onboardingSectionStatus = OnboardingSectionStatus.none;
        });
        showSnackbar(
          text: 'Incode setup onboarding session error: $error',
          color: Colors.red,
        );
      },
      onSuccess: (OnboardingSessionResult result) {
        print('Incode setup onboarding session success! $result');
        setState(() {
          onboardingSectionStatus = OnboardingSectionStatus.started;
        });
      },
    );
  }

  void startIdScan() {
    OnboardingFlowConfiguration config = OnboardingFlowConfiguration();
    config.addIdScan();

    IncodeOnboardingSdk.startNewOnboardingSection(
      flowConfig: config,
      flowTag: 'idSection',
      onError: (String error) {
        print('Incode onboarding session error: $error');
        showSnackbar(
          text: 'Incode onboarding session error: $error',
          color: Colors.red,
        );
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
      onOnboardingSectionCompleted: (String flowTag) {
        print('flowTag $flowTag');
      },
    );
  }

  void startSelfie() {
    OnboardingFlowConfiguration config = OnboardingFlowConfiguration();
    config.addSelfieScan();

    IncodeOnboardingSdk.startNewOnboardingSection(
      flowConfig: config,
      flowTag: 'selfieSection',
      onError: (String error) {
        print('Incode onboarding session error: $error');
        showSnackbar(
          text: 'Incode onboarding session error: $error',
          color: Colors.red,
        );
      },
      onSelfieScanCompleted: (SelfieScanResult result) {
        print(result);
      },
      onOnboardingSectionCompleted: (String flowTag) {
        print('flowTag $flowTag');
      },
    );
  }

  void startFaceMatch() {
    OnboardingFlowConfiguration config = OnboardingFlowConfiguration();
    config.addFaceMatch();

    IncodeOnboardingSdk.startNewOnboardingSection(
      flowConfig: config,
      flowTag: 'faceMatchSection',
      onError: (String error) {
        print('Incode onboarding session error: $error');
      },
      onFaceMatchCompleted: (FaceMatchResult result) {
        print(result);
      },
      onOnboardingSectionCompleted: (String flowTag) {
        print('flowTag $flowTag');
      },
    );
  }

  void finishFlow() {
    IncodeOnboardingSdk.finishFlow(
      onError: (String error) {
        print('Incode finish onboarding error: $error');
      },
      onSuccess: () {
        print('Incode Onboarding finished successfully!');
        setState(() {
          onboardingSectionStatus = OnboardingSectionStatus.finished;
        });
      },
    );
  }

  String sectionStatusToString(OnboardingSectionStatus status) {
    switch (status) {
      case OnboardingSectionStatus.initializing:
        return 'Initializing...';
      case OnboardingSectionStatus.finished:
        return 'Finished';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSnackbar({required String text, Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }
}

enum OnboardingSectionStatus {
  none,
  initializing,
  started,
  finished,
}