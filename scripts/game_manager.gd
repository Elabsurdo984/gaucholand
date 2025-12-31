extends Node

signal mates_cambiados(nuevos_mates)
signal objetivo_alcanzado  # Nueva señal para cuando llegues a 100

var mates_totales := 0
var objetivo := 100  # Mates necesarios para ganar
var objetivo_alcanzado_flag := false  # Para que solo se active una vez

func agregar_mates(cantidad: int):
	mates_totales += cantidad
	mates_cambiados.emit(mates_totales)
	print("Mates recolectados: ", mates_totales)

	# Verificar si llegaste al objetivo
	if mates_totales >= objetivo and not objetivo_alcanzado_flag:
		objetivo_alcanzado_flag = true
		objetivo_alcanzado.emit()
		# Cambiar a escena de felicitaciones después de un momento
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/felicitaciones/felicitaciones.tscn")

func reiniciar_mates():
	mates_totales = 0
	objetivo_alcanzado_flag = false
	mates_cambiados.emit(mates_totales)

func obtener_mates() -> int:
	return mates_totales
