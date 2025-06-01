import fetch from "node-fetch"; // <-- Asegúrate de instalarlo si usas Node.js <18

// ✅ Nueva función que obtiene el perfil de Steam desde un steamId
export async function obtenerPerfilSteam(steamId) {
  const API_KEY = 'E87B4144A08CBB4D15B717600EA15724'; // Usa variable de entorno en prod
  const url = `http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=${API_KEY}&steamids=${steamId}`;

  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`Error HTTP: ${res.status}`);

    const data = await res.json();
    if (!data.response || !data.response.players || data.response.players.length === 0) {
      throw new Error('Perfil no encontrado');
    }
    return data.response.players[0];
  } catch (err) {
    console.error('Error al obtener perfil Steam:', err);
    throw err;
  }
}




const API_KEY = 'E87B4144A08CBB4D15B717600EA15724'; // Usa una variable de entorno en producción

// ✅ Obtiene los juegos de Steam que posee un usuario junto con sus estadísticas
export async function obtenerJuegosConStats(steamId) {
  const urlGames = `http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=${API_KEY}&steamid=${steamId}&include_appinfo=1&format=json`;

  try {
    const res = await fetch(urlGames);
    if (!res.ok) throw new Error(`Error al obtener juegos: ${res.status}`);

    const data = await res.json();
    const juegos = data.response?.games;

    if (!juegos || juegos.length === 0) {
      return [];
    }

    // Obtener estadísticas para cada juego (en paralelo, pero limitado)
    const juegosConStats = await Promise.all(
      juegos.map(async (juego) => {
        const stats = await obtenerStatsJuego(juego.appid, steamId);
        return {
          ...juego,
          stats: stats || null,
        };
      })
    );

    return juegosConStats;
  } catch (err) {
    console.error("Error al obtener juegos con estadísticas:", err);
    throw err;
  }
}

// ✅ Obtiene las estadísticas de un juego concreto para un usuario
async function obtenerStatsJuego(appid, steamId) {
  const urlStats = `http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=${appid}&key=${API_KEY}&steamid=${steamId}`;

  try {
    const res = await fetch(urlStats);
    if (!res.ok) return null; // Algunos juegos no tienen stats

    const data = await res.json();
    return data.playerstats;
  } catch (err) {
    console.warn(`No se pudieron obtener stats para appid ${appid}:`, err.message);
    return null;
  }
}
