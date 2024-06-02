import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_shape/container/circular_container.dart';
import '../../../../common/widgets/custom_shape/container/primary_header_container.dart';
import '../../../../common/widgets/custom_shape/curved_edges/curved_edges.dart';
import '../../../../common/widgets/custom_shape/curved_edges/curved_edges_widget.dart';
import '../../../../utils/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TPrimaryHeaderContainer(child: Container()),
          ],
        ),
      ),
    );
  }
}
