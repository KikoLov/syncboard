import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// SyncBoard 看板页面
/// 演示如何：
/// 1. 连接 WebSocket
/// 2. 订阅看板频道
/// 3. 监听实时更新
/// 4. 实现局部数据刷新
class BoardScreen extends StatefulWidget {
  final int boardId;

  const BoardScreen({super.key, required this.boardId});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  // WebSocket 管理器（实际项目中应使用 Provider 注入）
  final WebSocketManager _wsManager = WebSocketManagerSingleton().manager;

  // 看板数据
  Map<String, dynamic>? _boardData;
  List<dynamic> _columns = [];
  List<dynamic> _tasks = [];
  Set<dynamic> _onlineUsers = {};

  // 加载状态
  bool _isLoading = true;
  String? _errorMessage;

  // 订阅取消标记
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();

    // 初始化
    _initialize();
  }

  /// 初始化：连接 WebSocket 并加载数据
  Future<void> _initialize() async {
    // 1. 连接 WebSocket
    await _wsManager.connect();

    // 2. 订阅消息流
    _messageSubscription = _wsManager.messageStream.listen((message) {
      _handleWebSocketMessage(message);
    });

    // 3. 订阅连接状态流
    _connectionSubscription = _wsManager.connectionStream.listen((isConnected) {
      if (isConnected) {
        // 连接成功后订阅看板频道
        _wsManager.subscribeToBoard(widget.boardId);
      }
    });

    // 4. 加载初始数据
    await _loadBoardData();
  }

  /// 加载看板数据（HTTP API）
  Future<void> _loadBoardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/boards/${widget.boardId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['code'] == 200) {
          setState(() {
            _boardData = data['data'];
            _columns = data['data']['columns'] ?? [];
            _tasks = data['data']['tasks'] ?? [];
            _isLoading = false;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 处理 WebSocket 实时消息
  /// 核心：根据事件类型进行局部数据刷新
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final eventType = message['eventType'];

    switch (eventType) {
      case 'TASK_CREATE':
        // 🆕 新任务创建
        _handleTaskCreate(message['payload']);
        break;

      case 'TASK_MOVE':
        // 🔄 任务移动（拖拽排序）
        _handleTaskMove(message['payload']);
        break;

      case 'TASK_UPDATE':
        // ✏️ 任务更新
        _handleTaskUpdate(message['payload']);
        break;

      case 'TASK_DELETE':
        // 🗑️ 任务删除
        _handleTaskDelete(message['payload']);
        break;

      case 'USER_PRESENCE':
        // 👤 用户在线状态变化
        _handleUserPresence(message['payload']);
        break;
    }
  }

  /// 处理任务创建（局部刷新）
  void _handleTaskCreate(dynamic payload) {
    setState(() {
      _tasks.add(payload);
    });

    // 显示通知
    _showSnackBar('🆕 新任务已创建: ${payload['title']}');
  }

  /// 处理任务移动（局部刷新）
  /// 这是拖拽排序的核心逻辑
  void _handleTaskMove(dynamic payload) {
    setState(() {
      // 找到任务并更新
      final index = _tasks.indexWhere((t) => t['id'] == payload['id']);
      if (index != -1) {
        _tasks[index] = payload;
      }
    });

    print('🔄 任务已移动: ${payload['title']} -> 列 ${payload['columnId']}');
  }

  /// 处理任务更新（局部刷新）
  void _handleTaskUpdate(dynamic payload) {
    setState(() {
      final index = _tasks.indexWhere((t) => t['id'] == payload['id']);
      if (index != -1) {
        _tasks[index] = payload;
      }
    });

    _showSnackBar('✏️ 任务已更新');
  }

  /// 处理任务删除（局部刷新）
  void _handleTaskDelete(dynamic payload) {
    setState(() {
      _tasks.removeWhere((t) => t['id'] == payload);
    });

    _showSnackBar('🗑️ 任务已删除');
  }

  /// 处理用户在线状态变化
  void _handleUserPresence(dynamic payload) {
    if (payload['online'] == true) {
      setState(() {
        _onlineUsers.add(payload['userId']);
      });
      _showSnackBar('👤 ${payload['username']} 上线了');
    } else {
      setState(() {
        _onlineUsers.remove(payload['userId']);
      });
    }
  }

  /// 显示通知
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 移动任务（拖拽排序）
  /// 向后端发送移动请求
  Future<void> _moveTask(
    int taskId,
    int targetColumnId,
    double? previousSortOrder,
    double? nextSortOrder,
  ) async {
    try {
      // 获取当前任务的版本号
      final task = _tasks.firstWhere((t) => t['id'] == taskId);
      final version = task['version'] ?? 0;

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/tasks/move'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'taskId': taskId,
          'targetColumnId': targetColumnId,
          'previousSortOrder': previousSortOrder,
          'nextSortOrder': nextSortOrder,
          'version': version,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ 任务移动成功');
      } else {
        final data = jsonDecode(response.body);

        // 处理并发冲突
        if (response.statusCode == 409) {
          _showSnackBar('⚠️ ${data['message']}');
          await _loadBoardData(); // 刷新数据
        } else {
          _showSnackBar('❌ 移动失败: ${data['message']}');
        }
      }
    } catch (e) {
      _showSnackBar('❌ 网络错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_boardData?['board']?['name'] ?? '加载中...'),
        actions: [
          // 显示在线用户数
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '👥 ${_onlineUsers.length} 人在线',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❌ 加载失败', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBoardData,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 看板视图（可拖拽）
    return _buildBoardView();
  }

  /// 构建看板视图
  Widget _buildBoardView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _columns.length,
      itemBuilder: (context, columnIndex) {
        final column = _columns[columnIndex];
        final columnTasks = _tasks
            .where((t) => t['columnId'] == column['id'])
            .toList()
          ..sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));

        return Container(
          width: 300,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(column['color']?.replaceAll('#', '0xFF') ?? 0xFFEBECF0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 列标题
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      column['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${columnTasks.length}'),
                    ),
                  ],
                ),
              ),

              // 任务列表
              Expanded(
                child: ListView.builder(
                  itemCount: columnTasks.length,
                  itemBuilder: (context, taskIndex) {
                    final task = columnTasks[taskIndex];
                    return _buildTaskCard(task);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建任务卡片
  Widget _buildTaskCard(dynamic task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task['title'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (task['description'] != null) ...[
            const SizedBox(height: 4),
            Text(
              task['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _wsManager.unsubscribeFromBoard(widget.boardId);
    super.dispose();
  }
}

/// 简单的 WebSocket 管理器（生产环境应放入单独文件）
class WebSocketManager {
  bool isConnected() => false;
  Future<void> connect() async {}
  void subscribeToBoard(int boardId) {}
  void unsubscribeFromBoard(int boardId) {}
  Stream<Map<String, dynamic>> get messageStream =>
      const Stream.empty();
  Stream<bool> get connectionStream => const Stream.empty();
}

class WebSocketManagerSingleton {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManagerSingleton() => _instance;
  WebSocketManager._internal();
  WebSocketManager get manager => _instance;
}
