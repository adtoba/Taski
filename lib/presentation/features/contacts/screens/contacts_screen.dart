import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taski/core/utils/navigator.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/presentation/features/contacts/screens/add_contact_screen.dart';
import 'package:taski/presentation/features/contacts/widgets/contact_widget.dart';
import 'package:taski/presentation/widgets/base_screen.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        body: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          itemBuilder: (context, index) {
            return ContactWidget(
              name: 'John Doe', 
              email: 'john.doe@example.com', 
              phone: '1234567890',
              onTap: () {
              },
            );
          },
          separatorBuilder: (context, index) => YMargin(5),
          itemCount: 5,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            push(AddContactScreen());
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}