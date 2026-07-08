class SignInRequestModel {
  final String? email;
  final String? password;
  final String? provider;
  final String? idToken;
  final String? name;

  SignInRequestModel({
    this.email,
    this.password,
    this.provider,
    this.idToken,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "provider": provider,
      "idToken": idToken,
      "name": name,
    }..removeWhere((k, v) => v == null);
  }
}
