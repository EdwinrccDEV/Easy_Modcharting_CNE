# Easy Modcharting — Format Guide

---

## Before You Start

### What is a modifier?
A modifier is an effect applied to the notes during gameplay — things like making notes wave, spin, flip, or move. Each modifier has a name and a value. A value of `0` means the modifier is off. Any other value turns it on with that intensity.

### What is a beat? What is a step?
A **beat** is a unit of musical time — it lines up with the BPM of the song. You can find the beat number of any point in the song by looking at the charter.

A **step** is a smaller unit — there are always **4 steps in 1 beat**. Steps are useful when you need more precise timing than beats allow.

### What is an ease?
An ease controls how a value changes over time. Instead of jumping instantly from one value to another, an ease makes it smoothly transition. Different ease types produce different motion curves — `bounce` will bounce at the end, `elastic` will overshoot and snap back, `expo` will accelerate quickly, and so on.

### What is a tween?
A tween is a smooth transition from one value to another over a period of time. You define where it starts, where it ends, and how long it takes.

---

## File Structure

Place your JSON files inside your song folder:

```
assets/songs/yourSongName/modchart (CPU).json
assets/songs/yourSongName/modchart (GPU).json
```

You can use just CPU, just GPU, or both at the same time. Each one is completely independent.

---

## Basic Format

Every JSON file follows this structure. The `modchart` array holds all your events in order.

```json
{
  "modchart": [
    ...events go here...
  ]
}
```

Each event is a single line inside the array, separated by commas. The order of events inside the array does not matter — the parser sorts them by beat automatically.

---

## Event Types

### Instant Set
Snaps a modifier to a value immediately at a given beat or step. No transition — it just jumps to that value.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4 }
{ "modifier": "drunk", "value": 1, "startStep": 16 }
```

Use this when you want something to happen immediately without any animation.

### Tween
Smoothly transitions a modifier from its current value to a target value over time. Requires a start, an end, and an ease.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "elastic", "easeDir": "Out" }
{ "modifier": "drunk", "value": 1, "startStep": 16, "endStep": 32, "ease": "expo", "easeDir": "In" }
```

The modifier will start transitioning at `startBeat` and finish at `endBeat`. The `ease` and `easeDir` control the shape of the transition.

### Snap then Tween (endValue)
Snaps to `value` instantly at `startBeat`, then immediately starts tweening to `endValue` by `endBeat`.

```json
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4, "endBeat": 8, "ease": "bounce", "easeDir": "Out" }
```

This is useful for effects that need to start at a specific value and then animate back. For example: snap to full rotation then bounce back to 0. Without `endValue` you would need two separate events to achieve the same result.

### Repeater (GPU ONLY)
Repeats an event automatically every X beats or steps. Instead of writing the same event dozens of times, you write it once and tell it how many times to repeat.

```json
{ "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "duration": 0.5, "every": 1, "each": "beat", "during": 8, "startBeat": 4 } }
```

This reads as: starting at beat 4, every 1 beat, for 8 times, snap flash to 1 then tween it to 0 over 0.5 beats.

With steps:
```json
{ "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "durationStep": 2, "every": 4, "each": "step", "during": 8, "startStep": 16 } }
```

To repeat multiple modifiers at the same time, just add multiple repeater entries:
```json
{
  "modchart": [
    { "repeater": { "modifier": "flash", "value": 1, "endValue": 0, "duration": 0.5, "every": 1, "each": "beat", "during": 8, "startBeat": 4 } },
    { "repeater": { "modifier": "drunk", "value": 1, "endValue": 0, "duration": 0.5, "every": 1, "each": "beat", "during": 8, "startBeat": 4 } }
  ]
}
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

Reference: https://easings.net

---

## Turning Modifiers Off

Modifiers do not turn off automatically. Once a modifier is active it stays active until you explicitly set it back to `0`. If you forget to turn a modifier off it will remain active for the rest of the song.

```json
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "elastic", "easeDir": "Out" },
{ "modifier": "drunk", "value": 0, "startBeat": 16, "endBeat": 20, "ease": "expo", "easeDir": "In" }
```

---

## Common Mistakes

**Don't use `endValue` without `endBeat` or `endStep`**

`endValue` needs a destination beat to know when to finish the tween. Without it the tween has no duration and nothing will happen.

```json
// WRONG — nothing to tween to
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4 }

// CORRECT
{ "modifier": "angleZ", "value": 360, "endValue": 0, "startBeat": 4, "endBeat": 8 }
```

**Don't use lowercase ease directions**

`easeDir` is case-sensitive. `Out` works, `out` does not.

```json
// WRONG
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "out" }

// CORRECT
{ "modifier": "drunk", "value": 1, "startBeat": 4, "endBeat": 8, "ease": "expo", "easeDir": "Out" }
```

**Don't mix up CPU and GPU modifiers**

CPU and GPU have different modifier libraries. Using a CPU-only modifier in `modchart (GPU).json` will produce a `WARNING: unknown GPU modifier` in the logs and the modifier will not be applied. Always check which framework supports the modifier you want to use.

**Don't forget to turn modifiers off**

Modifiers stay active until you set them back to 0. If you turn on `drunk` at beat 4 it will stay on for the rest of the song unless you turn it off later.

**Don't use `endBeat` without `ease` if you want a smooth transition**

Without `ease` the tween defaults to `linear`, which moves at a constant speed with no acceleration or deceleration. This may not look good for every modifier. Add an ease type for better results.

**Don't add a trailing comma after the last event**

JSON does not allow a comma after the last item in an array. This will cause the file to fail to parse.

```json
// WRONG
{
  "modchart": [
    { "modifier": "drunk", "value": 1, "startBeat": 4 },
  ]
}

// CORRECT
{
  "modchart": [
    { "modifier": "drunk", "value": 1, "startBeat": 4 }
  ]
}
```

---

## CPU Modifiers

Full list: https://github.com/theoo-h/FunkinModchart/tree/main/modchart/engine/modifiers/list

---

## GPU Modifiers

`x`, `y`, `z`, `xP1`, `xP2`, `angleX`, `angleY`, `angleZ`, `scaleX`, `scaleY`, `flip`, `invert`, `drunk`, `drunkP1`, `drunkP2`, `tipsy`, `reverse`, `reverseP1`, `reverseP2`, `boost`, `brake`, `speed`, `beat`, `beatYP1`, `beatYP2`, `confusion`, `alpha`, `opponentAlpha`, `incomingAngleX`, `incomingAngleY`, `incomingAngleZ`, `InvertIncomingAngle`, `IncomingAngleSmooth`, `IncomingAngleCurve`, `MoveYWaveShit`, `flash`

---

*Easy Modcharting by Edwin — Credits: TheZoroForce240 (GPU Framework), _theodev (CPU Framework)*
