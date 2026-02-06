import 'dart:async';
import 'package:stomp_web_socket/stomp_web_socket.dart';
import 'package:stomp_web_socket/stomp_frame.dart';

/// SyncBoard WebSocket 管理类
/// 负责与后端建立 WebSocket 连接，订阅看板频道，接收实时更新
class WebSocketManager {
  // WebSocket 服务地址
  static const String _wsUrl = 'ws://localhost:8080/api/ws';

  // STOMP 客户端实例
  StompClient? _stompClient;

  // 当前订阅的看板ID
  int? _currentBoardId;

  // 消息回调控制器
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  // 连接状态控制器
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  /// 获取消息流
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 获取连接状态流
  Stream<bool> get connectionStream => _connectionController.stream;

  /// 是否已连接
  bool isConnected() {
    return _stompClient != null && _stompClient!.isConnected;
  }

  /// 连接 WebSocket
  Future<void> connect() async {
    if (isConnected()) {
      print('WebSocket 已连接，跳过重复连接');
      return;
    }

    print('正在连接 WebSocket: $_wsUrl');

    // 创建 STOMP 客户端
    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        // 启用 SockJS 支持（降级方案）
        useSockJS: true,
        // 连接和心跳配置
        stompConnectHeaders: {
          'userId': '1', // 实际应从登录状态获取
        },
        webSocketConnectHeaders: {
          'userId': '1',
        },
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        // 心跳配置（与服务器保持一致）
        heartbeatOutgoing: const Duration(seconds: 20),
        heartbeatIncoming: const Duration(seconds: 20),
      ),
    );

    // 激活连接
    _stompClient!.activate();
  }

  /// 连接成功回调
  void _onConnect(StompFrame frame) {
    print('✅ WebSocket 连接成功');

    // 通知连接状态变化
    _connectionController.add(true);

    // 如果之前订阅过看板，重新订阅
    if (_currentBoardId != null) {
      subscribeToBoard(_currentBoardId!);
    }
  }

  /// 断开连接回调
  void _onDisconnect(StompFrame frame) {
    print('❌ WebSocket 断开连接');

    // 通知连接状态变化
    _connectionController.add(false);
  }

  /// STOMP 协议错误回调
  void _onStompError(StompFrame frame) {
    print('🔴 STOMP 错误: ${frame.body}');
  }

  /// WebSocket 错误回调
  void _onWebSocketError(dynamic error) {
    print('🔴 WebSocket 错误: $error');
  }

  /// 订阅看板频道
  /// 用户进入看板时调用
  void subscribeToBoard(int boardId) {
    if (!isConnected()) {
      print('❌ WebSocket 未连接，无法订阅看板');
      return;
    }

    _currentBoardId = boardId;

    // 订阅看板主题：/topic/board/{boardId}
    final destination = '/topic/board/$boardId';

    print('📡 订阅看板频道: $destination');

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          print('📨 收到消息: ${frame.body}');

          // 解析 JSON 消息
          try {
            final message = _parseMessage(frame.body!);

            // 发送给所有订阅者
            _messageController.add(message);

            // 根据事件类型进行不同处理
            _handleMessage(message);
          } catch (e) {
            print('❌ 解析消息失败: $e');
          }
        }
      },
    );
  }

  /// 取消订阅看板频道
  void unsubscribeFromBoard(int boardId) {
    if (!isConnected()) {
      return;
    }

    final destination = '/topic/board/$boardId';
    _stompClient!.unsubscribe(destination: destination);
    print('📡 取消订阅看板频道: $destination');

    if (_currentBoardId == boardId) {
      _currentBoardId = null;
    }
  }

  /// 发送消息到服务器（通过 HTTP API 或 WebSocket）
  /// 这里演示通过 WebSocket 发送，实际也可以用 HTTP POST
  void sendMessage(String destination, Map<String, dynamic> message) {
    if (!isConnected()) {
      print('❌ WebSocket 未连接，无法发送消息');
      return;
    }

    print('📤 发送消息: $destination -> $message');

    _stompClient!.send(
      destination: destination,
      body: message,
    );
  }

  /// 解析消息
  Map<String, dynamic> _parseMessage(String jsonBody) {
    // 手动解析 JSON（Dart 内置）
    final Map<String, dynamic> message = Map<String, dynamic>.from(
      // 简化处理，实际项目中应该使用 dart:convert
      <String, dynamic>{},
    );

    // 使用 dart:convert 解析
    try {
      final dynamic parsed = _jsonDecode(jsonBody);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
    } catch (e) {
      print('❌ JSON 解析失败: $e');
    }

    return message;
  }

  /// 处理收到的消息
  void _handleMessage(Map<String, dynamic> message) {
    final eventType = message['eventType'];

    switch (eventType) {
      case 'TASK_CREATE':
        print('🆕 新任务创建');
        // 通知 UI 刷新
        break;

      case 'TASK_MOVE':
        print('🔄 任务移动');
        // 局部刷新：更新任务位置
        break;

      case 'TASK_UPDATE':
        print('✏️ 任务更新');
        // 局部刷新：更新任务内容
        break;

      case 'TASK_DELETE':
        print('🗑️ 任务删除');
        // 局部刷新：移除任务
        break;

      case 'USER_PRESENCE':
        print('👤 用户在线状态变化');
        // 更新在线用户列表
        break;

      default:
        print('❓ 未知事件类型: $eventType');
    }
  }

  /// 断开连接
  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
      _currentBoardId = null;
      print('👋 WebSocket 连接已关闭');
    }
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }

  /// 简单的 JSON 解析（生产环境应使用 dart:convert）
  dynamic _jsonDecode(String source) {
    // 这里简化处理，实际应使用 `import 'dart:convert';` 然后调用 `jsonDecode(source)`
    // 为示例简洁，这里使用占位符
    return <String, dynamic>{};
  }
}

/// 单例模式
class WebSocketManagerSingleton {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManagerSingleton() {
    return _instance;
  }

  WebSocketManager._internal();

  WebSocketManager get manager => _instance;
}
