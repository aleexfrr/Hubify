# App Hubify

## Tenemos:
- Login/registro.
- Función agregar amigos.
- Función eliminar amigos.
- Perfil usuario.
- Editar perfil.
- Cuentas vinculadas (solo la vista).
- Modo oscuro.
- Barra de búsqueda de amigos y usuarios.
- Eliminar cuenta
- Deshabilitar cuenta.
- Corregir mensaje de error al tener cuenta deshabilitada.
- Servicio de vincular plataformas (solo xbox)

## Falta:
- Notificaciones de solicitudes de amistad.
- Widgets dinámicos estadísticas generales.
- Subir foto perfil.
- Servicios de vincular plataformas.

## Extras:
- Editar datos de info del perfil cuentas vinculadas (psn, xbox, …).

---

# Base de datos FireBase

## Tenemos:
- Colecciones de los usuarios:
    - Nombre
    - Apellidos
    - Correo
    - Nick-Name
    - Amigos
    - solicitudesEnviadas
    - solicitudesRecibidas
    - fechacreacion

## Falta:
- Colección de usuarios:
    - image
    - disabled (si esta o no deshabilitada la cuenta)
    - ArrayList plataformas

- Colección plataformas:
    - identificador colección
    - identificador usuario
        - plataforma: “Xbox”
        - Usuario: “jota14”
        - UIDUsuario: 12312321

## Extra:
- Crear colección admin
    - rango de permisos para eliminar.

---

# Servidor Nodejs

## Tenemos:
- Servidor para recibir y enviar info.

## Falta:
- Aplicar las APIs de cada plataforma.
