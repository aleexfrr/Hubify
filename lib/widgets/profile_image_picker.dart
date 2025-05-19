import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    final exists = await _pickedImage!.exists();
    print('Imagen seleccionada: ${_pickedImage!.path}');
    print('¿El archivo existe? $exists');

    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo de imagen no encontrado')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await ref.putFile(_pickedImage!); // sube
      final url = await ref.getDownloadURL(); // obtiene URL

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'imageUrl': url,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } catch (e) {
      print('❌ Error al subir imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir imagen: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : null,
          child: _pickedImage == null ? const Icon(Icons.person, size: 50) : null,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Seleccionar imagen'),
          onPressed: _pickImage,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadImage,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Subir imagen'),
        ),
      ],
    );
  }
}
