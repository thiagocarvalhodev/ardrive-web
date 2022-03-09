import 'package:ardrive/components/components.dart';
import 'package:ardrive/misc/misc.dart';
import 'package:ardrive/pages/user_interaction_wrapper.dart';
import 'package:ardrive/services/services.dart';
import 'package:ardrive/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showCongestionDependentModalDialog(
    BuildContext context, Function() showAppDialog) async {
  final warnAboutCongestion =
      await context.read<ArweaveService>().getCachedMempoolSize() >
          mempoolWarningSizeLimit;
  return await showModalDialog(context, () async {
    if (warnAboutCongestion) {
      final shouldShowDialog = await showDialog(
        context: context,
        builder: (_) => AppDialog(
          title: AppLocalizations.of(context)!.warningEmphasized,
          content: SizedBox(
            width: kMediumDialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .congestionWarning),
                          ],
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                  AppLocalizations.of(context)!.tryLaterCongestionEmphasized),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: Text(
                  AppLocalizations.of(context)!.proceedCongestionEmphasized),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (shouldShowDialog) {
        return showAppDialog();
      } else {
        return;
      }
    } else {
      return showAppDialog();
    }
  });
}
