# game_manager.gd
# Gestión del estado global del juego
extends Node

# ============================================================
# SIGNALS
# ============================================================
signal mates_cambiados(nuevos_mates: int)
signal vidas_cambiadas(nuevas_vidas: int)
signal objetivo_alcanzado

# ============================================================
# CONSTANTES
# ============================================================
const MAX_VIDAS: int = 3
const OBJETIVO_MATES: int = 100  # Mates necesarios para ganar

# ============================================================
# VARIABLES
# ============================================================
var mates_totales: int = 0
var objetivo_alcanzado_flag: bool = false
var vidas: int = MAX_VIDAS
var causa_muerte: String = ""  # Razón del último Game Over

# ============================================================
# REFERENCIAS A OTROS MANAGERS
# ============================================================
# Estos se accederán como autoloads:
# - DifficultyManager
# - ConfigManager
# - SceneManager

# ============================================================
# PUBLIC METHODS
# ============================================================

## Agrega mates recolectados y verifica objetivos
func agregar_mates(cantidad: int) -> void:
	mates_totales += cantidad
	mates_cambiados.emit(mates_totales)
	print("Mates recolectados: ", mates_totales)

	# Delegar verificación de velocidad a DifficultyManager
	DifficultyManager.verificar_aumento_velocidad(mates_totales)

	# Verificar si se alcanzó el objetivo
	if mates_totales >= OBJETIVO_MATES and not objetivo_alcanzado_flag:
		objetivo_alcanzado_flag = true
		objetivo_alcanzado.emit()

		# Delegar transición a SceneManager
		SceneManager.iniciar_secuencia_transicion_rancho()

## Descuenta una vida y retorna true si quedan vidas
func descontar_vida() -> bool:
	vidas -= 1
	vidas_cambiadas.emit(vidas)
	print("💔 Vida perdida. Restantes: ", vidas)
	return vidas > 0

## Reinicia el estado del juego
func reiniciar_juego() -> void:
	mates_totales = 0
	vidas = MAX_VIDAS
	objetivo_alcanzado_flag = false
	causa_muerte = ""

	mates_cambiados.emit(mates_totales)
	vidas_cambiadas.emit(vidas)

	# Delegar reinicio de dificultad a DifficultyManager
	DifficultyManager.reiniciar()

	print("🔄 Juego reiniciado")

## Obtiene los mates recolectados
func obtener_mates() -> int:
	return mates_totales

## Obtiene las vidas restantes
func obtener_vidas() -> int:
	return vidas

## Verifica si el objetivo fue alcanzado
func objetivo_fue_alcanzado() -> bool:
	return objetivo_alcanzado_flag

## Obtiene la velocidad actual del juego (delegado a DifficultyManager)
func obtener_velocidad_actual() -> float:
	return DifficultyManager.obtener_velocidad_actual()

## Verifica si está en transición (delegado a SceneManager)
func en_transicion() -> bool:
	return SceneManager.esta_en_transicion()
