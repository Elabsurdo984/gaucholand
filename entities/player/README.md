# 🎮 Player Entity - Estructura Modular

El jugador ha sido refactorizado en **4 componentes especializados** siguiendo el principio de responsabilidad única.

## 📁 Archivos

- **`player.gd`** - Script raíz (orquestador mínimo)
- **`player_controller.gd`** - Física e input (~118 líneas)
- **`player_visual.gd`** - Animaciones y efectos visuales (~63 líneas)
- **`player_death.gd`** - Secuencia cinemática de muerte (~133 líneas)
- **`player_collision.gd`** - Gestión dinámica de colisiones (~51 líneas)
- **`player.tscn`** - Escena del jugador
- **`animacion_jugador.tres`** - Recurso de animaciones

## ⚠️ IMPORTANTE: Estructura de la Escena

La escena `player.tscn` debe actualizarse en Godot para tener esta estructura:

```
Player (CharacterBody2D) → player.gd
├─ PlayerController (Node) → player_controller.gd
├─ PlayerVisual (Node) → player_visual.gd
├─ PlayerDeath (Node) → player_death.gd
├─ PlayerCollision (Node) → player_collision.gd
├─ AnimatedSprite2D
│  └─ [SpriteFrames: animacion_jugador.tres]
├─ CollisionShape2D
├─ SonidoSalto (AudioStreamPlayer)
└─ SonidoMorir (AudioStreamPlayer)
```

## 🔧 Instrucciones para Actualizar la Escena en Godot

1. Abrir `player.tscn` en Godot Editor
2. Seleccionar el nodo raíz (CharacterBody2D)
3. Cambiar el script a `player.gd`
4. Agregar 4 nodos hijos de tipo `Node`:
   - Nombrar: `PlayerController`, `PlayerVisual`, `PlayerDeath`, `PlayerCollision`
5. Asignar scripts a cada nodo:
   - PlayerController → `player_controller.gd`
   - PlayerVisual → `player_visual.gd`
   - PlayerDeath → `player_death.gd`
   - PlayerCollision → `player_collision.gd`
6. Verificar que AnimatedSprite2D, CollisionShape2D y AudioStreamPlayers estén en el nivel raíz
7. Guardar la escena

## 📊 División de Responsabilidades

### PlayerController
- Física (gravedad, salto)
- Input del jugador
- Estado (vivo, agachado)
- Coordina Visual y Collision

### PlayerVisual
- Reproduce animaciones
- Efectos visuales (parpadeo, tinte, rotación)
- Gestiona AnimatedSprite2D

### PlayerDeath
- Recibe daño
- Gestiona invencibilidad
- Secuencia cinemática de muerte
- Coordina con LivesManager

### PlayerCollision
- Modifica colisión dinámicamente
- Agacharse/levantarse
- Gestiona CollisionShape2D

## 🔗 Dependencias

- **LivesManager** (autoload) - Gestión de vidas
- **SceneManager** (autoload) - Transiciones
- **GameManager** (autoload) - Estado global

## ✅ Beneficios

- ✅ Scripts < 150 líneas (vs 166 líneas originales)
- ✅ Responsabilidad única por script
- ✅ Fácil de testear individualmente
- ✅ Separación lógica/visual clara
- ✅ Mantenible y escalable
