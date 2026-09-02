// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  testWidgets('long press timer does not fire against an unmounted chart',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(_buildChart()));

    // Press and hold, but do not release. This starts the long press timer.
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(charts.BarChart)));
    await tester.pump(const Duration(milliseconds: 150));

    // Navigate away before the 250ms long press timeout elapses.
    await tester.pumpWidget(_wrap(const SizedBox()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);

    await gesture.up();
  });
}

Widget _wrap(Widget child) => new Directionality(
      textDirection: TextDirection.ltr,
      child: new Center(
        child: new SizedBox(width: 200.0, height: 200.0, child: child),
      ),
    );

Widget _buildChart() => new charts.BarChart(
      _createSampleData(),
      animate: false,
      defaultInteractions: false,
      behaviors: [
        new charts.SelectNearest(
            eventTrigger: charts.SelectionTrigger.pressHold),
      ],
    );

List<charts.Series<OrdinalSales, String>> _createSampleData() {
  final data = [
    new OrdinalSales('2014', 5),
    new OrdinalSales('2015', 25),
    new OrdinalSales('2016', 100),
    new OrdinalSales('2017', 75),
  ];

  return [
    new charts.Series<OrdinalSales, String>(
      id: 'Sales',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (OrdinalSales sales, _) => sales.year,
      measureFn: (OrdinalSales sales, _) => sales.sales,
      data: data,
    )
  ];
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
