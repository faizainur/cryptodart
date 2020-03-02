import 'dart:io';
import 'package:cryptodart/cryptodart.dart' as cryptodart;
import 'package:args/args.dart';

const mainHelper = '''
Usage     : cryptodart <command> [options] [<flags>]

Example   : cryptodart encrypt --help
            cryptodart gen-keypair --path 'save/path/to/destined/dir'
            cryptodart decrypt --sinput 'Hello World' --path 'path/to/dir' --no-base64 -x8
                       ------- ---------------------- ------------------------------------
                          |               |                            |
                      <command>       [options]                    [<flags>]
  
commands  :
  hash           Use this command to hash data using one-way hashing algorithm.
                    run [crypto hash --help] for further details about this command.

  encrypt        Use this command to encrypt data using asymmetric encryption algorithms like RSA.
                 [RSA]
                    run [crypto encrypt --help] for further details about this command.

  decrypt        Use this command to decrypt encrypted data using asymmetric encryption algorithms.
                    run [crypto decrypt --help] for further details about this command.
          
                  NB] Please remember to always use the same keypair for encrytion and decryption.
      
  gen-keypair    Generate keypair, public key and private key, and save the key as [.pem] files to destined directory.

  help           Show helper.
    
    ''';

void main(List<String> arguments) {
  if (arguments.isNotEmpty) {
    initArgs(arguments);
  } else {
    stdout.writeln(mainHelper);
  }
}

/* This method will initialized the options, commands, and flags. */
Future<void> initArgs(List<String> arguments) async {
  /* 
    This object used to define options and flags for [hash] command.

    Options :
      - [-t]  [--type]    Specify the type of the hashing algorithm
      - [-s]  [--sinput]  String input to the algorithm.
    
    Flag    :
      - [-h]  [--help]    Show helper for hashing.
   */
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

  /* 
    This object used to define options and flags for [encrypt] command.

    Options :
      - [-s]  [--sinput]  String input to the algorithm.
    
    Flags   :
      - [-p]  [--path]        Specify the path to the key file [.pem].
      -       [--pem-string]  Use this command to directly passing the key as a string.
      - [-x]  [--hex]         Show the encrypted data as hexadecimal.
      - [-b]  [--base64]      Show the encrypred data as base64. (DEFAULT ON)
              [--no-base64]   Set this flag to not use base64.
      - [-8]  [--bytes]       Show the encrypted data as bytes.
      - [-h]  [--help]        Show helper for encryption.
   */
  final encryptOptionParser = ArgParser()
    // ..addOption(
    //   'type',
    //   abbr: 't',
    //   allowed: ['RSA'],
    //   help: 'Specify the type of the encryption algorithm ',
    // )
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
      help: 'Show helper for encryption',
    );

  /* 
    This object used to define options and flags for [decrypt] command.

    Options :
      - [-s]  [--sinput]  String input to the algorithm.
    
    Flags   :
      - [-p]  [--path]        Specify the path to the key file [.pem].
      -       [--pem-string]  Use this command to directly passing the key as a string.
      - [-h]  [--help]        Show helper for decryption.
   */
  final decryptOptionParser = ArgParser()
    // ..addOption(
    //   'type',
    //   abbr: 't',
    //   allowed: ['RSA'],
    //   help: 'Specify the type of the encryption algorithm',
    // )
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
      help: 'Show helper for decryption',
    );

  /* 
    This object used to define options and flags for [gen-keypair] command.

    Flags   :
      - [-p]  [--path]        Specify the path to save directory of the keypair files [.pem].
   */
  final genKeyPairOption = ArgParser()
    ..addFlag(
      'path',
      abbr: 'p',
      help: 'Specify the path to save',
    );
    
  /* 
    This object used to define commands of the program.

    Commands :
      - [hash]          Use this command to hash data.
      - [encrypt]       Use this command to encrypt data.
      - [decrypt]       Use this command to decrypt data.
      - [gen-keypair]   Use this command to generate keypair files and save the [.pem] files to destined directory.
      - [help]          Show main helper.
    
   */
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
    )
    ..addCommand('help', ArgParser())
    ..addFlag('help', abbr: 'h');

  // This object used for parsing the arguments.
  final argsInput = parser.parse(arguments);

  // Check if there is [help] command in the argument, will show the main helper.
  if (argsInput.command.name == 'help') {
    stdout.writeln(mainHelper);
  }

  // Check if there is [hash] command in the argument.
  if (argsInput.command.name == 'hash') {
    // sinput == String input
    String sinput;

    // Check if there is [--help] flag
    if (argsInput.command['help']) {
      if (argsInput.command.arguments.length == 1) {
        // Show the helper for [hash] command.
        stdout.writeln(hashOptionParser.usage);
      } else {
        stdout.writeln('Invalid options');
      }
    } else {
      // Get the input data
      sinput = argsInput.command['sinput'];

      // Start hashing the data using the selected type hashing algorithm.
      cryptodart.processHash(
          argsInput.command['type'].toString().toUpperCase(), sinput);
    }
  }

  // Check if there is [encrypt] command in the arguments.
  if (argsInput.command.name == 'encrypt') {
    // sinput == String input
    String sinput;

    // Check if there is [--help -h] flag in the arguments
    if (argsInput.command['help']) {
      if (argsInput.command.arguments.length == 1) {
        // Show the helper for [encrypt] command
        stdout.writeln(encryptOptionParser.usage);
      } else {
        stdout.writeln('Invalid options');
      }
    } else {
      // Get the input data
      sinput = argsInput.command['sinput'];

      var chiperText;

      if ((argsInput.command['path'] && argsInput.command['pem-string']) ||
          (!argsInput.command['path'] && !argsInput.command['pem-string'])) {
        // If the user set both the [--path -p] and [--pem-string] flags.
        // Program will showing error message
        stdout.writeln('Invalid options');
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
          stdout.writeln(cryptodart.base64toBytes(chiperText));
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
          stdout.writeln(cryptodart.base64toBytes(chiperText));
          stdout.writeln('\n');
        }
      }
    }
  }

  if (argsInput.command.name == 'decrypt') {
    String sinput;
    if (argsInput.command['help']) {
      if (argsInput.command.arguments.length == 1) {
        stdout.writeln(encryptOptionParser.usage);
      } else {
        stdout.writeln('Invalid options');
      }
    } else {
      sinput = argsInput.command['sinput'];
    }
    var plainText;

    if ((argsInput.command['path'] && argsInput.command['pem-string']) ||
        (!argsInput.command['path'] && !argsInput.command['pem-string'])) {
      stdout.writeln('Invalid options');
    } else if (argsInput.command['path']) {
      plainText = await cryptodart.processRsaDecrpytPemPath(
          sinput, argsInput.command.rest[0]);
      stdout.writeln('\n' + plainText);
    } else if (argsInput.command['pem-string']) {
      plainText = await cryptodart.processRsaDecrpytPemString(
          sinput, argsInput.command.rest[0]);
      stdout.writeln(plainText);
    }
  }
  if (argsInput.command.name == 'gen-keypair') {
    if (argsInput.command['path']) {
      final path = argsInput.command.rest[0];
      await cryptodart.writePemFiles(path);
    }
  }
}
