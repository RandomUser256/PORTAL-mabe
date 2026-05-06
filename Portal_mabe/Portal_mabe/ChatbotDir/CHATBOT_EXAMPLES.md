# Ejemplos de Conversaciones con el Chatbot de Empleados

## Ejemplo 1: Consulta Simple por Nombre

**👤 Usuario**: 
```
¿Quién es María González?
```

**🤖 Asistente**:
```
🔍 Proceso de búsqueda:
Se analizó tu consulta y se buscaron coincidencias en la base de datos de empleados.
Se encontraron 1 resultado(s) relevante(s) basándose en nombres, puestos, departamentos y jerarquía organizacional.

Identifiqué las palabras clave "María" y "González" en tu consulta. Busqué en la base de datos 
por coincidencias en nombres de empleados y encontré lo siguiente:

María González es la Quality Manager (Gerente de Calidad) de la empresa. Trabaja en el 
departamento de Calidad, donde se encarga de supervisar los estándares de calidad y 
certificaciones. Reporta directamente al Plant Manager y supervisa a un Plant Quality Assistant.

Su email institucional es: maria.gonzalez@empresa.com

📊 Detalles de la base de datos consultada:

[1] Empleado[María González]:
- Puesto: Quality Manager
- Departamento: Calidad
- Descripción del rol: Responsable de asegurar el cumplimiento de estándares de calidad
- Email: maria.gonzalez@empresa.com
- Reporta a: Roberto Sánchez (Plant Manager)
- Supervisa a: Carlos Ramírez (Plant Quality Assistant)
- [Relevancia: 10 puntos - coincidió por nombre]
```

---

## Ejemplo 2: Búsqueda Jerárquica

**👤 Usuario**: 
```
¿Quiénes trabajan bajo el supervisor de producción?
```

**🤖 Asistente**:
```
🔍 Proceso de búsqueda:
Se analizó tu consulta y se buscaron coincidencias en la base de datos de empleados.
Se encontraron 3 resultado(s) relevante(s) basándose en nombres, puestos, departamentos y jerarquía organizacional.

Busqué en la base de datos usando las palabras clave "supervisor" y "producción". 
El sistema expandió la búsqueda para incluir sinónimos como "manager" y "production".

El Production Manager (equivalente al supervisor de producción) supervisa a los siguientes empleados:

1. **Auxiliares de Línea de Producción**:
   - Production Line Auxiliary 1
   - Production Line Auxiliary 2
   - Production Line Auxiliary 3

2. **Jefes de Línea de Producción**:
   - Production Line Chief 1
   - Production Line Chief 2
   - Production Line Chief 3

3. **Sección de Metales, Plásticos y Pintura**:
   - Metals Plastics and Paint Production Auxiliary
   - Chief of Metals Plastics and Paint Section

4. **Trabajadores de Planta**:
   - Production Plant Worker

En total, el Production Manager supervisa directamente a 9 subordinados.

📊 Detalles de la base de datos consultada:

[1] Empleado[Juan Martínez]:
- Puesto: Production Manager
- Departamento: Producción
- Descripción del rol: Supervisar todas las operaciones de producción
- Email: juan.martinez@empresa.com
- Reporta a: Roberto Sánchez (Plant Manager)
- Supervisa a: Pedro López (Production Line Auxiliary 1); Ana Torres (Production Line Auxiliary 2); Luis Hernández (Production Line Auxiliary 3); Carmen Díaz (Production Line Chief 1); Miguel Ángel Ruiz (Production Line Chief 2); Patricia Morales (Production Line Chief 3); Ricardo Vargas (Metals Plastics and Paint Production Auxiliary); Fernando Castro (Chief of Metals Plastics and Paint Section); Gabriela Ortiz (Production Plant Worker)
- [Relevancia: 8 puntos - coincidió por puesto, departamento]

[2] Empleado[Pedro López]:
- Puesto: Production Line Auxiliary 1
- Departamento: Producción
...
```

---

## Ejemplo 3: Búsqueda por Departamento

**👤 Usuario**: 
```
Muéstrame el equipo de recursos humanos
```

**🤖 Asistente**:
```
🔍 Proceso de búsqueda:
Se analizó tu consulta y se buscaron coincidencias en la base de datos de empleados.
Se encontraron 3 resultado(s) relevante(s) basándose en nombres, puestos, departamentos y jerarquía organizacional.

Identifiqué "recursos humanos" en tu consulta. El sistema expandió la búsqueda para incluir 
sinónimos como "HR", "RRHH" y "human resources".

El departamento de Recursos Humanos está compuesto por:

**Gerente del departamento**:
- Laura Jiménez - Human Resource Manager
  - Email: laura.jimenez@empresa.com
  - Reporta a: Roberto Sánchez (Plant Manager)

**Personal de Reclutamiento**:
- Sofía Medina - Recruitment Staff
  - Email: sofia.medina@empresa.com
  - Reporta a: Laura Jiménez

**Personal de Seguridad y Salud**:
- Diego Ramos - Security and Health System Staff
  - Email: diego.ramos@empresa.com
  - Reporta a: Laura Jiménez

El equipo cuenta con 3 miembros en total.

📊 Detalles de la base de datos consultada:

[1] Empleado[Laura Jiménez]:
- Puesto: Human Resource Manager
- Departamento: Recursos Humanos
- Descripción del rol: Gestión del personal, reclutamiento y relaciones laborales
- Email: laura.jimenez@empresa.com
- Reporta a: Roberto Sánchez (Plant Manager)
- Supervisa a: Sofía Medina (Recruitment Staff); Diego Ramos (Security and Health System Staff)
- [Relevancia: 6 puntos - coincidió por departamento, puesto]

[2] Empleado[Sofía Medina]:
- Puesto: Recruitment Staff
- Departamento: Recursos Humanos
- Descripción del rol: Proceso de selección y contratación de personal
- Email: sofia.medina@empresa.com
- Reporta a: Laura Jiménez (Human Resource Manager)
- Supervisa a: Sin subordinados
- [Relevancia: 4 puntos - coincidió por departamento]

[3] Empleado[Diego Ramos]:
- Puesto: Security and Health System Staff
- Departamento: Recursos Humanos
- Descripción del rol: Seguridad laboral y prevención de riesgos
- Email: diego.ramos@empresa.com
- Reporta a: Laura Jiménez (Human Resource Manager)
- Supervisa a: Sin subordinados
- [Relevancia: 4 puntos - coincidió por departamento]
```

---

## Ejemplo 4: Consulta sobre Contacto

**👤 Usuario**: 
```
¿Cómo puedo contactar al jefe de mantenimiento eléctrico?
```

**🤖 Asistente**:
```
🔍 Proceso de búsqueda:
Se analizó tu consulta y se buscaron coincidencias en la base de datos de empleados.
Se encontraron 1 resultado(s) relevante(s) basándose en nombres, puestos, departamentos y jerarquía organizacional.

Busqué usando las palabras clave "jefe", "mantenimiento" y "eléctrico". El sistema 
identificó que buscas al Chief of Electrical Maintenance.

El jefe de mantenimiento eléctrico es **Alberto Navarro**.

**Información de contacto**:
- Email institucional: alberto.navarro@empresa.com
- Puesto: Chief of Electrical Maintenance
- Departamento: Mantenimiento

**Contexto organizacional**:
- Reporta a: Ramiro Silva (Maintenance Manager)
- Supervisa a: Electrical Technician

Puedes contactarlo a través de su email institucional para consultas relacionadas 
con el mantenimiento eléctrico de la planta.

📊 Detalles de la base de datos consultada:

[1] Empleado[Alberto Navarro]:
- Puesto: Chief of Electrical Maintenance
- Departamento: Mantenimiento
- Descripción del rol: Supervisar todas las actividades de mantenimiento eléctrico
- Email: alberto.navarro@empresa.com
- Reporta a: Ramiro Silva (Maintenance Manager)
- Supervisa a: José Paredes (Electrical Technician)
- [Relevancia: 11 puntos - coincidió por puesto, departamento]
```

---

## Ejemplo 5: Consulta sin Resultados

**👤 Usuario**: 
```
¿Quién es el director de marketing?
```

**🤖 Asistente**:
```
🔍 Proceso de búsqueda:
No se encontraron empleados que coincidan con tu consulta en la base de datos.

Busqué en la base de datos usando las palabras clave "director" y "marketing", pero 
no encontré ningún empleado que coincida con estos términos.

La base de datos no contiene información sobre un puesto de "director de marketing" 
ni sobre un departamento de marketing. 

Los departamentos disponibles en la organización son:
- Producción
- Manufactura
- Recursos Humanos
- Calidad
- Mantenimiento

Si necesitas información sobre alguno de estos departamentos, estaré encantado de ayudarte.
```

---

## Ejemplo 6: Consulta Compleja sobre Jerarquía

**👤 Usuario**: 
```
Explícame la estructura del departamento de mantenimiento
```

**🤖 Asistente**:
```
🔍 Proceso de búsqueda:
Se analizó tu consulta y se buscaron coincidencias en la base de datos de empleados.
Se encontraron 8 resultado(s) relevante(s) basándose en nombres, puestos, departamentos y jerarquía organizacional.

Busqué todos los empleados del departamento de Mantenimiento y analicé sus relaciones jerárquicas.

El departamento de Mantenimiento tiene la siguiente estructura organizacional:

**Nivel 1 - Gerencia**:
└── Ramiro Silva - Maintenance Manager
    - Email: ramiro.silva@empresa.com
    - Reporta a: Roberto Sánchez (Plant Manager)

**Nivel 2 - Jefaturas** (reportan al Maintenance Manager):
├── Chief of Mechanical Maintenance
├── Chief of Electrical Maintenance
└── Chief of Electronic Maintenance

**Nivel 3 - Técnicos y Personal Operativo**:

**Sección Mecánica**:
├── Mechanical and Workshop Technicians (reportan al Chief of Mechanical Maintenance)

**Sección Eléctrica**:
├── Electrical Technician (reporta al Chief of Electrical Maintenance)

**Sección Electrónica**:
├── Metrology and Automation Technician (reporta al Chief of Electronic Maintenance)

**Personal Adicional**:
├── Apprentice Technician
└── Contracted Technician

El departamento cuenta con aproximadamente 11 empleados distribuidos en 3 secciones 
principales: Mecánica, Eléctrica y Electrónica/Automatización.

📊 Detalles de la base de datos consultada:

[1] Empleado[Ramiro Silva]:
- Puesto: Maintenance Manager
- Departamento: Mantenimiento
...

[Continúa con los 8 empleados encontrados]
```

---

## Notas sobre el Comportamiento del Chatbot

### ✅ El chatbot PUEDE:
- Buscar empleados por nombre, apellido
- Buscar por puesto de trabajo
- Buscar por departamento
- Mostrar relaciones jerárquicas (superiores y subordinados)
- Proporcionar información de contacto
- Explicar estructuras organizacionales
- Entender sinónimos y términos en español e inglés

### ❌ El chatbot NO PUEDE:
- Responder preguntas no relacionadas con empleados
- Inventar información que no esté en la base de datos
- Modificar datos de empleados
- Proporcionar información personal sensible (más allá del email institucional)
- Ser manipulado para cambiar su comportamiento mediante prompt injection

### 🎯 Características Especiales:
- **Transparencia total**: Siempre explica cómo buscó la información
- **Puntuación de relevancia**: Muestra qué tan relevante es cada resultado
- **Contexto completo**: Proporciona toda la información disponible del empleado
- **Búsqueda inteligente**: Expande consultas con sinónimos automáticamente
