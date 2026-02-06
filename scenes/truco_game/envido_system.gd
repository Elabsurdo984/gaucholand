extends Node
class_name EnvidoSystem

signal envido_cantado(quien: String, tipo: String)
signal envido_resuelto(ganador: String, puntos: int)

enum TipoEnvido { ENVIDO, ENVIDO_ENVIDO, REAL_ENVIDO, FALTA_ENVIDO }

var puntos_por_tipo = {
	TipoEnvido.ENVIDO: 2,
	TipoEnvido.ENVIDO_ENVIDO: 2,
	TipoEnvido.REAL_ENVIDO: 3,
	TipoEnvido.FALTA_ENVIDO: 0  # Se calcula dinámicamente
}

var puntos_acumulados: int = 0
var tipo_actual: TipoEnvido = TipoEnvido.ENVIDO
var es_falta_envido: bool = false

func cantar_envido(tipo: TipoEnvido, quien: String) -> void:
	tipo_actual = tipo
	if tipo == TipoEnvido.FALTA_ENVIDO:
		es_falta_envido = true
	else:
		puntos_acumulados += puntos_por_tipo[tipo]
	envido_cantado.emit(quien, TipoEnvido.keys()[tipo])

func calcular_envido(cartas: Array) -> int:
	var mejor_envido = 0
	var por_palo = {}
	
	for c in cartas:
		var p = c["palo"] if c is Dictionary else c.palo
		if not por_palo.has(p):
			por_palo[p] = []
		por_palo[p].append(c)
	
	for palo in por_palo:
		var grupo = por_palo[palo]
		if grupo.size() >= 2:
			grupo.sort_custom(func(a, b): return _get_envido_val(a) > _get_envido_val(b))
			var envido = 20 + _get_envido_val(grupo[0]) + _get_envido_val(grupo[1])
			if envido > mejor_envido: mejor_envido = envido
		else:
			var val = _get_envido_val(grupo[0])
			if val > mejor_envido: mejor_envido = val
				
	return mejor_envido

func resolver_envido(puntos_envido_jugador: int, puntos_envido_muerte: int, es_mano_jugador: bool = true, puntos_partida_jugador: int = 0, puntos_partida_muerte: int = 0, puntos_para_ganar: int = 15) -> Dictionary:
	var ganador = ""
	if puntos_envido_jugador > puntos_envido_muerte:
		ganador = "jugador"
	elif puntos_envido_muerte > puntos_envido_jugador:
		ganador = "muerte"
	else:
		ganador = "jugador" if es_mano_jugador else "muerte"

	var puntos = puntos_acumulados

	# Si es falta envido, calcular puntos que faltan para ganar
	if es_falta_envido:
		# El que va perdiendo define los puntos (lo que le falta para ganar)
		if puntos_partida_jugador >= puntos_partida_muerte:
			# La muerte va perdiendo o empatados, se juega por lo que le falta a la muerte
			puntos = puntos_para_ganar - puntos_partida_muerte
		else:
			# El jugador va perdiendo, se juega por lo que le falta al jugador
			puntos = puntos_para_ganar - puntos_partida_jugador
		# Mínimo 1 punto
		if puntos < 1:
			puntos = 1
	elif puntos == 0:
		puntos = 2

	envido_resuelto.emit(ganador, puntos)
	return { "ganador": ganador, "puntos": puntos }

func resetear() -> void:
	puntos_acumulados = 0
	tipo_actual = TipoEnvido.ENVIDO
	es_falta_envido = false

func _get_envido_val(c) -> int:
	if c is Dictionary:
		return Carta.calcular_valor_envido(c["numero"])
	return c.obtener_valor_envido()
