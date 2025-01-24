class WebSocketConfig {
  static const pusherAppCluster = 'YOUR_PUSHER_APP_CLUSTER';
  static const pusherAppKey = 'YOUR_PUSHER_APP_KEY';
  static const webSocketPusherURL =
      'wss://ws-${WebSocketConfig.pusherAppCluster}.pusher.com/app/${WebSocketConfig.pusherAppKey}?protocol=7&client=Flutter&version=1.0&flash=false';
}
