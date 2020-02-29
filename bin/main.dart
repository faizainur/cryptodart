import 'dart:io';
import 'package:cryptodart/cryptodart.dart' as cryptodart;
import 'package:args/args.dart';

// import 'package:encrypt/encrypt.dart';
// import 'package:pointycastle/asymmetric/api.dart';

void main(List<String> arguments) {
  initArgs(arguments);
}

Future<void> initArgs(List<String> arguments) async {
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
      help: 'Specify the type of the encryption algorithm',
    )
    ..addOption(
      'sinput',
      abbr: 's',
      help: 'String input to the algorithm (REQUIRED)',
    )
    ..addFlag(
      'path',
      abbr: 'p',
      help: 'Specify the path to the the key',
    )
    ..addFlag(
      'pem-string',
      help: 'Input the key as string',
    )
    ..addFlag('hex',
        abbr: 'x',
        help: 'Represent the chipertext as Hexadecimal',
        negatable: false)
    ..addFlag('base64',
        abbr: 'b',
        help: 'Represent the chipertext as Base64 (RECOMMENDED)',
        defaultsTo: true,
        negatable: true)
    ..addFlag(
      'bytes',
      abbr: '8',
      negatable: false,
      help: 'Represent the chipertext as bytes (NOT RECOMMENDED)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show helper for hashing',
    );

  final decryptOptionParser = ArgParser()
    ..addOption(
      'type',
      abbr: 't',
      allowed: ['RSA'],
      help: 'Specify the type of the encryption algorithm',
    )
    ..addOption(
      'sinput',
      abbr: 's',
      help: 'String input to the algorithm (REQUIRED)',
    )
    ..addFlag(
      'path',
      abbr: 'p',
      help: 'Specify the path to the key',
    )
    ..addFlag(
      'pem-string',
      help: 'Input the key as string',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show helper for hashing',
    );

  final genKeyPairOption = ArgParser()
    ..addFlag(
      'path',
      abbr: 'p',
      help: 'Specify the path to save',
    );

  final parser = ArgParser()
    ..addCommand(
      'hash',
      hashOptionParser,
    )
    ..addCommand(
      'encrypt',
      encryptOptionParser,
    )
    ..addCommand(
      'decrypt',
      decryptOptionParser,
    )
    ..addCommand(
      'gen-keypair',
      genKeyPairOption,
    );

  final argsInput = parser.parse(arguments);

  if (argsInput.command.name == 'hash') {
    // sinput == String input
    String sinput;
    if (argsInput.command['help']) {
      if (argsInput.command.arguments.length == 1) {
        stdout.write(hashOptionParser.usage);
      } else {
        stdout.write('Invalid options');
      }
    } else {
      if (!(argsInput.command.arguments.contains('--sinput') ||
          argsInput.command.arguments.contains('-s'))) {
        stdout.write('Input string : ');
        sinput = stdin.readLineSync();
      } else {
        sinput = argsInput.command['sinput'];
      }

      cryptodart.processHash(
          argsInput.command['type'].toString().toUpperCase(), sinput);
    }
  }

  if (argsInput.command.name == 'encrypt') {
    // sinput == String input
    String sinput;
    String path;
    if (argsInput.command['help']) {
      if (argsInput.command.arguments.length == 1) {
        stdout.write(encryptOptionParser.usage);
      } else {
        stdout.write('Invalid options');
      }
    } else {
      if (!(argsInput.command.arguments.contains('--sinput') ||
          argsInput.command.arguments.contains('-s'))) {
        stdout.write('Input string : ');
        sinput = stdin.readLineSync();
      } else {
        sinput = argsInput.command['sinput'];
      }

      var chiperText;

      if ((argsInput.command['path'] && argsInput.command['pem-string']) ||
          (!argsInput.command['path'] && !argsInput.command['pem-string'])) {
        stdout.write('Invalid options');
      } else {
        chiperText = await cryptodart.processRsaEncrpytPemPath(
            sinput, argsInput.command.rest[0]);
        if (argsInput.command['base64']) {
          stdout.writeln('Chipertext in base64 : ');
          stdout.writeln(chiperText + '\n');
        }

        if (argsInput.command['hex']) {
          stdout.writeln('Chipertext in hex : ');
          stdout.writeln(cryptodart.base64toHex(chiperText) + '\n');
        }

        if (argsInput.command['bytes']) {
          stdout.writeln('Chipertext in bytes : ');
          stdout.write(cryptodart.base64toBytes(chiperText));
          stdout.writeln('\n');
        }
      }
    }

    if (argsInput.command.name == 'decrypt') {
      String sinput;
      if (argsInput.command['help']) {
        if (argsInput.command.arguments.length == 1) {
          stdout.write(encryptOptionParser.usage);
        } else {
          stdout.write('Invalid options');
        }
      } else {
        if (!(argsInput.command.arguments.contains('--sinput') ||
            argsInput.command.arguments.contains('-s'))) {
          stdout.write('Input string : ');
          sinput = stdin.readLineSync();
        } else {
          sinput = argsInput.command['sinput'];
        }
      }
      // stdout.write(cryptodart.processRsaDecrpyt(sinput));
      // stdout.write(argsInput.arguments);
    }

    if (argsInput.command.name == 'gen-keypair') {
      if (argsInput.command['path']) {
        final path = argsInput.command.rest[0];

        cryptodart.writePemFiles(path);
      }
    }
  }
}
