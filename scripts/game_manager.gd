extends Node

signal mates_cambiados(nuevos_mates)

var mates_totales := 0

func agregar_mates(cantidad: int):
	mates_totales += cantidad
	mates_cambiados.emit(mates_totales)
	print("Mates recolectados: ", mates_totales)

func reiniciar_mates():
	mates_totales = 0
	mates_cambiados.emit(mates_totales)

func obtener_mates() -> int:
	return mates_totales
