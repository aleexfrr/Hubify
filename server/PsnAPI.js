import {
  getProfileFromUserName,
  exchangeNpssoForAccessCode,
  exchangeAccessCodeForAuthTokens,
  getUserPlayedGames,
  getProfileFromAccountId,
} from "psn-api";

const myNpsso = "d0barsLW5c8iMXu4rHU3F2Um8bIQWS7vAZ8Yv6OgRLZYJ7sDA4lykUNJT08aBMCS";

let authorization;

async function inicializarAutenticacion() {
  if (!authorization) {
    const accessCode = await exchangeNpssoForAccessCode(myNpsso);
    authorization = await exchangeAccessCodeForAuthTokens(accessCode);
  }
}

export async function obtenerPerfilPsn(nombreUsuario) {
  await inicializarAutenticacion();
  const perfil = await getProfileFromUserName(authorization, nombreUsuario);
  return perfil;
}

export async function obtenerJuegosPsn(accountId, opciones = {}) {
  await inicializarAutenticacion();
  const juegos = await getUserPlayedGames(authorization, accountId, opciones);
  return juegos;
}

// ✅ NUEVA FUNCIÓN QUE OBTIENE PERFIL DESDE accountId
export async function obtenerPerfilDesdeAccountId(accountId) {
  await inicializarAutenticacion();
  const response = await getProfileFromAccountId(authorization, accountId);
  return response;
}
