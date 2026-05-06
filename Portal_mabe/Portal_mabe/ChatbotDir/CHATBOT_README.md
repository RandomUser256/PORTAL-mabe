# Sistema de Chatbot para Empleados - Documentación

## Resumen de Cambios

Este chatbot ha sido actualizado para consultar la base de datos de empleados de la empresa y proporcionar información sobre la jerarquía organizacional, puestos, departamentos y relaciones laborales.

## Arquitectura del Sistema

### 1. **KnowledgeRetrieval.swift**
   - **EmployeeDatabaseSource**: Fuente de datos que consulta la base de datos SwiftData de empleados
   - Búsqueda inteligente con:
     - Tokenización de consultas
     - Filtrado de palabras vacías (stopwords)
     - Expansión con sinónimos (jefe→supervisor→manager, etc.)
     - Ponderación de coincidencias:
       - Nombre: 5 puntos por coincidencia
       - Puesto: 3 puntos por coincidencia
       - Departamento: 2 puntos por coincidencia
       - Superior jerárquico: 1 punto por coincidencia

### 2. **ChatOrchestrator.swift**
   - Personalidad única y fija enfocada en información de empleados
   - Instrucciones del sistema:
     - Solo responde preguntas sobre empleados, puestos, departamentos y jerarquía
     - Usa únicamente información del contexto de la base de datos
     - Explica el proceso de búsqueda en cada respuesta
     - Respuestas siempre en español
   - **Estructura de respuesta**:
     1. Explicación del proceso de búsqueda (qué criterios se usaron)
     2. Respuesta a la consulta del usuario
     3. Detalles de la base de datos consultada

### 3. **ChatScreen.swift**
   - Se eliminó el selector de personalidad (`ChatPersonality`)
   - Se activó automáticamente `EmployeeDatabaseSource` como fuente de datos
   - Título actualizado: "Asistente de Empleados"
   - Muestra información detallada sobre el proceso de retrieval

## Funcionalidades Clave

### Búsqueda Inteligente
El sistema identifica automáticamente:
- **Nombres de empleados**: Busca en nombre, apellidos y segundo apellido
- **Puestos de trabajo**: Busca en nombre del rol y descripción del puesto
- **Departamentos**: Busca en nombre y descripción del departamento
- **Jerarquía**: Identifica relaciones supervisor-subordinado

### Sinónimos Soportados
```swift
"jefe" → supervisor, manager, gerente, encargado, chief
"trabajador" → empleado, operario, auxiliar, worker, assistant
"departamento" → área, sección, división, department
"producción" → production, manufactura, manufacturing
"calidad" → quality, qa
"mantenimiento" → maintenance, mtto
"recursos humanos" → human, hr, rrhh
```

### Información Proporcionada
Para cada empleado encontrado, el chatbot muestra:
- ✅ Nombre completo
- ✅ Puesto de trabajo
- ✅ Departamento
- ✅ Descripción del rol
- ✅ Email institucional
- ✅ Superior directo (a quién reporta)
- ✅ Subordinados (a quiénes supervisa)
- ✅ Puntuación de relevancia y razón de la coincidencia

## Ejemplos de Uso

### Ejemplo 1: Búsqueda por nombre
**Usuario**: "¿Quién es Juan Pérez?"

**Sistema**: 
```
🔍 Proceso de búsqueda:
Se analizó tu consulta y se buscaron coincidencias en la base de datos de empleados.
Se encontraron 1 resultado(s) relevante(s) basándose en nombres, puestos, departamentos y jerarquía organizacional.

Identifiqué las palabras clave "Juan" y "Pérez" en tu consulta...

[Respuesta del modelo con información de Juan Pérez]

📊 Detalles de la base de datos consultada:

[1] Empleado[Juan Pérez]:
- Puesto: Production Manager
- Departamento: Producción
...
```

### Ejemplo 2: Búsqueda jerárquica
**Usuario**: "¿Quién supervisa el área de mantenimiento?"

**Sistema**: Busca empleados con puestos relacionados a "mantenimiento" y "supervisor/jefe"

### Ejemplo 3: Búsqueda por departamento
**Usuario**: "Muéstrame los empleados de recursos humanos"

**Sistema**: Busca todos los empleados del departamento de HR

## Jerarquía Organizacional Soportada

```
Plant Manager
├── Production Manager
│   ├── Production Line Auxiliary 1, 2, 3
│   ├── Production Line Chief 1, 2, 3
│   ├── Metals Plastics and Paint Production Auxiliary
│   ├── Chief of Metals Plastics and Paint Section
│   └── Production Plant Worker
├── Manufacturing Manager
│   └── Manufacturing Plant Assistant
├── Human Resource Manager
│   ├── Recruitment Staff
│   └── Security and Health System Staff
├── Quality Manager
│   └── Plant Quality Assistant
└── Maintenance Manager
    ├── Mechanical and Workshop Technicians
    ├── Chief of Mechanical Maintenance
    ├── Electrical Technician
    ├── Chief of Electrical Maintenance
    ├── Metrology and Automation Technician
    ├── Chief of Electronic Maintenance
    ├── Apprentice Technician
    └── Contracted Technician
```

## Modelos de Datos Utilizados

- **Employee**: Información del empleado
- **Employee_roles**: Roles/puestos de trabajo
- **Employee_superior**: Relaciones jerárquicas
- **Department**: Departamentos de la empresa

## Ventajas del Sistema

1. ✨ **Transparencia**: Explica cómo llegó a cada resultado
2. 🎯 **Precisión**: Sistema de puntuación de relevancia
3. 🌍 **Multilingüe**: Soporta términos en español e inglés
4. 🧠 **Inteligente**: Expande consultas con sinónimos
5. 📊 **Detallado**: Muestra toda la información contextual relevante
6. 🔒 **Seguro**: Solo responde sobre información de empleados, no puede ser manipulado

## Mantenimiento

Para agregar más sinónimos o mejorar la búsqueda, edita:
- `KnowledgeRetrieval.swift` → propiedades `stopwords` y `synonymMap`

Para ajustar la personalidad del chatbot:
- `ChatOrchestrator.swift` → propiedad `systemInstructions`

Para cambiar el número máximo de resultados:
- `ChatScreen.swift` → `EmployeeDatabaseSource(context: context, maxResults: 5)`
