import 'package:chitchat/config/agora_config.dart';
import 'package:chitchat/feature/call/controller/call_controller.dart';
import 'package:chitchat/feature/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;
  static String token = 'https://chitchat-app-f4998734cc6a.herokuapp.com';
  static String appId = 'ba5888394d7a4d45987e21f47354c0b3';
  static String appcertificate = '63603cd8c1cd430db60fcf361ad3f27b';

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  late RtcEngine _engine;
  bool _isJoined = false;
  bool _remoteUserJoined = false;
  bool _isMuted = false;
  bool _isVideoDisabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    // Agora motorunu oluştur
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(appId: AgoraConfig.appId),
    );

    // Olayları yapılandır
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
          });
          debugPrint('Kanala katıldı: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUserJoined = true;
          });
          debugPrint('Uzaktaki kullanıcı katıldı: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUserJoined = false;
          });
          debugPrint('Uzaktaki kullanıcı ayrıldı: $remoteUid');
        },
      ),
    );

    // Video etkinleştir ve kanala katıl
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Yerel ve uzak video görünümü
            Column(
              children: [
                Expanded(
                  child: _isJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0), // Yerel video
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
                Expanded(
                  child: _remoteUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 1), // Uzak video
                            connection: const RtcConnection(
                                channelId:
                                    'your_channel_id'), // Gerekli parametre eklendi
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Kullanıcının katılması bekleniyor...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
            // Kontrol düğmeleri
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Sesi kapatma düğmesi
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                        _engine.muteLocalAudioStream(_isMuted);
                      },
                      icon: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                      iconSize: 36,
                    ),
                    // Kamerayı çevirme düğmesi
                    IconButton(
                      onPressed: () async {
                        await _engine.switchCamera();
                      },
                      icon: const Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                      ),
                      iconSize: 36,
                    ),
                    // Çağrıyı sonlandırma düğmesi
                    IconButton(
                      onPressed: () async {
                        await _engine.leaveChannel();
                        ref.read(callControllerProvider).endCall(
                              widget.call.callerId,
                              widget.call.receiverId,
                              context,
                            );
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.call_end,
                        color: Colors.red,
                      ),
                      iconSize: 56,
                    ),
                    // Videoyu kapatma düğmesi
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isVideoDisabled = !_isVideoDisabled;
                        });
                        _engine.muteLocalVideoStream(_isVideoDisabled);
                      },
                      icon: Icon(
                        _isVideoDisabled ? Icons.videocam_off : Icons.videocam,
                        color: Colors.white,
                      ),
                      iconSize: 36,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
