# 🧠 Mejores Prácticas para Godot 4.5 – Desarrollo 2D

Este documento recopila buenas prácticas profesionales para desarrollar juegos **2D en Godot 4.5**, enfocadas en orden, escalabilidad, rendimiento y mantenibilidad.

---

## 📁 1. Organización del Proyecto

### 🔹 Agrupar por funcionalidad (no por tipo)

❌ Evitar:

```
scripts/
scenes/
sprites/
```

✅ Recomendado:

```
res://
├─ core/
├─ systems/
│  ├─ input/
│  ├─ combat/
│  └─ board/
├─ scenes/
├─ entities/
├─ ui/
└─ assets/
```

📌 Todo lo relacionado a un sistema debe vivir junto.

---

## 🧱 2. Escenas

### 🔹 Una escena = una responsabilidad

* Escenas pequeñas y reutilizables
* Evitar escenas "monstruo"

Ejemplos:

* `player.tscn`
* `enemy.tscn`
* `hud.tscn`

---

### 🔹 Separar lógica y presentación

* La lógica va en *controllers*
* Los nodos visuales solo muestran

Ejemplo:

```
PlayerController (Node)
PlayerVisual (Node2D)
```

---

## 📜 3. Scripts

### 🔹 Un script = una responsabilidad

❌ Incorrecto:

```gdscript
player.gd # movimiento + UI + guardado
```

✅ Correcto:

```
player_data.gd
player_movement.gd
player_attack.gd
```

---

### 🔹 Nombres claros y consistentes

* Usar `snake_case`
* Evitar nombres genéricos

Ejemplo:

```
game_controller.gd
input_controller.gd
screen_transition.gd
```

---

### 🔹 Evitar scripts largos

* Ideal: < 300 líneas
* Si crece → refactorizar

---

## 🔄 4. Comunicación entre Nodos

### 🔹 Preferir signals

```gdscript
signal action_requested(data)
```

✔ Reduce acoplamiento
✔ Facilita mantenimiento

---

### 🔹 Evitar rutas largas

❌

```gdscript
get_parent().get_parent().get_node("UI/HUD")
```

✅

```gdscript
ui_controller.update_score()
```

---

## 🌍 5. Autoloads (Singletons)

Usarlos **con moderación**.

### Casos válidos:

* Estado global
* AudioManager
* SaveManager
* Configuración

❌ Evitar meter lógica de juego principal.

---

## 🎮 6. Input

### 🔹 Usar Input Map

* Nunca hardcodear teclas
* Permite rebinding

```gdscript
Input.is_action_pressed("move_left")
```

---

## ⚙️ 7. Rendimiento 2D

### 🔹 Usar nodos correctos

* `Node2D` para lógica
* `Sprite2D` solo para render
* `CanvasLayer` para UI

---

### 🔹 Evitar `_process()` innecesario

* Preferir señales
* Usar `_physics_process()` solo si es necesario

---

## 🧩 8. Diseño del Código

### 🔹 Data-driven design

* Usar `Resources` o JSON
* Separar datos de lógica

---

### 🔹 State Machines

Usar para:

* Jugador
* Enemigos
* Menús

---

## 🧪 9. Debug y Mantenimiento

* Usar `print_debug()`
* Agrupar logs
* Limpiar código muerto

---

## 🧠 10. Reglas de Oro

✔ Lo visual no decide reglas
✔ La lógica no depende de la UI
✔ Cambiar una cosa no rompe otra
✔ El código se entiende al volver en 6 meses

---

## ✅ Señales de un Buen Proyecto

* Escala sin volverse caótico
* Fácil de refactorizar
* Scripts cortos
* Claridad total de responsabilidades

---

> "Un proyecto bien organizado es un proyecto que sobrevive." 🚀
