# Deploy Automático a GitHub Pages

Este proyecto está configurado para hacer deploy automático a GitHub Pages cuando se hace push o merge a la rama `master` usando GitHub Actions.

## Configuración Requerida

### 1. Habilitar GitHub Pages en tu repositorio

1. Ve a tu repositorio en GitHub
2. Ir a **Settings** → **Pages**
3. En **Source**, selecciona **GitHub Actions**
4. ¡Eso es todo! No necesitas configurar secrets ni nada más

## Cómo Funciona

1. **Trigger**: El workflow se ejecuta automáticamente cuando:
   - Haces push a `master` o `main`

2. **Build**: Se crea un build web (HTML5) optimizado para navegadores

3. **Deploy**: El build se sube automáticamente a GitHub Pages

## URL de tu Juego

Una vez configurado, tu juego estará disponible en:
```
https://[tu-usuario].github.io/[nombre-del-repositorio]/
```

Por ejemplo:
```
https://andresguibarra.github.io/scrap-ascent/
```

## Verificar el Deploy

1. Ve a la pestaña **Actions** en tu repositorio de GitHub
2. Verifica que el workflow "Deploy to GitHub Pages" se ejecute correctamente
3. Ve a **Settings** → **Pages** para ver la URL de tu juego
4. Una vez que termine el deploy, podrás jugar tu juego en esa URL

## Ventajas de GitHub Pages

- ✅ **Gratis** - Sin costo alguno
- ✅ **Sin configuración** - No necesitas secrets ni API keys
- ✅ **SSL automático** - HTTPS incluido
- ✅ **CDN global** - Carga rápida en todo el mundo
- ✅ **Dominio personalizado** - Puedes usar tu propio dominio si quieres

## Notas Importantes

- El deploy solo ocurre en la rama `master` o `main`
- Solo se construye la versión web (HTML5)
- El export debe estar configurado correctamente en `export_presets.cfg`
- Asegúrate de que tu juego compile y funcione correctamente en web antes del merge
- Los archivos de Godot web requieren headers especiales que se configuran automáticamente
- El juego estará disponible públicamente en internet

## Solución de Problemas

Si el juego no carga correctamente:
1. Verifica que el workflow se ejecutó sin errores
2. Asegúrate de que tu juego funcione localmente en web
3. Revisa la consola del navegador para errores
4. Verifica que GitHub Pages esté habilitado en la configuración del repositorio
