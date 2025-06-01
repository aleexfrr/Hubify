export async function obtenerPerfilesXbox(nombreUsuario) {
  try {
    const res = await fetch(`https://xbl.io/api/v2/search/${nombreUsuario}`, {
      method: "GET",
      headers: {
        "X-Authorization": "7781f1ce-1977-4b76-912c-78d2d1cbe0fe"
      }
    });

    if (!res.ok) {
      throw new Error(`Error HTTP: ${res.status}`);
    }

    const data = await res.json();
    
    return data; //  Aquí sí devuelves el JSON
  } catch (err) {
    console.error("Error al obtener perfil Xbox:", err);
    throw err; // Puedes lanzar el error para manejarlo desde fuera
  }
}

export async function obtenerDatosCuentaXbox(XUID) {
  try {
    const res = await fetch(`https://xbl.io/api/v2/account/${XUID}`, {
      method: "GET",
      headers: {
        "X-Authorization": "7781f1ce-1977-4b76-912c-78d2d1cbe0fe"
      }
    });

    if (!res.ok) {
      throw new Error(`Error HTTP: ${res.status}`);
    }

    const data = await res.json();
    
    return data; //  Aquí sí devuelves el JSON
  } catch (err) {
    console.error("Error al obtener datos de la cuenta de Xbox:", err);
    throw err; // Puedes lanzar el error para manejarlo desde fuera
  }
}

export async function obtenerJuegosCuentaXbox(XUID) {
  try {
    const res = await fetch(`https://xbl.io/api/v2/achievements/player/${XUID}`, {
      method: "GET",
      headers: {
        "X-Authorization": "7781f1ce-1977-4b76-912c-78d2d1cbe0fe",
        "Accept-Language": "es-ES" // 👈 lenguaje válido
      }
    });

    if (!res.ok) {
      const errorBody = await res.text();
      throw new Error(`Error HTTP: ${res.status} - ${errorBody}`);
    }

    const data = await res.json();
    return data;
  } catch (err) {
    console.error("Error al obtener juegos de la cuenta de Xbox:", err);
    throw err;
  }
}


