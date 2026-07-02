class LoginModel {
  final String token;
  final ImModel im;

  LoginModel({required this.token, required this.im});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'] ?? '',
      im: ImModel.fromJson(json['im'] ?? {}),
    );
  }
}

class ImModel {
  final int sdkAppId;
  final String userId;
  final String userSig;
  final int expire;

  ImModel({
    required this.sdkAppId,
    required this.userId,
    required this.userSig,
    required this.expire,
  });

  factory ImModel.fromJson(Map<String, dynamic> json) {
    return ImModel(
      sdkAppId: json['sdkAppId'] ?? 0,
      userId: json['userId'] ?? '',
      userSig: json['userSig'] ?? '',
      expire: json['expire'] ?? 0,
    );
  }
}
