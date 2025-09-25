import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';
import 'package:taski/presentation/widgets/custom_textfield.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create Contact",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: config.sp(20),
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        padding: EdgeInsets.all(config.sw(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: config.sp(16),
              ),
            ),
            YMargin(5),
            CustomTextField(
              controller: TextEditingController(),
              hintText: "Enter name",
              keyboardType: TextInputType.name,
              isDark: Theme.of(context).brightness == Brightness.dark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name is required";
                }
                return null;
              },
            ),
            YMargin(10),
            Text(
              "Email",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: config.sp(16),
              ),
            ),
            YMargin(5),
            CustomTextField(
              controller: TextEditingController(),
              hintText: "Enter email",
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')),
              ],
              isDark: Theme.of(context).brightness == Brightness.dark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                return null;
              },
            ),

            YMargin(10),
            Text(
              "Phone Number",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: config.sp(16),
              ),
            ),
            YMargin(5),
            CustomTextField(
              controller: TextEditingController(),
              hintText: "Enter phone number",
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              isDark: Theme.of(context).brightness == Brightness.dark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        MaterialButton(
          minWidth: double.infinity,
          height: config.sh(50),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onPressed: () {
            // TODO: Add contact
          },
          child: Text("Add Contact"),
        ),
      ],
    );
  }
}