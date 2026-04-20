import 'package:flutter/material.dart';
import 'package:flutter_app/ui/widgets/premium_explainer_sheet.dart';

class PremiumExplainerSheetService {
  const PremiumExplainerSheetService();

  Future<PremiumExplainerAction?> show({
    required BuildContext context,
    String? featureLabel,
  }) {
    return showModalBottomSheet<PremiumExplainerAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return PremiumExplainerSheet(featureLabel: featureLabel);
      },
    );
  }
}
