Buenas practicas para GODOT 4.5
1. Convención de Nombres:
    
    ◦ Nodos: Usa PascalCase, por ejemplo para un nodo 2D, usa EscenaPrincipal.
    
    ◦ Archivos y Scripts: Usa snake_case, por ejemplo personaje_principal.tscn, para evitar problemas de compatibilidad en sistemas operativos.
   
    ◦ Variables y Funciones: Usa snake_case. Si una variable o función es privada (solo para uso interno del script), ponle un guion bajo adelante del nombre (ej. _velocidad).
    
    ◦ Constantes: Deben ir siempre en MAYÚSCULAS (ej. GRAVEDAD).
2. GDScript y Programación:
    
    ◦ Tipado de variables: Aunque GDScript es dinámico, es recomendable especificar el tipo de dato (ej. var vida: int = 10). Esto mejora el rendimiento, evita errores y activa el autocompletado inteligente del editor.
    
    ◦ Variables exportadas: Usa @export para referenciar componentes o recursos desde el Inspector en lugar de utilizar rutas manuales (ej. @export var label: Label). Esto evita que el código se rompa si cambias el nombre o la posición de un nodo en la jerarquía.
    
    ◦ No utilices rutas de texto para cambiar de escena: En su lugar, usa variables @export var escena: PackedScene. Esto permite arrastrar el archivo de la escena directamente al Inspector, garantizando que Godot actualice la referencia automáticamente si mueves el archivo.
    
    ◦ Uso de Delta: Siempre multiplica los cálculos de movimiento o aceleración por el parámetro delta en las funciones de proceso. Esto asegura que el objeto se mueva a la misma velocidad independientemente de si la computadora corre a 30 o 144 FPS.
    
    ◦ PhysicsProcess vs Process: Utiliza _physics_process(delta) para todo lo relacionado con físicas o colisiones para mantener la sincronización con el motor, y _process(delta) solo para lógica visual o de entrada general.
    
    ◦ Señales para el desacoplamiento: Usa señales para que los nodos hijos se comuniquen con sus padres. Esto permite que los nodos sean independientes y reutilizables, ya que no necesitan conocer quién los está escuchando.
    ◦ Llamadas diferidas: Usa call_deferred() al añadir o eliminar nodos del árbol de escenas (SceneTree) si la acción ocurre durante un cálculo de físicas, evitando errores de estado del motor.
3. Interfaz de Usuario (UI):
    
    ◦ Uso de Contenedores: No posiciones los elementos de UI manualmente. Utiliza nodos de tipo Container (como VBoxContainer o HBoxContainer) para que los botones y textos se organicen y escalen automáticamente según la resolución.
    
    ◦ Capas de Interfaz (CanvasLayer): Coloca siempre tus nodos de interfaz dentro de un CanvasLayer. Esto garantiza que la UI se dibuje siempre por encima del juego y no se desplace cuando la cámara se mueva.
4. Gestión de Audio:
    
    ◦ **Buses de Audio**: Crea buses separados para "Música" y "Efectos (SFX)" en el mezclador de audio. Esto te permite controlar el volumen de cada categoría de forma independiente sin afectar a la otra.
5. Rendimiento y Mantenimiento:
    
    ◦ **Comentarios y Documentación**: Documenta partes complejas del código usando # o etiquetas como # TODO para facilitar el trabajo futuro o la colaboración.
Analogía: Programar con estas prácticas es como construir un tablero eléctrico etiquetado. En lugar de tener cables sueltos y anónimos (rutas de texto y variables sin tipo), cada conexión tiene un color y una etiqueta clara (tipado y señales). Si necesitas cambiar un componente, no tienes que desarmar todo el sistema; simplemente desconectas el módulo y enchufas uno nuevo sin riesgo de provocar un cortocircuito