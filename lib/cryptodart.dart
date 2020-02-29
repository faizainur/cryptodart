import 'package:steel_crypt/steel_crypt.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
void processHash(String type, String plainText) {
  final hasher = HashCrypt(type);
  final digest = hasher.hash(plainText);

  final digestBytes = base64toBytes(digest);
  final digestHex = bytesToHex(digestBytes);

  stdout.write('--------------------------------------------');
  stdout.write('Input string       : $plainText');
  stdout.write('Hashing algorithm  : $type');
  stdout.write('Hash in bytes      : $digestBytes');
  stdout.write('Hash in Base64     : $digest');
  stdout.write('Hash in hex        : $digestHex');
}

List<int> base64toBytes(String data) {
  return base64.decode(data);
}

String base64toHex(String data) {
  return bytesToHex(base64toBytes(data));
}

String bytesToHex(List<int> data) {
  var hex = '';

  // Convert every integer in data to hex, and add to variable hex
  data.forEach((value) => hex += value.toRadixString(16));

  return hex;
}

Future<String> readPemFile(String path) async {
  var key;

  final pemFile = File(path);

  if (await pemFile.exists()) {
    key = await pemFile.readAsString();
  }

  return key;
}

Future<String> processRsaEncrpytPemPath(String plainText, String path) async {
  final encrypter = RsaCrypt();
  final pubkey = RsaCrypt().parseKeyFromString(await readPemFile(path));
  final chiperText = encrypter.encrypt(plainText, pubkey);
  
  return chiperText;
}

String processRsaEncrpytPemString(String plainText, String key) {
  final encrypter = RsaCrypt();
  final pubkey = RsaCrypt().parseKeyFromString(key);
  final chiperText = encrypter.encrypt(plainText, pubkey);
  
  return chiperText;
}

Future<String> processRsaDecrpytPemPath(String chiperText, String path) async {
  final privkey = RsaCrypt().parseKeyFromString(await readPemFile(path));
  final decrypter = RsaCrypt();
  final plainText = decrypter.decrypt(chiperText, privkey);
  return plainText;
}

String processRsaDecrpytPemString(String chiperText, String key) {
  final privkey = RsaCrypt().parseKeyFromString(key);
  final decrypter = RsaCrypt();
  final plainText = decrypter.decrypt(chiperText, privkey);
  return plainText;
}

void writePemFiles(String path) async {
  final pubkey = RsaCrypt().encodeKeyToString(RsaCrypt().randPubKey);
  final privkey = RsaCrypt().encodeKeyToString(RsaCrypt().randPrivKey);
  final pubPath = p.join(path, 'pubkey.pem');
  final privPath = p.join(path, 'privkey.pem');

  await File(privPath).writeAsString(privkey);
  await File(pubPath).writeAsString(pubkey);

  if (await File(privPath).exists() && await File(pubPath).exists()) {
    stdout.write('Success !!!');
  }
}
