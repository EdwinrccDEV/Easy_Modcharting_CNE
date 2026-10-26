# Easy Modcharting — Guía de Formato

---

## Antes de Empezar

### ¿Qué es un modifier?
Un modifier es un efecto que se aplica a las notas durante el juego — cosas como hacer que las notas se muevan, giren, se volteen o hagan olas. Cada modifier tiene un nombre y un valor. Un valor de `0` significa que el modifier está apagado. Cualquier otro valor lo activa con esa intensidad.

### ¿Qué es un beat? ¿Qué es un step?
Un **beat** es una unidad de tiempo musical — se alinea con el BPM de la canción. Puedes encontrar el número de beat de cualquier punto de la canción mirando el charter.

Un **step** es una unidad más pequeña — siempre hay **4 steps en 1 beat**. Los steps son útiles cuando necesitas más precisión que la que ofrecen los beats.

### ¿Qué es un ease?
Un ease controla cómo cambia un valor con el tiempo. En lugar de saltar instantáneamente de un valor a otro, un ease lo hace transicionar suavemente. Diferentes tipos de ease producen diferentes curvas de movimiento — `bounce` rebotará al final, `elastic` se pasará y volverá, `expo` acelerará rápidamente, etc.

### ¿Qué es un tween?
Un tween es una transición suave de un valor a otro durante un período de tiempo. Defines dónde empieza, dónde termina y cuánto tiempo tarda.

---

## Estructura de Archivos

Coloca tus archivos JSON dentro de la carpeta de tu canción — tanto en el juego base como dentro de un mod (ambos se detectan automáticamente):

```
assets/songs/nombreDeTuCancion/modchart (CPU).json
assets/songs/nombreDeTuCancion/modchart (GPU).json
mods/TuMod/songs/nombreDeTuCancion/modchart (CPU).json
mods/TuMod/songs/nombreDeTuCancion/modchart (GPU).json
```

Puedes usar solo CPU, solo GPU, o ambos al mismo tiempo. Cada uno es completamente independiente.

### Archivos por dificultad y por variación

Puedes apuntar a dificultades o variaciones de canción específicas (ej. `erect`, `pico`) agregando un sufijo al nombre del archivo. El parser los prueba en este orden y usa el primero que encuentre:

```
modchart (GPU)-hard-erect.json   <- dificultad + variacion exactas (mas especifico)
modchart (GPU)-any-erect.json    <- cualquier dificultad, pero solo la variacion erect
modchart (GPU)-hard.json         <- solo la dificultad hard
modchart (GPU).json              <- generico, vale para todo lo demas
```

El mismo patrón funciona para `(CPU)`. Los nombres de dificultad salen del `meta.json` de la canción (`easy`, `normal`, `hard`, o personalizados). La variación `default` usa los archivos genéricos/de dificultad; `any` es un comodín que abarca todas las dificultades.

Ejemplo de setup: un modchart suave en `modchart (GPU).json`, uno intenso en `modchart (GPU)-hard.json`, y uno sincronizado a los charts alternos en `modchart (GPU)-any-erect.json`.

### Archivos faltantes o rotos

Una canción sin archivo de modchart no es un error — el parser simplemente la omite en silencio. Un archivo vacío, sin el campo `"modchart"` o con JSON inválido también se ignora sin romper nada: solo verás un aviso en la consola y la canción sigue sonando.

---

## Formato Básico

Cada archivo JSON sigue esta estructura. El array `modchart` contiene todos tus eventos en orden.

```json
{
  "modchart": [
    ...los eventos van aquí...
  ]
}
```

Cada evento es una línea dentro del array, separada por comas. El orden de los eventos dentro del array no importa — el parser los ordena por beat automáticamente.

---

## Tipos de Eventos

### Instant Set
Cambia un modifier a un valor inmediatamente en un beat o step dado. Sin transición — simplemente salta a ese valor.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4 }
{ "modifier": "drunk", "value": 1, "startStep": 16 }
```

Úsalo cuando quieras que algo ocurra inmediatamente sin ninguna animación.

### Tween
Transiciona suavemente un modifier desde su valor actual hasta un valor objetivo con el tiempo. Requiere un inicio, un fin y un ease.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "elastic", "easeDir": "Out" }
{ "modifier": "drunk", "value": 1, "startStep": 16, "endStep": 32, "ease": "expo", "easeDir": "In" }
```

El modifier comenzará a transicionar en `startBeat` y terminará en `endBeat`. El `ease` y `easeDir` controlan la forma de la transición.

### Snap then Tween (endValue)
Salta a `value` instantáneamente en `startBeat`, luego inmediatamente comienza a transicionar a `endValue` hasta `endBeat`.

```json
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4, "endBeat": 8, "ease": "bounce", "easeDir": "Out" }
```

Esto es útil para efectos que necesitan comenzar en un valor específico y luego volver. Por ejemplo: saltar a rotación completa y luego rebotar de vuelta a 0. Sin `endValue` necesitarías dos eventos separados para lograr el mismo resultado.

### Repeater (SOLO GPU)
Repite un evento automáticamente cada X beats o steps. En lugar de escribir el mismo evento docenas de veces, lo escribes una vez y le dices cuántas veces repetir.

> **Nota:** El repeater es solo para GPU porque el framework de CPU maneja el tiempo de manera diferente — `ease` y `callback` entran en conflicto cuando se programan en el mismo beat, haciendo que la repetición confiable sea imposible sin las funciones `set` y `ease` del GPU que no tienen esta limitación.

```json
{ "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "duration": 0.5, "every": 1, "each": "beat", "during": 8, "startBeat": 4 } }
```

Esto se lee como: comenzando en el beat 4, cada 1 beat, por 8 veces, snap flash a 1 y luego transiciónalo a 0 en 0.5 beats.

Con steps:
```json
{ "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "durationStep": 2, "every": 4, "each": "step", "during": 8, "startStep": 16 } }
```

### Loader (SOLO CPU)
Algunos modifiers de CPU son grupos con sub-modifiers — por ejemplo `rotateX`, `centerRotateZ` o `localRotateY` solo funcionan cuando su padre (`rotate`, `centerRotate`, `localRotate`) está cargado. Un evento normal `{ "modifier": "centerRotateX", ... }` solo fija una clave de valor, así que sin el padre no hace nada en silencio. Precarga el padre con una entrada `loader` (un nombre o un array):

```json
{ "loader": "centerRotate" }
{ "loader": ["rotate", "localRotate", "fieldRotate"] }
```

Después de eso, los sub-modifiers funcionan normal:

```json
{ "modifier": "centerRotateX", "value": 360, "startBeat": 2, "endBeat": 32, "ease": "sine", "easeDir": "InOut" }
```

Las entradas `loader` deben usar nombres de padres (`rotate`, `centerRotate`, …), nunca las variantes `X`/`Y`/`Z`. El lado GPU ignora las entradas `loader` — los modifiers GPU son todos planos y se registran solos.


---

## Referencia de Campos

### Eventos Normales

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `modifier` | Sí | Nombre del modifier |
| `value` | Sí | Valor objetivo |
| `startBeat` o `startStep` | Sí | Cuándo activar |
| `endBeat` o `endStep` | No | Si está presente, hace tween desde el inicio hasta el fin |
| `endValue` | No | Salta a `value` y luego hace tween a `endValue` (requiere `endBeat` o `endStep`) |
| `ease` | No | Tipo de ease, por defecto `linear` |
| `easeDir` | No | Dirección del ease: `In`, `Out`, `InOut` |

### Eventos Repeater (Solo GPU)

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `modifier` | Sí | Nombre del modifier |
| `value` | Sí | Valor a establecer en cada repetición |
| `every` | Sí | Con qué frecuencia repetir |
| `each` | Sí | Unidad para `every`: `beat` o `step` |
| `during` | Sí | Cuántas veces repetir |
| `startBeat` o `startStep` | No | Cuándo comenzar, por defecto beat 0 |
| `endValue` | No | Hace tween a este valor después de cada snap |
| `duration` | No | Duración del tween en beats (requiere `endValue`) |
| `durationStep` | No | Duración del tween en steps (requiere `endValue`) |
| `ease` | No | Tipo de ease, por defecto `linear` |
| `easeDir` | No | Dirección del ease: `In`, `Out`, `InOut` |

---

## Timing

- `startBeat` / `endBeat` — timing basado en beats
- `startStep` / `endStep` — timing basado en steps (4 steps = 1 beat)
- Beats y steps pueden mezclarse libremente en el mismo archivo
- `duration` — duración del tween en beats
- `durationStep` — duración del tween en steps

---

## Easing

**Tipos:** `linear`, `quad`, `cube`, `quart`, `quint`, `expo`, `sine`, `circ`, `bounce`, `elastic`, `back`

**Direcciones:** `In`, `Out`, `InOut`

Si `ease` se omite, por defecto es `linear`. Si `easeDir` se omite, no se aplica sufijo de dirección.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "Out" }
```

Referencia: https://easings.net

---

## Apagar Modifiers

Los modifiers no se apagan automáticamente. Una vez que un modifier está activo, permanece activo hasta que explícitamente lo vuelvas a `0`. Si olvidas apagar un modifier, permanecerá activo por el resto de la canción.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "elastic", "easeDir": "Out" },
{ "modifier": "drunk", "value": 0, "startBeat": 16, "endBeat": 20, "ease": "expo", "easeDir": "In" }
```

---

## Errores Comunes

**No uses `endValue` sin `endBeat` o `endStep`**

`endValue` necesita un beat de destino para saber cuándo terminar el tween. Sin él, el tween no tiene duración y nada pasará.

```json
// MAL — no hay destino para el tween
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4 }

// BIEN
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4, "endBeat": 8 }
```

**No uses direcciones de ease en minúsculas**

`easeDir` es sensible a mayúsculas. `Out` funciona, `out` no.

```json
// MAL
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "out" }

// BIEN
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "Out" }
```

**No mezcles modifiers de CPU y GPU**

CPU y GPU tienen diferentes librerías de modifiers. Usar un modifier exclusivo de CPU en `modchart (GPU).json` producirá un `WARNING: unknown GPU modifier` en los logs y el modifier no se aplicará. Siempre verifica qué framework soporta el modifier que quieres usar.

**No olvides apagar los modifiers**

Los modifiers permanecen activos hasta que los vuelvas a 0. Si activas `drunk` en el beat 4, seguirá activo por el resto de la canción a menos que lo apagues después.

**No uses `endBeat` sin `ease` si quieres una transición suave**

Sin `ease`, el tween usa `linear` por defecto, que se mueve a velocidad constante sin aceleración ni desaceleración. Esto puede no verse bien para todos los modifiers. Agrega un tipo de ease para mejores resultados.

**No agregues una coma al final del último evento**

JSON no permite una coma después del último elemento en un array. Esto hará que el archivo falle al parsear.

```json
// MAL
{
  "modchart": [
    { "modifier": "drunk", "value": 1, "startBeat": 4 },
  ]
}

// BIEN
{
  "modchart": [
    { "modifier": "drunk", "value": 1, "startBeat": 4 }
  ]
}
```

---

## Modifiers CPU

Lista completa: https://github.com/theoo-h/FunkinModchart/tree/main/modchart/engine/modifiers/list

---

## Modifiers GPU

`x`, `y`, `z`, `xP1`, `xP2`, `angleX`, `angleY`, `angleZ`, `scaleX`, `scaleY`, `flip`, `invert`, `drunk`, `drunkP1`, `drunkP2`, `tipsy`, `reverse`, `reverseP1`, `reverseP2`, `boost`, `brake`, `speed`, `beat`, `beatYP1`, `beatYP2`, `confusion`, `alpha`, `opponentAlpha`, `incomingAngleX`, `incomingAngleY`, `incomingAngleZ`, `InvertIncomingAngle`, `IncomingAngleSmooth`, `IncomingAngleCurve`, `MoveYWaveShit`, `flash`

---

*Easy Modcharting por Edwin — Créditos: TheZoroForce240 (GPU Framework), _theodev o Srt (CPU Framework)*
