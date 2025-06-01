const UBI_APP_ID = "3587dcbb-7f81-457c-9781-0e3f29f6f56a"; // App ID de Rainbow Six Siege

export async function loginUbisoft(email, password) {
  const res = await fetch("https://public-ubiservices.ubi.com/v2/profiles/sessions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Ubi-AppId": UBI_APP_ID,
      "User-Agent": "UbiServices_SDK_2020.Release.27_PC64_ansi_static",
      "Accept": "*/*",
      "Connection": "keep-alive"
    },
    body: JSON.stringify({
      email,
      password,
      rememberMe: true
    })
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Login fallido: ${res.status} - ${errorText}`);
  }

  const data = await res.json();
  return {
    ticket: data.ticket,
    userId: data.userId,
    nameOnPlatform: data.nameOnPlatform
  };
}

export async function obtenerPerfilUbisoft(ticket) {
  const res = await fetch("https://public-ubiservices.ubi.com/v3/profiles/me", {
    method: "GET",
    headers: {
      "Authorization": `Ubi_v1 t=${ticket}`,
      "Ubi-AppId": UBI_APP_ID,
      "User-Agent": "UbiServices_SDK_2020.Release.27_PC64_ansi_static",
      "Accept": "*/*",
      "Connection": "keep-alive"
    }
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Error al obtener perfil: ${res.status} - ${errorText}`);
  }

  return await res.json();
}
