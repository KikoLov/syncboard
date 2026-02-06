import 'package:flutter/material.dart';
import 'board_screen.dart';

void main() {
  runApp(const SyncBoardApp());
}

class SyncBoardApp extends StatelessWidget {
  const SyncBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncBoard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// 首页：选择看板
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SyncBoard - 实时协作任务平台'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('项目开发看板'),
            subtitle: const Text('看板 ID: 1'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoardScreen(boardId: 1),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('个人任务管理'),
            subtitle: const Text('看板 ID: 2'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BoardScreen(boardId: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
