import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../providers/auth_notifier.dart';

class ImageUploads extends StatefulWidget {
  const ImageUploads({Key? key}) : super(key: key);

  @override
  ImageUploadsState createState() => ImageUploadsState();
}

class ImageUploadsState extends State<ImageUploads> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery(userUid, context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile(userUid);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No image selected')));
      }
    });
  }

  Future uploadFile(userUid) async {
    if (_photo == null) return;
    final destination = 'avatars/$userUid';

    try {
      final ref = storage.ref(destination);
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    var photoUrl = context.watch<AuthNotifier>().userAvatar;
    return Row(children: [
      CircleAvatar(
        radius: 55,
        backgroundColor: null,
        child: _photo != null || photoUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: photoUrl == null
                    ? Image.file(
                        _photo!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      )
                    : Image.network(photoUrl, width: 100, height: 100),
              )
            : Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(50)),
                width: 100,
                height: 100,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.grey[800],
                ),
              ),
      ),
      Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 15, 10),
              child: Text(
                '${context.read<AuthNotifier>().user?.email}',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
          Container(
              padding: const EdgeInsets.fromLTRB(40, 10, 15, 10),
              child: ElevatedButton(
                onPressed: () {
                  var userUid = context.read<AuthNotifier>().user?.uid;
                  _showPicker(context, userUid);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                child: const Text('Create Avatar'),
              ))
        ],
      )
    ]);
  }

  void _showPicker(context, userUid) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery(userUid, context);
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          );
        });
  }
}
