console.clear();
import express from "express";
import session from "express-session";
import passport from "passport";
import { Strategy as SteamStrategy } from "passport-steam";
import { loginUbisoft, obtenerPerfilUbisoft } from "./UbisoftAPI.js";
import { obtenerPerfilSteam, obtenerJuegosConStats } from "./SteamAPI.js";


import { obtenerPerfilPsn, obtenerJuegosPsn,obtenerPerfilDesdeAccountId } from "./PsnAPI.js";
import { obtenerPerfilesXbox,obtenerDatosCuentaXbox,obtenerJuegosCuentaXbox } from "./XboxAPI.js";

const PORT = 3000;
const app = express();


// ─────────────────────────────────────────────
// 🔐 STEAM PASSPORT CONFIGURACIÓN
// ─────────────────────────────────────────────
passport.use(new SteamStrategy({
  returnURL: 'http://192.168.249.225:3000/steam/login/return',
  realm: 'http://192.168.249.225:3000/',
  apiKey: 'E87B4144A08CBB4D15B717600EA15724' // ⚠️ Usa variable de entorno en producción
}, (identifier, profile, done) => {
  return done(null, profile);
}));

passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((obj, done) => done(null, obj));

app.use(session({
  secret: "secreto", // ⚠️ Usa una clave segura en producción
  resave: false,
  saveUninitialized: false
}));
app.use(passport.initialize());
app.use(passport.session());

// ─────────────────────────────────────────────
// 📦 API: PLAYSTATION
// ─────────────────────────────────────────────

// Obtener perfil PSN por nombre
app.get("/psn/cuenta/nombre/:nombre", async (req, res) => {
  const nombre = req.params.nombre;

  try {
    const perfil = await obtenerPerfilPsn(nombre);
    res.json(perfil);
  } catch (error) {
    console.error("Error al obtener perfil PSN:", error);
    res.status(500).json({ error: "Error al obtener perfil del jugador" });
  }
});

// Obtener perfil PSN por accountId
app.get("/psn/cuenta/accountId/:accountId", async (req, res) => {
  const accountId = req.params.accountId;

  try {
    const perfil = await obtenerPerfilDesdeAccountId(accountId);
    res.json(perfil);
  } catch (error) {
    console.error("Error al obtener perfil PSN por accountId:", error);
    res.status(500).json({ error: "Error al obtener perfil del jugador" });
  }
});

// Obtener juegos PSN por accountId
app.get("/psn/cuenta/juegos/:accountId", async (req, res) => {
  const accountId = req.params.accountId;

  try {
    const juegos = await obtenerJuegosPsn(accountId, { limit: 200, offset: 0 });
    res.json(juegos);
  } catch (error) {
    console.error("Error al obtener juegos PSN:", error);
    res.status(500).json({ error: "Error al obtener juegos del jugador" });
  }
});

// ─────────────────────────────────────────────
// 🎮 API: UBISOFT
// ─────────────────────────────────────────────

// Login a Ubisoft y obtener perfil (requiere email y password en query)
app.get("/ubisoft/login/:email/:password", async (req, res) => {
  const email = req.params.email;
  const password = req.params.password;

  if (!email || !password) {
    return res.status(400).json({ error: "Se requieren email y password como parámetros" });
  }

  try {
    const session = await loginUbisoft(email, password);
    console.log(session);
    //const perfil = await obtenerPerfilUbisoft(session.ticket);

    res.json({
      usuario: session.nameOnPlatform,
      userId: session.userId,
      //perfil
    });
  } catch (error) {
    console.error("Error en Ubisoft API:", error);
    res.status(500).json({ error: "Error al iniciar sesión o cargar perfil Ubisoft" });
  }
});


// ─────────────────────────────────────────────
// 📦 API: XBOX
// ─────────────────────────────────────────────

// Obtener perfil Xbox por gamertag
app.get("/xbox/perfiles/:gametag", async (req, res) => {
  const gametag = req.params.gametag;

  try {
    const perfilesXbox = await obtenerPerfilesXbox(gametag);
    res.json(perfilesXbox);
  } catch (error) {
    console.error("Error al obtener perfil Xbox:", error);
    res.status(500).json({ error: "Error al obtener perfil del jugador Xbox" });
  }
});

app.get("/xbox/cuenta/nombre/:XUID", async (req, res) => {
  const XUID = req.params.XUID;

  try {
    const cuentaXbox = await obtenerDatosCuentaXbox(XUID);
    res.json(cuentaXbox);
  } catch (error) {
    console.error("Error al obtener datos de la cuenta Xbox:", error);
    res.status(500).json({ error: "Error al obtener datos de la cuenta Xbox" });
  }
});

app.get("/xbox/cuenta/juegos/:XUID", async (req, res) => {
  const XUID = req.params.XUID;
  console.log(XUID);

  try {
    const juegosXbox = await obtenerJuegosCuentaXbox(XUID);
    res.json(juegosXbox);
  } catch (error) {
    console.error("Error al obtener juegos de la cuenta Xbox:", error);
    res.status(500).json({ error: "Error al obtener juegos de la cuenta Xbox" });
  }
});

// ─────────────────────────────────────────────
// 🔑 AUTH: STEAM (Passport)
// ─────────────────────────────────────────────

app.get("/", (req, res) => {
  if (req.isAuthenticated()) {
    res.send(`
      <h2>Hola, ${req.user.displayName}</h2>
      <p>SteamID64: ${req.user.id}</p>
      <img src="${req.user.photos[2]?.value}" alt="Avatar">
      <br><a href="/steam/logout">Cerrar sesión</a>
    `);
  } else {
    res.send(`<a href="/steam/login">Iniciar sesión con Steam</a>`);
  }
});

// Iniciar autenticación con Steam
app.get("/steam/login", passport.authenticate("steam"));

// Callback luego del login de Steam
app.get("/steam/login/return",
  passport.authenticate("steam", { failureRedirect: "/" }),
  (req, res) => {
    // En lugar de redirigir, puedes devolver JSON si prefieres
    res.json({
      steamId: req.user.id,
      displayName: req.user.displayName,
      photos: req.user.photos,
      profile: req.user._json
    });
  }
);

app.get("/steam/cuenta/nombre/:steamId", async (req, res) => {
  const steamId = req.params.steamId;

  try {
    const cuentaSteam = await obtenerPerfilSteam(steamId);
    res.json(cuentaSteam);
  } catch (error) {
    console.error("Error al obtener datos de la cuenta Steam:", error);
    res.status(500).json({ error: "Error al obtener datos de la cuenta Xbox" });
  }
});

app.get("/steam/cuenta/juegos/:steamId", async (req, res) => {
  const steamId = req.params.steamId;

  try {
    const juegoSteam = await obtenerJuegosConStats(steamId);
    res.json(juegoSteam);
  } catch (error) {
    console.error("Error al obtener datos de la cuenta Steam:", error);
    res.status(500).json({ error: "Error al obtener datos de la cuenta Xbox" });
  }
});

// Logout
app.get("/steam/logout", (req, res) => {
  req.logout(() => {
    res.redirect("/");
  });
});

// ─────────────────────────────────────────────
// 🚀 INICIAR SERVIDOR
// ─────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`Servidor conectado en http://localhost:${PORT}`);
});
