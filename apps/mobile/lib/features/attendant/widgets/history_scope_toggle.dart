import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../attendant_providers.dart';

/// Bascule « Ma pompe / Toute la station » pilotant [historyScopeProvider].
class HistoryScopeToggle extends ConsumerWidget {
  const HistoryScopeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(historyScopeProvider);

    return SegmentedButton<HistoryScope>(
      segments: const [
        ButtonSegment(
          value: HistoryScope.pump,
          label: Text('Ma pompe'),
          icon: Icon(Icons.local_gas_station_rounded),
        ),
        ButtonSegment(
          value: HistoryScope.station,
          label: Text('Toute la station'),
          icon: Icon(Icons.store_rounded),
        ),
      ],
      selected: {scope},
      showSelectedIcon: false,
      onSelectionChanged: (selection) =>
          ref.read(historyScopeProvider.notifier).set(selection.first),
    );
  }
}
