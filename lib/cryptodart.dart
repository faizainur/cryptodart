import 'package:steel_crypt/steel_crypt.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

/* 
  Use this function to to hash plainText data using selected hashing algorithm

  @param String   type         Specify the type of hasing algorithm
  @param String   plainText    Input data to the algorithm

 */
void processHash(String type, String plainText) {

  // Create the HashCrypt object for the selected type hashing algorithm.
  final hasher = HashCrypt(type);
  // Hash the plainText and save the result to variable digest. Default base64.
  final digest = hasher.hash(plainText);

  // Represent the digest as byte codes.
  final digestBytes = base64toBytes(digest);

  // Represent the digest as hexadecimal.
  final digestHex = bytesToHex(digestBytes);

  // Print the result to the screen
  stdout.writeln('--------------------------------------------');
  stdout.writeln('Input string       : $plainText');
  stdout.writeln('Hashing algorithm  : $type');
  stdout.writeln('Hash in bytes      : $digestBytes');
  stdout.writeln('Hash in Base64     : $digest');
  stdout.writeln('Hash in hex        : $digestHex');
}

/* 
  Convert base64 data to bytes data

  @param  String     data  input Data
  @return List<int>        Return list of byte integer data.
*/
List<int> base64toBytes(String data) {
  return base64.decode(data);
}

/* 
  Convert base64 data to hexadecimal.

  @param  String  data  Input data
  @return String        Return the hexadecimal data as string
*/
String base64toHex(String data) {
  return bytesToHex(base64toBytes(data));
}

/* 
  Convert byte codes to hexadecimal.

  @param  List<int>   data  List of integers as input data.
  #return String      hex   Return the hexadecimal data as string.
*/
String bytesToHex(List<int> data) {
  
  // String hex
  var hex = '';

  // Convert every integer in data to hex, and add to variable hex
  data.forEach((value) => hex += value.toRadixString(16));

  return hex;
}

/* 
  Use this function to read [.pem] files.
  
  THIS IS AN ASYNCHRONUS FUNCTION.

  @param  String          path    The path to the [.pem] file.
  @return Future<String>  key     Return the content of the file as string.
*/
Future<String> readPemFile(String path) async {
  // String key to store the content of the file
  var key;

  // Create File object of the file.
  final pemFile = File(path);

  // If the file is exist
  if (await pemFile.exists()) {
    // Read the content of the file as string, 
    // and store the content to variable key
    key = await pemFile.readAsString();
  }

  return key;
}

/* 
  Use this function to encrypt the plainText data using RSA algorithm.
  Load the public key from saved [.pem] file

  THIS IS AN ASYNCHRONUS FUNCTION

  @param  String          plainText    Input data to the encryption algorithm
  @param  String          path         The path to the key file [.pem]
  @return Future<String>  chiperText   Return the chiperText as string.

 */
Future<String> processRsaEncrpytPemPath(String plainText, String path) async {
  // Create the object of RsaCrypt
  final encrypter = RsaCrypt();

  // Load the public key from [.pem] file
  final pubkey =  encrypter.parseKeyFromString(await readPemFile(path));

  // Perform the encryption using the public key.
  final chiperText = encrypter.encrypt(plainText, pubkey);
  
  return chiperText;
}

/* 
  Use this function to encrypt the plainText data using RSA algorithm 
  directly passing the public key to the arguments

  @param  String    plainText    Input data to the encryption algorithm
  @param  String    key          Directy passing the public key string to the function.
  @return String    chiperText   Return the chiperText as string.

 */
String processRsaEncrpytPemString(String plainText, String key) {
  // Create the object of RsaCrypt
  final encrypter = RsaCrypt();

  // Load the public key
  final pubkey = encrypter.parseKeyFromString(key);

  // Perform the encryption using the public key.
  final chiperText = encrypter.encrypt(plainText, pubkey);
  
  return chiperText;
}

/* 
  Use this function to decrypt the chiperText data using RSA algorithm.
  Load the private key from saved [.pem] file

  THIS IS AN ASYNCHRONUS FUNCTION

  @param  String          chiperText   Input data to the decryption algorithm
  @param  String          path         The path to the key file [.pem]
  @return Future<String>  plainText    Return the plainText as string.

 */
Future<String> processRsaDecrpytPemPath(String chiperText, String path) async {
  // Create the object of RsaCrypt
  final decrypter = RsaCrypt();
  
  // Load the private key from [.pem] file.
  final privkey = decrypter.parseKeyFromString(await readPemFile(path));

  // Perform the decryption algorithm using the private key.
  final plainText = decrypter.decrypt(chiperText, privkey);

  return plainText;
}

/* 
  Use this function to decrypt the chiperText data using RSA algorithm 
  directly passing the private key to the arguments

  @param  String    chiperText   Input data to the encryption algorithm
  @param  String    key          Directy passing the public key string to the function.
  @return String    plainText    Return the chiperText as string.

 */
String processRsaDecrpytPemString(String chiperText, String key) {
  // Create the object of RsaCrypt
  final decrypter = RsaCrypt();

  // Load the private key
  final privkey = decrypter.parseKeyFromString(key);

  // Perform the decryption algorithm using the private key.
  final plainText = decrypter.decrypt(chiperText, privkey);

  return plainText;
}

/* 
  Use this function to generate keypair, public key and private key
  and save the keys as [.pem] files.

  THIS IS AN ASYNCHRONUS FUNCTION

  @param  String    chiperText   Input data to the encryption algorithm
  @param  String    key          Directy passing the public key string to the function.
  @return String    plainText    Return the chiperText as string.

 */
Future<void> writePemFiles(String path) async {
  // Create the object of RsaCrypt
  final keypairGenerator = RsaCrypt();

  // Generate the public key and store the key as string to variable pubkey.
  final pubkey = keypairGenerator.encodeKeyToString(keypairGenerator.randPubKey);

  // Generate the private key and store the key as string to variable privkey.
  final privkey = keypairGenerator.encodeKeyToString(keypairGenerator.randPrivKey);

  // Join the string path and public key file name
  final pubPath = p.join(path, 'pubkey.pem');

  // Join the string path and private key file name
  final privPath = p.join(path, 'privkey.pem');

  // writeln the private key to the file
  await File(privPath).writeAsString(privkey);

  // writeln the public key to the file.
  await File(pubPath).writeAsString(pubkey);

  // Check if the process is success by checking the file
  if (await File(privPath).exists() && await File(pubPath).exists()) {
    stdout.writeln('Success !!!');
  }
}
