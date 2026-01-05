# lives_manager.gd
# Sistema de vidas del jugador
extends Node

# ============================================================
# SIGNALS
# ============================================================
signal vidas_cambiadas(vidas_restantes: int)
signal sin_vidas()
signal vida_perdida(vidas_restantes: int)

# ============================================================
# CONSTANTES
# ============================================================
const MAX_VIDAS: int = 3

# ============================================================
# VARIABLES
# ============================================================
var vidas: int = MAX_VIDAS
var causa_muerte: String = ""  # Razón del último Game Over

# ============================================================
# PUBLIC METHODS
# ============================================================

## Descuenta una vida y retorna true si quedan vidas
func descontar_vida() -> bool:
	vidas -= 1
	vidas_cambiadas.emit(vidas)
	vida_perdida.emit(vidas)
	print("💔 Vida perdida. Restantes: ", vidas, " / ", MAX_VIDAS)

	if vidas <= 0:
		sin_vidas.emit()
		print("💀 Sin vidas restantes")
		return false

	return true

## Agrega una vida (power-up, etc.)
func agregar_vida() -> void:
	if vidas < MAX_VIDAS:
		vidas += 1
		vidas_cambiadas.emit(vidas)
		print("💚 Vida ganada! Restantes: ", vidas, " / ", MAX_VIDAS)

## Reinicia las vidas al máximo
func reiniciar() -> void:
	vidas = MAX_VIDAS
	causa_muerte = ""
	vidas_cambiadas.emit(vidas)
	print("🔄 Vidas reiniciadas")

## Obtiene las vidas restantes
func obtener_vidas() -> int:
	return vidas

## Verifica si el jugador tiene vidas
func tiene_vidas() -> bool:
	return vidas > 0

## Establece la causa de muerte
func establecer_causa_muerte(causa: String) -> void:
	causa_muerte = causa
	print("💀 Causa de muerte: ", causa)

## Obtiene la causa de muerte
func obtener_causa_muerte() -> String:
	return causa_muerte
