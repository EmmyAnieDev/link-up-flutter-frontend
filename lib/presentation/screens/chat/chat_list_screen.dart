import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/appbar_profile_photo.dart';
import '../../widgets/chat_list_view.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFBFCFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF626FFF),
          title: Text(
            'Chat List',
            style: GoogleFonts.sansita(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 30,
            ),
          ),
          actions: [
            AppBarProfilePhoto(),
          ],
        ),
        body: ChatListView(),
      ),
    );
  }
}
