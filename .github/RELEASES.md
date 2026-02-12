# Sistema de Releases Automáticos

Este proyecto usa GitHub Actions para compilar y publicar releases automáticamente.

## Cómo crear un release

1. **Asegúrate de que tu código esté listo para release**
   - Todos los cambios commiteados
   - Tests pasando
   - Versión actualizada en `project.godot`

2. **Crea y sube un tag que empiece con "v"**
   ```bash
   # Crear tag localmente
   git tag v0.9.1

   # O con mensaje anotado (recomendado)
   git tag -a v0.9.1 -m "Release version 0.9.1"

   # Subir el tag a GitHub
   git push origin v0.9.1
   ```

3. **GitHub Actions automáticamente:**
   - ✅ Compilará el juego para Windows, Linux y macOS
   - ✅ Empaquetará cada build en un archivo ZIP
   - ✅ Creará un release en GitHub con los 3 archivos
   - ✅ Generará notas del release automáticamente

4. **El release estará disponible en:**
   `https://github.com/tu-usuario/gaucholand/releases`

## Formatos de tags soportados

El workflow se activa con cualquier tag que empiece con "v":
- ✅ `v0.9.1`
- ✅ `v1.0.0`
- ✅ `v1.2.3-beta`
- ✅ `v2.0.0-rc1`
- ❌ `0.9.1` (sin "v" no se activa)
- ❌ `release-1.0` (no empieza con "v")

## Archivos del release

Cada release incluye 3 archivos:
- `la_odisea_del_gaucho-windows.zip` - Build para Windows
- `la_odisea_del_gaucho-linux.zip` - Build para Linux
- `la_odisea_del_gaucho-macos.zip` - Build para macOS

## Troubleshooting

**Si el workflow falla:**
1. Ve a la pestaña "Actions" en GitHub
2. Haz click en el workflow fallido
3. Revisa los logs para ver qué paso falló
4. Soluciona el problema y crea un nuevo tag

**Para eliminar un tag y retry:**
```bash
# Eliminar tag local
git tag -d v0.9.1

# Eliminar tag remoto
git push origin :refs/tags/v0.9.1

# Crear nuevo tag y subir
git tag v0.9.1
git push origin v0.9.1
```

## Monitorear el progreso

Después de hacer `git push origin v0.9.1`:
1. Ve a https://github.com/tu-usuario/gaucholand/actions
2. Verás el workflow "Build and Release" ejecutándose
3. Toma ~5-10 minutos en completar
4. Cuando termine, el release estará en la pestaña "Releases"
