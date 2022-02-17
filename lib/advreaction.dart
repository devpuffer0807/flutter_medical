import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iraqpvc/ui/drugs_form.dart';
import 'package:iraqpvc/ui/patient_details.dart';
import 'package:iraqpvc/ui/reaction_form.dart';
import 'package:iraqpvc/ui/reporter.dart';

import 'application_localizations.dart';

class AdvReaction extends StatefulWidget {
  @override
  _AdvReactionState createState() => _AdvReactionState();
}

class _AdvReactionState extends State<AdvReaction>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  var tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }


  _updateIndex(int index) {
    print("index: " + index.toString());
    tabIndex = index;
    setState(() {
      _tabController.index = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.yellow[100],
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 0, 128, 10),
          title: Text(
              ApplicationLocalizations.of(context)
                  .translate('title_adverse_reactions')
                  .toString(),
              style: new TextStyle(fontSize: 18, color: Colors.yellow),
              textAlign: TextAlign.start),
          titleSpacing: -5,
          bottom: TabBar(
            onTap: (value) {
              _tabController.index = tabIndex;
            },
            controller: _tabController,
            indicatorColor: Color.fromRGBO(242, 0, 0, 10),
            tabs: [
              Tab(
                  text: ApplicationLocalizations.of(context)
                      .translate('reporter_info')
                      .toString()),
              Tab(
                  text: ApplicationLocalizations.of(context)
                      .translate('patient_details')
                      .toString()),
              Tab(
                  text: ApplicationLocalizations.of(context)
                      .translate('adverse_reactions')
                      .toString()),
              Tab(
                  text: ApplicationLocalizations.of(context)
                      .translate('drugs')
                      .toString())
            ],
            labelStyle: TextStyle(fontSize: 16),
            labelPadding: EdgeInsets.only(left: 20, right: 20),
            isScrollable: true,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Reporter(tabController: _tabController, parentAction: _updateIndex),
            PatientDetails(tabController: _tabController, parentAction: _updateIndex),
            ReactionForm(tabController: _tabController, parentAction: _updateIndex),
            DrugsForm(tabController: _tabController, parentAction: _updateIndex)
          ],
        ),
      ),
    );
  }
}
