# Easy Modcharting — Format Guide

---

## File Structure

```
assets/songs/yourSongName/modchart (CPU).json
assets/songs/yourSongName/modchart (GPU).json
```

You can use just CPU, just GPU, or both at the same time. Each one is completely independent.

---

## Basic Format

Every JSON file follows this structure:

```json
{
  "modchart": [
    ...events go here...
  ]
}
```

---

## Event Types

### Instant Set
Snaps a modifier to a value immediately at a given beat or step.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4 }
{ "modifier": "drunk", "value": 1, "startStep": 16 }
```

### Tween
Smoothly transitions a modifier from its current value to a target value over time.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "elastic", "easeDir": "Out" }
{ "modifier": "drunk", "value": 1, "startStep": 16, "endStep": 32, "ease": "expo", "easeDir": "In" }
```

### Snap then Tween (endValue)
Snaps to `value` instantly at `startBeat`, then tweens to `endValue` by `endBeat`.

```json
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4, "endBeat": 8, "ease": "bounce", "easeDir": "Out" }
```

Useful for rotation resets — instead of two separate events, one line does both.

### Repeater
Repeats an event every X beats or steps for a given duration.

```json
{ "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "duration": 0.5, "every": 1, "each": "beat", "during": 8, "startBeat": 4 } }
```

With steps:
```json
{ "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "durationStep": 2, "every": 4, "each": "step", "during": 8, "startStep": 16 } }
```

---

## Fields Reference

### Normal Events

| Field | Required | Description |
|-------|----------|-------------|
| `modifier` | Yes | Modifier name |
| `value` | Yes | Target value |
| `startBeat` or `startStep` | Yes | When to trigger |
| `endBeat` or `endStep` | No | If present, tweens from start to end |
| `endValue` | No | Snaps to `value` then tweens to `endValue` (requires `endBeat` or `endStep`) |
| `ease` | No | Ease type, defaults to `linear` |
| `easeDir` | No | Ease direction: `In`, `Out`, `InOut` |

### Repeater Events

| Field | Required | Description |
|-------|----------|-------------|
| `modifier` | Yes | Modifier name |
| `value` | Yes | Value to set on each repeat |
| `every` | Yes | How often to repeat |
| `each` | Yes | Unit for `every`: `beat` or `step` |
| `during` | Yes | How many times to repeat |
| `startBeat` or `startStep` | No | When to start, defaults to beat 0 |
| `endValue` | No | Tweens to this value after each snap |
| `duration` | No | Tween duration in beats (requires `endValue`) |
| `durationStep` | No | Tween duration in steps (requires `endValue`) |
| `ease` | No | Ease type, defaults to `linear` |
| `easeDir` | No | Ease direction: `In`, `Out`, `InOut` |

---

## Timing

- `startBeat` / `endBeat` — beat-based timing
- `startStep` / `endStep` — step-based timing (4 steps = 1 beat)
- Beats and steps can be mixed freely in the same file
- `duration` — tween duration in beats
- `durationStep` — tween duration in steps

---

## Easing

**Types:** `linear`, `quad`, `cube`, `quart`, `quint`, `expo`, `sine`, `circ`, `bounce`, `elastic`, `back`

**Directions:** `In`, `Out`, `InOut`

If `ease` is omitted it defaults to `linear`. If `easeDir` is omitted no direction suffix is applied.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "Out" }
```

---

## Turning Modifiers Off

Set `value` to `0` to turn a modifier off:

```json
{ "modifier": "drunk", "value": 0, "startBeat": 16, "endBeat": 20, "ease": "expo", "easeDir": "In" }
```

---

## Common Mistakes

**Don't use `endValue` without `endBeat` or `endStep`**
```json
// WRONG — nothing to tween to
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4 }

// CORRECT
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4, "endBeat": 8 }
```

**Don't use lowercase ease directions**
```json
// WRONG
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "out" }

// CORRECT
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "Out" }
```

**Don't mix up CPU and GPU modifiers**

CPU and GPU have different modifier libraries. Using a CPU-only modifier in `modchart (GPU).json` will give you a `WARNING: unknown GPU modifier` in the logs and it won't work.

**Don't forget to turn modifiers off**

Modifiers stay active until you set them back to 0. If you turn on `drunk` at beat 4 it will stay on forever unless you turn it off later.

**Don't use `endBeat` without `ease` if you want a smooth transition**

Without `ease` it defaults to `linear` which may not look great for every modifier. Always add an ease type for the best results.

---

## CPU Modifiers

Full list: https://github.com/theoo-h/FunkinModchart/tree/main/modchart/engine/modifiers/list

---

## GPU Modifiers

`x`, `y`, `z`, `xP1`, `xP2`, `angleX`, `angleY`, `angleZ`, `scaleX`, `scaleY`, `flip`, `invert`, `drunk`, `drunkP1`, `drunkP2`, `tipsy`, `reverse`, `reverseP1`, `reverseP2`, `boost`, `brake`, `speed`, `beat`, `beatYP1`, `beatYP2`, `confusion`, `alpha`, `opponentAlpha`, `incomingAngleX`, `incomingAngleY`, `incomingAngleZ`, `InvertIncomingAngle`, `IncomingAngleSmooth`, `IncomingAngleCurve`, `MoveYWaveShit`, `flash`

---

*Easy Modcharting by Edwin — Credits: TheZoroForce240 (GPU Framework), _theodev (CPU Framework)*
