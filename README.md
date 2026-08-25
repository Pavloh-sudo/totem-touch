# Tótem Touch

Aplicación Flutter Web para el tótem interactivo de GPA.

La interfaz se diseña primero para una pantalla táctil horizontal de **1024 × 768 px**. La base del proyecto mantiene separadas la aplicación, la configuración común, los datos, las funciones y los componentes reutilizables.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run -d chrome
```

## Revisiones rápidas

```bash
flutter analyze
flutter test
flutter build web
```

## Organización

```text
lib/
├── app/       # Inicio, navegación y contenedor del tótem
├── core/      # Tema, configuración y servicios comunes
├── data/      # Modelos, almacenamiento, repositorios y exportación
├── features/  # Pantallas separadas por función
└── shared/    # Controles y componentes reutilizables
```

Las imágenes proporcionadas para diseño se conservan en `assets/branding` y `docs/referencias`.
