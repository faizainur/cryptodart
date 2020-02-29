import 'dart:io';
import 'package:cryptodart/cryptodart.dart' as cryptodart;
import 'package:args/args.dart';
import 'package:steel_crypt/steel_crypt.dart';

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
      } else if (argsInput.command['path']) {
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
      } else if (argsInput.command['pem-string']) {
        chiperText = await cryptodart.processRsaEncrpytPemString(
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
  }

  if (argsInput.command.name == 'decrypt') {
    // RsaCrypt crypt = RsaCrypt();
    // final pubkey = crypt.parseKeyFromString(await cryptodart.readPemFile('/home/xenon/Documents/pem/pubkey.pem'));
    // final privkey = crypt.parseKeyFromString(await cryptodart.readPemFile('/home/xenon/Documents/pem/privkey.pem'));
    // var chiperText = crypt.encrypt('Hello world', pubkey);

    // // print(await cryptodart.readPemFile('/home/xenon/Documents/pem/privkey.pem'));
    // print(chiperText + '\n');

    // var plainText = crypt.decrypt(chiperText, privkey);
    // print(plainText);

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
    var plainText;

    if ((argsInput.command['path'] && argsInput.command['pem-string']) ||
        (!argsInput.command['path'] && !argsInput.command['pem-string'])) {
      stdout.write('Invalid options');
    } else if (argsInput.command['path']) {
      plainText = await cryptodart.processRsaDecrpytPemPath(
          sinput, argsInput.command.rest[0]);

//       plainText = RsaCrypt().decrypt(
//           '''fVn0sRgrNskNjfF9SGWCmCVCo+HR6h2fMBar0I6LAbqSNzHXJfE/Mx6769R2MBACfzsy9nz239WFaoDtFfrpILrH8HgHC6e1gq2kE9bmja4RzQhdyCK23eW7ipPky/kJsCRsApVLQyqVGSF558ejhomKJL18ApvCzKf1xfVHJTBa4sLoFIU3AXfl+OFHE4DKtFsMRNF9bgn6s9oK1OcbDdxG6A/m8fjU7CDMnbyWCJsC/8Y0xlQ1x4rQ7ZEfgFSjsBR2IaaLAk5kOr/ZAO8G29o1wdAJW0VXSMocqy6oUz2dYwANEDbEHULApKDw8T2dLPqpLs/6u1+adc6lADzc1g==''',
//           RsaCrypt().parseKeyFromString('''-----BEGIN PRIVATE KEY-----
// MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCFDmudLOE8hg/C7gQcq+WAHcmpV9M7qm48HB/yX59S6MXrDQaMiavsc0a93Vse4a5XS7SiKbPnmjHMkoawlGZWCYZWRdPOocHT0XCPIlU7QmLPsOrrv4j3ssOXTk6gA2PTEW6Ey9R/2cQPmTfZKlQXBWeGoK2hfIOK2y+RVxg2XwOKsD2J54R2rbX6119nABRhCEZYV6mEaX9vB/5z4hl7UAOloKxaRWC4OCtRr4fE6K0mqFJfKOfkGUq02apu6m9Abm+YATtn4FiF3Zzaoi/4vwWXghLfVBw5KapttaFvT2AxYXa2svCFk7f9EMihGrq5D/kmBC5RrGQ+y9xEfUhJAgMBAAECggEAFL0tqt7+8HcY59I/k9R7Ph/med21j/w9mGLt29Jpu/uKNdve5HLk+ELziM6C0GpuyS6Epi4H25aeInvIQKew18I+TR4vKGrwEjr352d7j3QGgMbbpwlAqRMVB3VuLeS5X4G9DzfSFGd19tRz7wZ4+umdvE85IQ2OV0tYu7euj3LAEnzzY1wy6iNXgVDiPdAGHwvL2RkaoHFpUMgY7BFmEppDLu4eNvgEwDSLZQPzewItw6asAYu0PbY8743zsXcRijArpWPeUviPKkHShL+5fi5T5CIxHHIjgs+C3sZaVXsyzoqG7k9k9M/UxH2op77HFGCMw+yv4kHGvmdyt0ndHQKBgQDJbBV4/HVCs4zWQzjq8YoBstP2eLL8IxhVVqSqctZowtJSCPiqWR0hSX7YerKxvTyG2kSOVS2qV16Y4eFjqUOqO2DC2nY+NEu6YpN8pVKnobU0CP/ce5VsaxlL4wLg7Xoa7oRBhZ0H8L5X4EKAWuQNx67zMBlwF/sjMJIjBB/R0wKBgQCpHAw5Dd7D0kJKFeOvXDfMLn6e/pHp0GMjrL1nzFvoW0FG0keYBMKbTRwGSfWuYlo0iZQEZAIppAYwD/8jExJILvzwJBSVBrLpzVrluec/Nr0t/u5YaB/TMU5A3LfJW6BiXR6uSp1h8pFR3qSzwGasD9ZubcX1QtkmyXPpprNP8wKBgB30FtVhJcb/kIgkgwhdVxqdj2vt0yAvz+SQ9/fpD/2QS1qrvt8GVZCnr1deF8jazW94cg2AmUPlrkmp/aymdUuRfPg9KKxjdoeHNUuqAjqvj5TnabVOI5B19NMWNU1hw3DR25Uq24lcwdGrpfgUjCmIcnnzwzSqPEylYnYWnOzFAoGBAIjrYqIXLtQRuwZM7soeujahNnf42Z8b0AkkZT5TYd6hdBqpSro0sHQZXKVi4H5Ot4ZuFd/wMSgR28iySvrVCCpVkQnFzLxUbiuKzxvNBwRRh55kGAqQU6Qk+ZzemBd6DkNV7e9kDkUtpqdIwsWe9AI/2HgUfQD1HOigly8If4otAoGAf6++vqchxJJKeFEDaiIPAU6Wm/Qu/E8+ANYHbGSga7pUgPAXnolj6L7y6xw2g2DmeXJ7gRtpFicr1NL3p1YW3yX6iTeV2Eu+eYA5JjyYVVT8N7/e0IqVjj5Uw1naRi9hJ3B3dGuZi5GEFYQnji1a7M+ew8aLZq2we/PRSAJyfxw=
// -----END PRIVATE KEY-----'''));

      stdout.write(plainText);
    } else if (argsInput.command['pem-string']) {
      plainText = await cryptodart.processRsaDecrpytPemString(
          sinput, argsInput.command.rest[0]);
      stdout.write(plainText);
    }
  }
  if (argsInput.command.name == 'gen-keypair') {
    if (argsInput.command['path']) {
      final path = argsInput.command.rest[0];

      cryptodart.writePemFiles(path);
    }
    // print(await cryptodart.readPemFile('/home/xenon/Documents/pem/pubkey.pem'));

  }
}
