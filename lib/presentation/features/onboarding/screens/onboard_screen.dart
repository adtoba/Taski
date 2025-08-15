import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/features/onboarding/screens/first_task_page.dart';
import 'package:taski/presentation/features/onboarding/screens/info_page.dart';
import 'package:taski/presentation/features/onboarding/screens/options_page.dart';
import 'package:taski/presentation/features/onboarding/widgets/onboarding_option_selector.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> with TickerProviderStateMixin {

  final PageController _pageController = PageController(
    keepPage: true,
    initialPage: 0,
  );
  

  int _currentPage = 0;

  void onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
  
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildProgressIndicator(currentStep: _currentPage + 1, totalSteps: 3),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: config.sw(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                // physics: NeverScrollableScrollPhysics(),
                onPageChanged: onPageChanged,
                children: [
                  OptionsPage(),
                  InfoPage(),
                  FirstTaskPage(),
                ],
              ),
            ),
            if(_currentPage == 0)...[
              MaterialButton(
                minWidth: double.infinity,
                height: config.sh(45),
                onPressed: () {
                  onPageChanged(_currentPage + 1);
                },
                color: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("Continue", style: textTheme.bodyMedium?.copyWith(
                  fontSize: config.sp(16),
                  color: Colors.white,
                )),
              ),
              YMargin(10),
              MaterialButton(
                minWidth: double.infinity,
                height: config.sh(45),
                onPressed: () {},
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: colorScheme.primary),
                ),
                child: Text("Skip", style: textTheme.bodyMedium?.copyWith(
                  fontSize: config.sp(16),
                  color: Colors.black,
                )),
              ),
              YMargin(40)
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({int? currentStep = 0, int? totalSteps = 3}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: config.sw(12), vertical: config.sh(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(totalSteps!, (index) => _buildIndicator(index < currentStep!)),
          XMargin(8),
          Text(
            '${currentStep!} of $totalSteps',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: config.sp(11),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(right: config.sw(4)),
      width: config.sw(20),
      height: config.sh(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isActive ? colorScheme.primary : Colors.grey[300],
      ),
    );
  }
}