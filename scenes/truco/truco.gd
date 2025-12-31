# truco.gd
# Juego de truco argentino contra la Muerte
extends Control

# ==================== RECURSOS ====================
const CARTA_SCENE = preload("res://scenes/truco/carta.tscn")

# ==================== REFERENCIAS ====================
@onready var jugador_cartas_container = $JugadorCartas
@onready var muerte_cartas_container = $MuerteCartas
@onready var mesa_jugador = $Mesa/CartaJugador
@onready var mesa_muerte = $Mesa/CartaMuerte

@onready var puntos_jugador_label = $UI/PuntosPanel/PuntosJugador
@onready var puntos_muerte_label = $UI/PuntosPanel/PuntosMuerte

@onready var btn_envido = $UI/BotonesPanel/BtnEnvido
@onready var btn_truco = $UI/BotonesPanel/BtnTruco
@onready var btn_mazo = $UI/BotonesPanel/BtnMazo

@onready var mensaje_label = $UI/MensajeLabel

@onready var gaucho_sprite = $Personajes/Gaucho
@onready var muerte_sprite = $Personajes/Muerte

# ==================== CONFIGURACIÓN ====================
const PUNTOS_PARA_GANAR = 15

# ==================== ESTADO DEL JUEGO ====================
var puntos_jugador := 0
var puntos_muerte := 0

var cartas_jugador: Array = []  # Array de nodos Carta
var cartas_muerte: Array = []  # Array de nodos Carta

var mazo: Mazo  # Instancia del mazo

var es_turno_jugador := true
var ronda_actual := 1  # 1, 2 o 3
var carta_jugada_jugador: Carta = null
var carta_jugada_muerte: Carta = null

# Resultados de rondas: 0 = no jugada, 1 = jugador gana, 2 = muerte gana, 3 = empate
var resultado_ronda_1 := 0
var resultado_ronda_2 := 0
var resultado_ronda_3 := 0

var puntos_en_juego := 1  # Puntos que vale la mano actual

# ==================== INICIALIZACIÓN ====================
func _ready():
	print("🎴 Iniciando partida de truco contra la Muerte...")

	# Conectar botones
	if btn_envido:
		btn_envido.pressed.connect(_on_envido_pressed)
	if btn_truco:
		btn_truco.pressed.connect(_on_truco_pressed)
	if btn_mazo:
		btn_mazo.pressed.connect(_on_mazo_pressed)

	# Iniciar partida
	await get_tree().create_timer(1.0).timeout
	iniciar_nueva_mano()

# ==================== FLUJO DEL JUEGO ====================
func iniciar_nueva_mano():
	print("🃏 Nueva mano - Repartiendo cartas...")

	# Resetear estado
	ronda_actual = 1
	resultado_ronda_1 = 0
	resultado_ronda_2 = 0
	resultado_ronda_3 = 0
	carta_jugada_jugador = null
	carta_jugada_muerte = null
	puntos_en_juego = 1
	es_turno_jugador = true

	# Limpiar cartas anteriores
	limpiar_cartas()

	# Crear nuevo mazo
	mazo = Mazo.new()

	# Repartir 3 cartas al jugador
	repartir_cartas_jugador()

	# Repartir 3 cartas a la muerte
	repartir_cartas_muerte()

	actualizar_ui()
	mostrar_mensaje("Ronda %d - Tu turno" % ronda_actual)

func limpiar_cartas():
	# Limpiar cartas del jugador
	for carta in cartas_jugador:
		if carta:
			carta.queue_free()
	cartas_jugador.clear()

	# Limpiar cartas de la muerte
	for carta in cartas_muerte:
		if carta:
			carta.queue_free()
	cartas_muerte.clear()

	# Limpiar contenedores visuales
	for child in jugador_cartas_container.get_children():
		child.queue_free()
	for child in muerte_cartas_container.get_children():
		child.queue_free()

func repartir_cartas_jugador():
	var cartas_data = mazo.repartir_cartas(3)

	for carta_data in cartas_data:
		# Crear instancia de carta
		var carta = CARTA_SCENE.instantiate()
		carta.setup(carta_data["numero"], carta_data["palo"])

		# Mostrar boca arriba
		carta.mostrar_frente()

		# Hacer clickeable
		carta.hacer_clickeable(true)

		# Conectar señal
		carta.carta_clickeada.connect(_on_carta_jugador_clickeada)

		# Agregar al contenedor visual
		jugador_cartas_container.add_child(carta)

		# Guardar referencia
		cartas_jugador.append(carta)

	print("✅ Jugador recibe: ", cartas_jugador.size(), " cartas")

func repartir_cartas_muerte():
	var cartas_data = mazo.repartir_cartas(3)

	for carta_data in cartas_data:
		# Crear instancia de carta
		var carta = CARTA_SCENE.instantiate()
		carta.setup(carta_data["numero"], carta_data["palo"])

		# Mantener boca abajo
		carta.mostrar_dorso()

		# No hacer clickeable
		carta.hacer_clickeable(false)

		# Agregar al contenedor visual
		muerte_cartas_container.add_child(carta)

		# Guardar referencia
		cartas_muerte.append(carta)

	print("✅ Muerte recibe: ", cartas_muerte.size(), " cartas")

func _on_carta_jugador_clickeada(carta: Carta):
	if not es_turno_jugador:
		mostrar_mensaje("No es tu turno")
		return

	print("🃏 Jugador juega: ", carta.obtener_nombre_completo())
	jugar_carta_jugador(carta)

func jugar_carta_jugador(carta: Carta):
	# Guardar carta jugada
	carta_jugada_jugador = carta

	# Remover del array (pero no destruir, solo reparentar)
	cartas_jugador.erase(carta)

	# Desactivar todas las cartas del jugador mientras espera
	for c in cartas_jugador:
		c.hacer_clickeable(false)

	# Mover carta a la mesa
	carta.get_parent().remove_child(carta)
	mesa_jugador.add_child(carta)
	carta.position = Vector2.ZERO

	mostrar_mensaje("Jugaste: " + carta.obtener_nombre_completo())

	# Cambiar turno
	es_turno_jugador = false

	# Esperar un momento y que juegue la Muerte
	await get_tree().create_timer(1.0).timeout
	turno_muerte()

func actualizar_ui():
	if puntos_jugador_label:
		puntos_jugador_label.text = "Jugador: %d" % puntos_jugador
	if puntos_muerte_label:
		puntos_muerte_label.text = "Muerte: %d" % puntos_muerte

func mostrar_mensaje(texto: String):
	if mensaje_label:
		mensaje_label.text = texto
	print("💬 ", texto)

# ==================== TURNO DE LA MUERTE ====================
func turno_muerte():
	mostrar_mensaje("Turno de la Muerte...")

	# IA simple: jugar carta aleatoria por ahora
	if cartas_muerte.is_empty():
		push_error("❌ La Muerte no tiene cartas!")
		return

	var carta = cartas_muerte[randi() % cartas_muerte.size()]
	jugar_carta_muerte(carta)

func jugar_carta_muerte(carta: Carta):
	# Guardar carta jugada
	carta_jugada_muerte = carta

	# Remover del array
	cartas_muerte.erase(carta)

	# Mover carta a la mesa
	carta.get_parent().remove_child(carta)
	mesa_muerte.add_child(carta)
	carta.position = Vector2.ZERO

	# Mostrar boca arriba
	carta.mostrar_frente()

	print("💀 Muerte juega: ", carta.obtener_nombre_completo())
	mostrar_mensaje("Muerte juega: " + carta.obtener_nombre_completo())

	# Esperar un momento y comparar
	await get_tree().create_timer(1.5).timeout
	comparar_cartas()

# ==================== COMPARACIÓN Y RESOLUCIÓN ====================
func comparar_cartas():
	if not carta_jugada_jugador or not carta_jugada_muerte:
		push_error("❌ Faltan cartas para comparar!")
		return

	var valor_jugador = carta_jugada_jugador.obtener_valor_truco()
	var valor_muerte = carta_jugada_muerte.obtener_valor_truco()

	var ganador := 0  # 0 = empate, 1 = jugador, 2 = muerte

	if valor_jugador > valor_muerte:
		ganador = 1
		mostrar_mensaje("¡Ganaste la ronda!")
		print("✅ Jugador gana ronda %d (%d vs %d)" % [ronda_actual, valor_jugador, valor_muerte])
	elif valor_muerte > valor_jugador:
		ganador = 2
		mostrar_mensaje("Muerte gana la ronda")
		print("💀 Muerte gana ronda %d (%d vs %d)" % [ronda_actual, valor_muerte, valor_jugador])
	else:
		ganador = 3
		mostrar_mensaje("¡Empate!")
		print("🤝 Empate en ronda %d" % ronda_actual)

	# Guardar resultado
	match ronda_actual:
		1: resultado_ronda_1 = ganador
		2: resultado_ronda_2 = ganador
		3: resultado_ronda_3 = ganador

	# Esperar y pasar a la siguiente ronda
	await get_tree().create_timer(2.0).timeout
	siguiente_ronda()

func siguiente_ronda():
	# Verificar si la mano ya está decidida
	if verificar_mano_terminada():
		return

	# Limpiar cartas de la mesa
	if carta_jugada_jugador:
		carta_jugada_jugador.queue_free()
		carta_jugada_jugador = null
	if carta_jugada_muerte:
		carta_jugada_muerte.queue_free()
		carta_jugada_muerte = null

	# Siguiente ronda
	ronda_actual += 1

	if ronda_actual > 3:
		resolver_mano()
		return

	# Reactivar cartas del jugador
	for c in cartas_jugador:
		c.hacer_clickeable(true)

	es_turno_jugador = true
	mostrar_mensaje("Ronda %d - Tu turno" % ronda_actual)

func verificar_mano_terminada() -> bool:
	# Contar rondas ganadas
	var rondas_jugador = 0
	var rondas_muerte = 0

	for resultado in [resultado_ronda_1, resultado_ronda_2, resultado_ronda_3]:
		if resultado == 1:
			rondas_jugador += 1
		elif resultado == 2:
			rondas_muerte += 1

	# Si alguien ganó 2 rondas, la mano está decidida
	if rondas_jugador >= 2:
		print("🏆 Jugador gana la mano!")
		resolver_mano_ganada(1)
		return true
	elif rondas_muerte >= 2:
		print("💀 Muerte gana la mano!")
		resolver_mano_ganada(2)
		return true

	return false

func resolver_mano():
	# Contar rondas ganadas (sin contar empates)
	var rondas_jugador = 0
	var rondas_muerte = 0

	for resultado in [resultado_ronda_1, resultado_ronda_2, resultado_ronda_3]:
		if resultado == 1:
			rondas_jugador += 1
		elif resultado == 2:
			rondas_muerte += 1

	# Determinar ganador
	if rondas_jugador > rondas_muerte:
		resolver_mano_ganada(1)
	elif rondas_muerte > rondas_jugador:
		resolver_mano_ganada(2)
	else:
		# En caso de empate total, gana el que ganó la primera ronda
		if resultado_ronda_1 == 1:
			resolver_mano_ganada(1)
		elif resultado_ronda_1 == 2:
			resolver_mano_ganada(2)
		else:
			# Si la primera fue empate, no gana nadie
			mostrar_mensaje("Mano empatada - No hay puntos")
			await get_tree().create_timer(2.0).timeout
			iniciar_nueva_mano()

func resolver_mano_ganada(ganador: int):
	if ganador == 1:
		puntos_jugador += puntos_en_juego
		mostrar_mensaje("¡Ganaste %d punto(s)!" % puntos_en_juego)
	else:
		puntos_muerte += puntos_en_juego
		mostrar_mensaje("Muerte gana %d punto(s)" % puntos_en_juego)

	actualizar_ui()

	# Verificar victoria
	await get_tree().create_timer(2.0).timeout
	if verificar_victoria():
		return

	# Nueva mano
	iniciar_nueva_mano()

# ==================== CALLBACKS BOTONES ====================
func _on_envido_pressed():
	print("🗣️ Jugador canta: ¡Envido!")
	mostrar_mensaje("Cantaste Envido")
	# TODO: Lógica de envido

func _on_truco_pressed():
	print("🗣️ Jugador canta: ¡Truco!")
	mostrar_mensaje("Cantaste Truco")
	# TODO: Lógica de truco

func _on_mazo_pressed():
	print("🚪 Jugador se va al mazo")
	mostrar_mensaje("Te fuiste al mazo - Muerte gana la mano")
	# TODO: Muerte gana puntos
	await get_tree().create_timer(2.0).timeout
	iniciar_nueva_mano()

# ==================== VICTORIA ====================
func verificar_victoria() -> bool:
	if puntos_jugador >= PUNTOS_PARA_GANAR:
		victoria_jugador()
		return true
	elif puntos_muerte >= PUNTOS_PARA_GANAR:
		derrota_jugador()
		return true
	return false

func victoria_jugador():
	print("🎉 ¡GANASTE! La Muerte cumple su palabra...")
	mostrar_mensaje("¡VICTORIA! Vivís para contar la historia")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/felicitaciones/felicitaciones.tscn")

func derrota_jugador():
	print("💀 Perdiste... Te toca cebar mate en el más allá")
	mostrar_mensaje("DERROTA - La Muerte gana")
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()
