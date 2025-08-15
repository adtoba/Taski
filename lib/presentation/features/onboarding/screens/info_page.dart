import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  String? name;

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YMargin(10),
          Text(
            "Getting to Know You",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: config.sp(25),
            ),
          ),
          YMargin(30),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(config.sw(8)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                ),
                child: Icon(
                  Icons.smart_toy, 
                  size: config.sp(25), 
                  color: Colors.white
                ),
              ),
              XMargin(10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: config.sw(12), vertical: config.sh(10)),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Hi there! I'm Taski, your personal assistant. What should I call you?", 
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: config.sp(16),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "10:25",
                          textAlign: TextAlign.end,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: config.sp(12),
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          YMargin(20),
          if(name != null)...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: config.sw(12), vertical: config.sh(10)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My name is $name", 
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: config.sp(16),
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "10:25",
                            textAlign: TextAlign.start,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: config.sp(12),
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                XMargin(10),
                Container(
                  padding: EdgeInsets.all(config.sw(8)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.person, 
                    size: config.sp(25), 
                    color: Colors.white
                  ),
                ),
                
              ],
            ),
          ],
          Spacer(),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      fontSize: config.sp(16),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              XMargin(10),
              IconButton(
                onPressed: () {
                  setState(() {
                    name = _nameController.text;
                    _nameController.clear();
                  });
                }, 
                icon: Icon(
                  Icons.send, 
                  color: colorScheme.primary
                )
              ),
              XMargin(10),
            ],
          ),
          YMargin(40)
        ],
      ),
    );
  }
}