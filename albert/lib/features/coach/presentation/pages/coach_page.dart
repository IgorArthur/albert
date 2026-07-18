import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/fonts/app_fonts.dart';
import '../controllers/coach_controller.dart';
import '../widgets/coach_message_bubble.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoachController>();
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with simulated safe area top padding
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, topPadding + 24.0, 20.0, 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceLight : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI COACH'.tr).overline(color: AppColors.primary100),
                      const SizedBox(height: 2),
                      Text('Coach Albert').headline(),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.suggestNextWorkout(
                    goal: "Get stronger and improve endurance",
                    recentWorkouts: [],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Suggest',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Message List
          Expanded(
            child: Obx(() {
              final list = controller.messages;
              _scrollToBottom();

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary100,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text('Ask Coach Albert any fitness question!').subtitle2(color: AppColors.neutral60),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) => CoachMessageBubble(message: list[index]),
              );
            }),
          ),
          // Loading Indicator
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary100),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Input Box with bottom safe area padding
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: bottomPadding > 0 ? bottomPadding + 12 : 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceCard : Colors.grey.shade100,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceLight : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Theme.of(context).dividerColor, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: AppColors.neutral60),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        controller.sendQuestion(val);
                        _textController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    controller.sendQuestion(_textController.text);
                    _textController.clear();
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.primary100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
