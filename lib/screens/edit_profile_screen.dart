import 'package:flutter/material.dart';
import '../constants/status_data.dart';
import '../services/user_service.dart';
import '../utilities/text_styles.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/profile_image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _estadoSeleccionado;
  bool _isLoading = false;

  String? _imagenLocalUrl; // URL local para mostrar preview de la imagen subida

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _userService.getUserData();
      if (userData != null) {
        _usuarioController.text = userData['username'] ?? '';
        _nombreController.text = userData['name'] ?? '';
        _apellidoController.text = userData['lastname'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _estadoSeleccionado = userData['status'] ?? StatusData.statusAvailables.first;
        _imagenLocalUrl = userData['imagenUrl']; // Si tienes url imagen guardada, la cargas aquí para preview
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos del usuario: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    final apodo = _usuarioController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final email = _emailController.text.trim();


    if (apodo.isEmpty || nombre.isEmpty || apellido.isEmpty || email.isEmpty || _estadoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Usamos la imagen seleccionada si existe, sino null (o si quieres subir siempre, cambia aquí)
      final imagenUrl = _imagenLocalUrl;

      await _userService.updateUserDocument(
        apodo: apodo,
        nombre: nombre,
        apellido: apellido,
        email: email,
        estado: _estadoSeleccionado!,
        imagenUrl: imagenUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar perfil', style: TextStyles.headerLarge),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Center(
                child: ProfileImagePicker(),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usuarioController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Nickname", Icons.person),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Nombre", Icons.person),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _apellidoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Apellido", Icons.person_outline),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Correo electrónico", Icons.email),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                items: StatusData.statusAvailables
                    .map((estado) => DropdownMenuItem(
                  value: estado,
                  child: Text(estado, style: TextStyle(color: StatusData.statusColors[estado])),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _estadoSeleccionado = value);
                    _updateProfile();
                  }
                },
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  "Estado",
                  Icons.circle,
                  iconColor: StatusData.statusColors[_estadoSeleccionado],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    CustomDialog.show(context, type: DialogType.updateProfile,
                      onConfirm: () {
                        Navigator.pop(context);
                        _updateProfile();
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Actualizar Perfil"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Color? iconColor}) {
    final Color effectiveColor = iconColor ?? Colors.white;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: effectiveColor),
      prefixIcon: Icon(icon, color: effectiveColor),
      errorStyle: const TextStyle(color: Colors.redAccent),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: effectiveColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: effectiveColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
