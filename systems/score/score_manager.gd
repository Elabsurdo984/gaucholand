# score_manager.gd
# Sistema de puntuación y recolección de mates
extends Node

# ============================================================
# SIGNALS
# ============================================================
signal mates_cambiados(nuevos_mates: int)
signal objetivo_alcanzado()

# ============================================================
# CONSTANTES
# ============================================================
const OBJETIVO_MATES: int = 1  # Mates necesarios para ganar

# ============================================================
# VARIABLES
# ============================================================
var mates_totales: int = 0
var objetivo_alcanzado_flag: bool = false

# ============================================================
# PUBLIC METHODS
# ============================================================

## Agrega mates recolectados y verifica si se alcanzó el objetivo
func agregar_mates(cantidad: int) -> void:
	mates_totales += cantidad
	mates_cambiados.emit(mates_totales)
	print("🧉 Mates recolectados: ", mates_totales, " / ", OBJETIVO_MATES)

	# Notificar a DifficultyManager para verificar aumento de velocidad
	if DifficultyManager:
		DifficultyManager.verificar_aumento_velocidad(mates_totales)

	# Verificar si se alcanzó el objetivo
	if mates_totales >= OBJETIVO_MATES and not objetivo_alcanzado_flag:
		objetivo_alcanzado_flag = true
		objetivo_alcanzado.emit()
		print("🎉 ¡Objetivo alcanzado! 100 mates recolectados")

		# Notificar a SceneManager para iniciar transición
		if SceneManager:
			SceneManager.iniciar_secuencia_transicion_rancho()

## Reinicia el contador de mates
func reiniciar() -> void:
	mates_totales = 0
	objetivo_alcanzado_flag = false
	mates_cambiados.emit(mates_totales)
	print("🔄 Score reiniciado")

## Obtiene los mates totales recolectados
func obtener_mates() -> int:
	return mates_totales

## Verifica si el objetivo fue alcanzado
func objetivo_fue_alcanzado() -> bool:
	return objetivo_alcanzado_flag

## Obtiene el progreso como porcentaje (0.0 - 1.0)
func obtener_progreso() -> float:
	return float(mates_totales) / float(OBJETIVO_MATES)
