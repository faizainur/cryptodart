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
        //stdout.write('$sinput');

      } else {
        sinput = argsInput.command['sinput'];
      }

      processHash(argsInput.command['type'].toString().toUpperCase(), sinput);
    }
    // if (argsInput.command.arguments.contains('-s')){
    //   print(argsInput.command['sinput']);
    // } else {
    //   print('error');
    // }
    // print('Hello');
  }
}

void processHash(String type, String plainText) {
  if (type == 'MD5') {
    final bytes = utf8.encode(plainText);
    Digest digest = md5.convert(bytes);

    print('--------------------------------------------');
    print('Input string       : $plainText');
    print('Hashing algorithm  : $type');
    print('Digest as bytes    : ${digest.bytes}');
    stdout.write('Digest as Base64   : ');
    digest.bytes.forEach((value) {
      stdout.write(value.toRadixString(16));
    });
    stdout.write('\n' + base64.encode(digest.bytes));
    print('\nDigest as hex      : $digest');

    final hasher = HashCrypt('MD5');

    print(500.toRadixString(16));
  }

  if (type == 'SHA-1') {
    final bytes = utf8.encode(plainText);
    final digest = sha1.convert(bytes);
    
    print('--------------------------------------------');
    print('Input string       : $plainText');
    print('Hashing algorithm  : $type');
    print('Digest as bytes    : ${digest.bytes}');
    print('Digest as hex      : $digest');

  
  }
}

void processEncrpyt(String type, String key, String plainText) {
  
}
