import 'dart:convert';
import 'dart:io';

import '../lib/cryptodart.dart';
import 'package:args/args.dart';
import 'package:io/io.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:crypto/crypto.dart';
// import 'package:encrypt/encrypt.dart';
// import 'package:pointycastle/asymmetric/api.dart';

void main(List<String> arguments) {
  final hashOptionParser = ArgParser()
    ..addOption(
      'type',
      abbr: 't',
      allowed: ['MD5', 'md5', 'SHA-1', 'sha-1'],
      help: 'Specify the type of the hashing algorithm (REQUIRED)',
    )
    ..addOption(
      'sinput',
      abbr: 's',
      help: 'String input to the algorithm (REQUIRED)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show helper for hashing',
    );

  final encryptOptionParser = ArgParser()
    ..addOption(
      'type',
      abbr: 't',
      allowed: ['RSA'],
      help: 'Specify the type of the encryption algorithm (REQUIRED)',
    )
    ..addOption(
      'sinput',
      abbr: 's',
      help: 'String input to the algorithm (REQUIRED)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show helper for hashing',
    )
    ..addFlag(
      'hex',
      abbr: 'x',
      help: 'Represent the chipertext as Hexadecimal',
      negatable: false
    )
    ..addFlag(
      'base64',
      abbr: 'b64'
    );
  ;

  final parser = ArgParser()
    ..addCommand(
      'hash',
      hashOptionParser,
    )
    ..addCommand(
      'encrypt',
      encryptOptionParser,
    );

  final argsInput = parser.parse(arguments);

  if (argsInput.command.name == 'hash') {
    String sinput;
    if ((argsInput.command.arguments.contains('--help') ||
        argsInput.command.arguments.contains('-h'))) {
      if (argsInput.command.arguments.length == 1) {
        print(hashOptionParser.usage);
      } else {
        print('Invalid options');
      }
    } else {
      if (!(argsInput.command.arguments.contains('--sinput') ||
          argsInput.command.arguments.contains('-s'))) {
        stdout.write('Input string : ');
        sinput = stdin.readLineSync();
      } else {
        sinput = argsInput.command['sinput'];
      }

      processHash(argsInput.command['type'].toString().toUpperCase(), sinput);
    }
  }

  if (argsInput.command.name == 'encrypt') {
    processRsaEncrpyt('Hello World');
  }
}

void processHash(String type, String plainText) {
  final hasher = HashCrypt(type);
  final digest = hasher.hash(plainText);
  final bytes = base64.decode(digest);
  final digestHex = bytesToHex(bytes);

  print('--------------------------------------------');
  print('Input string       : $plainText');
  print('Hashing algorithm  : $type');
  print('Hash in bytes      : $bytes');
  print('Hash in Base64     : $digest');
  print('Hash in hex        : $digestHex');
}

String bytesToHex(List<int> data) {
  String hex = '';

  // Convert every integer in data to hex, and add to variable hex
  data.forEach((value) => hex += value.toRadixString(16));

  return hex;
}

String processRsaEncrpyt(String plainText) {
  final encrypter = RsaCrypt();
  final chiperText = encrypter.encrypt(plainText, RsaCrypt().randPubKey);

  return chiperText;
}
