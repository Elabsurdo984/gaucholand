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
var mano_actual := 1  # 1, 2 o 3 (mejor de 3)
var rondas_ganadas_jugador := 0
var rondas_ganadas_muerte := 0

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
	mano_actual = 1
	rondas_ganadas_jugador = 0
	rondas_ganadas_muerte = 0

	# Limpiar cartas anteriores
	limpiar_cartas()

	# Crear nuevo mazo
	mazo = Mazo.new()

	# Repartir 3 cartas al jugador
	repartir_cartas_jugador()

	# Repartir 3 cartas a la muerte
	repartir_cartas_muerte()

	actualizar_ui()
	mostrar_mensaje("Nueva mano - Tu turno")

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
	# TODO: Implementar lógica de jugar carta
	mostrar_mensaje("Jugaste: " + carta.obtener_nombre_completo())
	# Mover carta a la mesa, etc.

func actualizar_ui():
	if puntos_jugador_label:
		puntos_jugador_label.text = "Jugador: %d" % puntos_jugador
	if puntos_muerte_label:
		puntos_muerte_label.text = "Muerte: %d" % puntos_muerte

func mostrar_mensaje(texto: String):
	if mensaje_label:
		mensaje_label.text = texto
	print("💬 ", texto)

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
func verificar_victoria():
	if puntos_jugador >= PUNTOS_PARA_GANAR:
		victoria_jugador()
	elif puntos_muerte >= PUNTOS_PARA_GANAR:
		derrota_jugador()

func victoria_jugador():
	print("🎉 ¡GANASTE! La Muerte cumple su palabra...")
	mostrar_mensaje("¡VICTORIA! Vivís para contar la historia")
	# TODO: Escena de victoria final
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/felicitaciones/felicitaciones.tscn")

func derrota_jugador():
	print("💀 Perdiste... Te toca cebar mate en el más allá")
	mostrar_mensaje("DERROTA - La Muerte gana")
	# TODO: Escena de derrota
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()
