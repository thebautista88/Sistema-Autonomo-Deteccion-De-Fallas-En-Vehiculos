;;; =====================================================================
;;; PROYECTO 7 - SISTEMA EXPERTO PARA DIAGNÓSTICO DE AUTOMÓVILES
;;; Base de Conocimiento con Causas Únicas Deterministas
;;; =====================================================================

;; ---------------------------------------------------------------------
;; 1. PLANTILLAS DE HECHOS (deftemplate)
;; ---------------------------------------------------------------------

(deftemplate sintoma
   (slot nombre (type SYMBOL))
   (slot valor (type SYMBOL) (default si))
   (slot detalle (type STRING) (default "")))

(deftemplate estado-sistema
   (slot subsistema (type SYMBOL))
   (slot condicion (type SYMBOL))
   (slot descripcion (type STRING)))

(deftemplate diagnostico
   (slot id (type SYMBOL))
   (slot sistema (type STRING))
   (slot problema (type STRING))
   (slot causa-probable (type STRING))                  ; CAUSA ÚNICA IDENTIFICADA
   (slot gravedad (type SYMBOL) (allowed-values BAJA MEDIA ALTA CRITICA))
   (slot recomendacion (type STRING))
   (slot prioridad (type INTEGER) (default 1)))

(deftemplate control-reporte
   (slot ejecutado (type SYMBOL) (default no)))


;; =====================================================================
;; 2. REGLAS DE PRODUCCIÓN DE DIAGNÓSTICO CON CAUSA ÚNICA
;; =====================================================================

;; ---------------------------------------------------------------------
;; CATEGORÍA 1: EL MOTOR NO ARRANCA / PROBLEMAS DE ARRANQUE
;; ---------------------------------------------------------------------

;; 1.1: Batería descargada
(defrule regla-bateria-descargada-exacta
   (sintoma (nombre motor-no-arranca) (valor si))
   (sintoma (nombre motor-gira) (valor no))
   (sintoma (nombre chasquido-arranque) (valor si))
   (sintoma (nombre luces-apagan-en-clic) (valor si))
   (sintoma (nombre bornes-sulfatados-flojos) (valor no))
   =>
   (assert (diagnostico
              (id diag-bateria-descargada)
              (sistema "Sistema Eléctrico y de Arranque")
              (problema "El motor de arranque no recibe suficiente amperaje para girar.")
              (causa-probable "Batería descargada con voltaje en circuito inferior a 11.8V.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Cargar la batería con cargador externo o realizar puente de arranque con cables auxiliares."))))

;; 1.2: Bornes de batería sulfatados o flojos
(defrule regla-bornes-sulfatados-exacta
   (sintoma (nombre motor-no-arranca) (valor si))
   (sintoma (nombre motor-gira) (valor no))
   (sintoma (nombre chasquido-arranque) (valor si))
   (sintoma (nombre luces-apagan-en-clic) (valor si))
   (sintoma (nombre bornes-sulfatados-flojos) (valor si))
   =>
   (assert (diagnostico
              (id diag-bornes-sulfatados)
              (sistema "Conexiones de Batería")
              (problema "Falso contacto por resistencia de óxido/sarro que impide el paso de alta corriente.")
              (causa-probable "Bornes de batería sulfatados o terminales flojos.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Desconectar terminales, cepillar el sulfato con agua caliente y bicarbonato, lijar y apretar firmemente."))))

;; 1.3: Solenoide del motor de arranque trabado
(defrule regla-solenoide-arranque-exacta
   (sintoma (nombre motor-no-arranca) (valor si))
   (sintoma (nombre motor-gira) (valor no))
   (sintoma (nombre chasquido-arranque) (valor si))
   (sintoma (nombre luces-apagan-en-clic) (valor no))
   =>
   (assert (diagnostico
              (id diag-solenoide-trabado)
              (sistema "Motor de Arranque")
              (problema "El solenoide acopla pero los contactos internos de potencia no transmiten corriente al inducido.")
              (causa-probable "Solenoide (automático) del motor de arranque quemado o trabado mecánicamente.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Golpear suavemente el cuerpo del arranque mientras se acciona la llave; desmontar y reparar solenoide."))))

;; 1.4: Batería en cortocircuito interno (muerte súbita)
(defrule regla-bateria-corto-total-exacta
   (sintoma (nombre motor-no-arranca) (valor si))
   (sintoma (nombre motor-gira) (valor no))
   (sintoma (nombre luces-tablero) (valor no))
   (sintoma (nombre energia-general) (valor nada))
   (sintoma (nombre masa-conectada) (valor si))
   =>
   (assert (diagnostico
              (id diag-bateria-muerta)
              (sistema "Batería Principal")
              (problema "Pérdida absoluta de diferencia de potencial en todo el vehículo.")
              (causa-probable "Batería con celdas comunicadas en cortocircuito interno (fin irreversible de vida útil).")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar la batería de inmediato por una nueva con las especificaciones de CCA del fabricante."))))

;; 1.5: Fusible maxifuse principal quemado
(defrule regla-maxifuse-quemado-exacta
   (sintoma (nombre motor-no-arranca) (valor si))
   (sintoma (nombre motor-gira) (valor no))
   (sintoma (nombre luces-tablero) (valor no))
   (sintoma (nombre energia-general) (valor algunos))
   =>
   (assert (diagnostico
              (id diag-maxifuse-quemado)
              (sistema "Distribución Eléctrica Primaria")
              (problema "Línea de contacto del encendido interrumpida mientras accesorios secundarios aún tienen energía.")
              (causa-probable "Fusible principal de ignición (Maxi-Fuse de 40A-60A) quemado en vano motor.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Localizar la fusiblera principal junto a la batería y sustituir el maxifuse quemado por uno del mismo amperaje."))))

;; 1.6: Motor de arranque en corto (gira pesado en caliente)
(defrule regla-arranque-pesado-caliente-exacta
   (sintoma (nombre motor-gira-lento) (valor si))
   (sintoma (nombre motor-caliente-frio) (valor caliente))
   =>
   (assert (diagnostico
              (id diag-arranque-pesado-caliente)
              (sistema "Motor de Arranque (Bujes y Carbones)")
              (problema "El inducido roza contra los campos magnéticos por dilatación térmica.")
              (causa-probable "Bujes del motor de arranque gastados con pérdida de centrado en caliente.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Desmontar el motor de arranque en taller electricista para sustituir bujes y porta-carbones."))))

;; 1.7: Batería agotada en frío (CCA degradado)
(defrule regla-arranque-pesado-frio-exacta
   (sintoma (nombre motor-gira-lento) (valor si))
   (sintoma (nombre motor-caliente-frio) (valor frio))
   =>
   (assert (diagnostico
              (id diag-arranque-pesado-frio)
              (sistema "Batería - Capacidad de Arranque en Frío")
              (problema "La batería no entrega los amperios de pico requeridos en frío.")
              (causa-probable "Degradación química de las placas de plomo con pérdida de capacidad CCA.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Cargar la batería o sustituirla si ya superó los 2 o 3 años de antigüedad."))))

;; 1.8: Tanque de combustible vacío
(defrule regla-tanque-vacio-exacta
   (sintoma (nombre motor-gira-normal) (valor si))
   (sintoma (nombre indicador-combustible-vacio) (valor si))
   =>
   (assert (diagnostico
              (id diag-tanque-vacio)
              (sistema "Suministro de Combustible")
              (problema "No ingresa combustible por ausencia física en el depósito.")
              (causa-probable "Tanque de combustible completamente vacío.")
              (gravedad MEDIA)
              (prioridad 4)
              (recomendacion "Cargar un mínimo de 5 a 10 litros de combustible y purgar circuito antes de insistir con el arranque."))))

;; 1.9: Motor eléctrico de bomba de nafta quemado
(defrule regla-bomba-nafta-quemada-exacta
   (sintoma (nombre motor-gira-normal) (valor si))
   (sintoma (nombre indicador-combustible-vacio) (valor no))
   (sintoma (nombre bomba-zumba-contacto) (valor no))
   (sintoma (nombre rele-bomba-clic) (valor si))
   =>
   (assert (diagnostico
              (id diag-bomba-quemada)
              (sistema "Bomba de Combustible")
              (problema "Llega señal eléctrica de activación pero la bomba sumergida no gira.")
              (causa-probable "Motor eléctrico interno de la bomba de nafta quemado.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Desmontar aforador bajo asiento trasero o tanque para sustituir la bomba de combustible."))))

;; 1.10: Relé de bomba de combustible inoperativo
(defrule regla-rele-bomba-quemado-exacta
   (sintoma (nombre motor-gira-normal) (valor si))
   (sintoma (nombre indicador-combustible-vacio) (valor no))
   (sintoma (nombre bomba-zumba-contacto) (valor no))
   (sintoma (nombre rele-bomba-clic) (valor no))
   =>
   (assert (diagnostico
              (id diag-rele-bomba-quemado)
              (sistema "Circuito de Control de Combustible")
              (problema "No llega corriente a la bomba por interrupción en el circuito de control.")
              (causa-probable "Relé de la bomba de combustible quemado o bobina de mando cortada.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Sustituir el relé de bomba de nafta ubicado en la fusiblera del vano motor o habitáculo."))))

;; 1.11: Filtro de combustible tapado
(defrule regla-filtro-combustible-tapado-exacta
   (sintoma (nombre motor-gira-normal) (valor si))
   (sintoma (nombre indicador-combustible-vacio) (valor no))
   (sintoma (nombre bomba-zumba-contacto) (valor si))
   =>
   (assert (diagnostico
              (id diag-filtro-tapado)
              (sistema "Línea de Presión de Combustible")
              (problema "La bomba presuriza pero el flujo hacia la rampa de inyección está bloqueado.")
              (causa-probable "Filtro de combustible severamente obstruido por sedimentos.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Reemplazar el cartucho del filtro de combustible (generalmente ubicado cerca del tanque o filtro en línea)."))))

;; 1.12: Sensor de cigüeñal (CKP) defectuoso (sin señal de giro)
(defrule regla-sensor-ckp-arranque-exacta
   (sintoma (nombre motor-gira-normal) (valor si))
   (sintoma (nombre chispa-bujias) (valor no))
   (sintoma (nombre aguja-tacometro-mueve) (valor cero))
   =>
   (assert (diagnostico
              (id diag-sensor-ckp-arranque)
              (sistema "Sincronismo de Encendido")
              (problema "La computadora del motor (ECU) no detecta la rotación del motor y no autoriza disparo de chispa.")
              (causa-probable "Sensor de posición de cigüeñal (CKP) defectuoso o con cable cortado.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Comprobar resistencia del sensor inductivo CKP o sustituir el sensor ubicado frente a la rueda fónica."))))

;; 1.13: Bobina de encendido averiada
(defrule regla-bobina-encendido-exacta
   (sintoma (nombre motor-gira-normal) (valor si))
   (sintoma (nombre chispa-bujias) (valor no))
   (sintoma (nombre aguja-tacometro-mueve) (valor mueve))
   (sintoma (nombre bujia-mojada-nafta) (valor si))
   =>
   (assert (diagnostico
              (id diag-bobina-quemada)
              (sistema "Alta Tensión de Encendido")
              (problema "La ECU envía los pulsos pero el transformador de alta tensión no genera el arco eléctrico.")
              (causa-probable "Bobina de encendido (o módulo de bobinas) en cortocircuito interno.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Reemplazar la bobina de encendido y secar los cilindros ahogados antes de reiniciar el arranque."))))


;; ---------------------------------------------------------------------
;; CATEGORÍA 2: EL MOTOR SE APAGA
;; ---------------------------------------------------------------------

;; 2.1: Válvula IAC / Paso a paso trabada
(defrule regla-valvula-iac-exacta
   (sintoma (nombre motor-se-apaga) (valor si))
   (sintoma (nombre momento-apagado) (valor ralenti))
   (sintoma (nombre comportamiento-apagado-ralenti) (valor inmediato))
   =>
   (assert (diagnostico
              (id diag-iac-trabada)
              (sistema "Control de Marcha Lenta")
              (problema "El conducto de derivación de aire se cierra de golpe al soltar el pedal.")
              (causa-probable "Válvula de control de ralentí (IAC / motor paso a paso) sucia o trabada por carbonilla.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Desmontar y limpiar la válvula IAC con limpiador de cuerpos de mariposa o sustituir el actuador."))))

;; 2.2: Entrada de aire pirata (manguera de vacío rajada)
(defrule regla-vacio-rajado-exacta
   (sintoma (nombre motor-se-apaga) (valor si))
   (sintoma (nombre momento-apagado) (valor ralenti))
   (sintoma (nombre comportamiento-apagado-ralenti) (valor oscila))
   (sintoma (nombre silbido-vacio-motor) (valor si))
   =>
   (assert (diagnostico
              (id diag-vacio-rajado)
              (sistema "Admisión y Depresión de Motor")
              (problema "Ingresa aire no censado por el múltiple alterando la mezcla estequiométrica.")
              (causa-probable "Manguera de vacío rajada o desconectada en el múltiple de admisión.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Revisar visualmente las mangueras de vacío del servofreno y canister; reemplazar la manguera dañada."))))

;; 2.3: Sensor CKP con falla térmica en marcha
(defrule regla-ckp-termico-marcha-exacta
   (sintoma (nombre motor-se-apaga) (valor si))
   (sintoma (nombre momento-apagado) (valor marcha))
   (sintoma (nombre forma-apagado-marcha) (valor golpe))
   (sintoma (nombre arranca-al-enfriar) (valor si))
   =>
   (assert (diagnostico
              (id diag-ckp-termico)
              (sistema "Gestión Electrónica de Motor")
              (problema "El bobinado interno del sensor se dilata con el calor y abre el circuito repentinamente.")
              (causa-probable "Falla térmica interna del sensor de posición de cigüeñal (CKP).")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar el sensor CKP para evitar detenciones peligrosas del vehículo en velocidad."))))

;; 2.4: Bomba de combustible con caída de caudal en caliente
(defrule regla-bomba-recalienta-marcha-exacta
   (sintoma (nombre motor-se-apaga) (valor si))
   (sintoma (nombre momento-apagado) (valor marcha))
   (sintoma (nombre forma-apagado-marcha) (valor tironea))
   =>
   (assert (diagnostico
              (id diag-bomba-recalienta)
              (sistema "Presión de Rampa de Combustible")
              (problema "La presión cae progresivamente provocando tironeos hasta la detención total.")
              (causa-probable "Bomba de combustible recalentada por desgaste en su inducido eléctrico.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Medir presión de combustible en rampa bajo carga; cambiar la bomba sumergida."))))


;; ---------------------------------------------------------------------
;; CATEGORÍA 3: RUIDO EXTRAÑO
;; ---------------------------------------------------------------------

;; 3.1: Correa poli-V reseca o floja
(defrule regla-correa-reseca-exacta
   (sintoma (nombre ruido-extrano) (valor si))
   (sintoma (nombre tipo-ruido) (valor chirrido))
   (sintoma (nombre agua-en-correa-silencia) (valor si))
   =>
   (assert (diagnostico
              (id diag-correa-reseca)
              (sistema "Correas de Transmisión Auxiliar")
              (problema "Patinamiento superficial de la goma sobre las poleas metálicas.")
              (causa-probable "Correa de accesorios poli-V resecada, cristalizada o con tensión insuficiente.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Ajustar la tensión de la correa o reemplazarla por una nueva."))))

;; 3.2: Rodillo tensor de correa dañado
(defrule regla-tensor-correa-danado-exacta
   (sintoma (nombre ruido-extrano) (valor si))
   (sintoma (nombre tipo-ruido) (valor chirrido))
   (sintoma (nombre agua-en-correa-silencia) (valor no))
   =>
   (assert (diagnostico
              (id diag-tensor-danado)
              (sistema "Poleas y Tensores de Accesorios")
              (problema "Fricción interna del rodamiento del tensor con desalineación de pista.")
              (causa-probable "Rodamiento del rodillo tensor de correa de accesorios gripado o dañado.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Reemplazar el conjunto del tensor automático y polea loca de accesorios."))))

;; 3.3: Cojinetes / Metales de biela fundidos (golpe bajo)
(defrule regla-metales-biela-fundidos-exacta
   (sintoma (nombre ruido-extrano) (valor si))
   (sintoma (nombre tipo-ruido) (valor golpeteo-metalico))
   (sintoma (nombre ubicacion-golpeteo) (valor baja))
   =>
   (assert (diagnostico
              (id diag-metales-fundidos)
              (sistema "Mecánica Baja del Motor")
              (problema "Holgura destructiva entre muñones del cigüeñal y cabezas de biela.")
              (causa-probable "Cojinetes / metales de biela fundidos por falta crítica de presión de aceite.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "URGENTE: Detener el motor inmediatamente y remolcar en grúa. Requiere rectificación de motor."))))

;; 3.4: Botadores hidráulicos descargados (golpe alto)
(defrule regla-botadores-descargados-exacta
   (sintoma (nombre ruido-extrano) (valor si))
   (sintoma (nombre tipo-ruido) (valor golpeteo-metalico))
   (sintoma (nombre ubicacion-golpeteo) (valor alta))
   =>
   (assert (diagnostico
              (id diag-botadores-descargados)
              (sistema "Distribución y Válvulas")
              (problema "Juego excesivo entre levas y válvulas por falta de carga hidráulica.")
              (causa-probable "Botadores hidráulicos de válvulas descargados u obstruidos por barniz de aceite.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Verificar nivel y viscosidad del aceite; realizar enjuague de motor o reemplazar botadores."))))

;; 3.5: Rulemán de maza de rueda dañado
(defrule regla-ruleman-rueda-exacta
   (sintoma (nombre ruido-extrano) (valor si))
   (sintoma (nombre tipo-ruido) (valor zumbido))
   (sintoma (nombre zumbido-varia-curva) (valor si))
   =>
   (assert (diagnostico
              (id diag-ruleman-rueda)
              (sistema "Tren Rodante y Mazas")
              (problema "Pistas de rodamientos de bolas o rodillos picadas por desgaste y fatiga.")
              (causa-probable "Rulemán / rodamiento de maza de rueda dañado.")
              (gravedad MEDIA)
              (prioridad 4)
              (recomendacion "Reemplazar el rulemán de rueda afectado antes de que se clave en velocidad."))))


;; ---------------------------------------------------------------------
;; CATEGORÍA 4: TEMPERATURA ELEVADA (SOBRECALENTAMIENTO)
;; ---------------------------------------------------------------------

;; 4.1: Sensor de temperatura (ECT) / Termocontacto averiado
(defrule regla-sensor-ect-averiado-exacta
   (sintoma (nombre temperatura-elevada) (valor si))
   (sintoma (nombre electroventilador-enciende) (valor no))
   (sintoma (nombre electro-enciende-directo-ac) (valor si))
   =>
   (assert (diagnostico
              (id diag-sensor-ect)
              (sistema "Sensores de Gestión Térmica")
              (problema "El circuito eléctrico del electro funciona, pero no recibe la orden de arranque por sensor defectuoso.")
              (causa-probable "Termocontacto del radiador o sensor de temperatura de refrigerante (ECT) averiado.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar el sensor de temperatura de refrigerante y purgar el circuito."))))

;; 4.2: Motor de electroventilador trabado / engranado
(defrule regla-motor-electro-trabado-exacta
   (sintoma (nombre temperatura-elevada) (valor si))
   (sintoma (nombre electroventilador-enciende) (valor no))
   (sintoma (nombre electro-enciende-directo-ac) (valor no))
   (sintoma (nombre aspas-electro-giran-libres) (valor no))
   =>
   (assert (diagnostico
              (id diag-electro-trabado)
              (sistema "Flujo de Aire Forzado en Radiador")
              (problema "El eje del ventilador no gira por fricción mecánica extrema.")
              (causa-probable "Motor eléctrico del electroventilador trabado mecánicamente o buje clavado.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar el motor del electroventilador completo."))))

;; 4.3: Manguera del circuito de refrigeración rajada
(defrule regla-manguera-rota-exacta
   (sintoma (nombre temperatura-elevada) (valor si))
   (sintoma (nombre perdida-liquido) (valor si))
   (sintoma (nombre origen-fuga-refrigerante) (valor manguera))
   =>
   (assert (diagnostico
              (id diag-manguera-rota)
              (sistema "Canalización de Refrigerante")
              (problema "Despresurización rápida y vaciado del fluido refrigerante.")
              (causa-probable "Manguera del circuito de refrigeración rajada o abrazadera cortada.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar la manguera dañada, ajustar abrazaderas y rellenar con refrigerante al 50% con agua desmineralizada."))))

;; 4.4: Radiador pinchado o rajado
(defrule regla-radiador-pinchado-exacta
   (sintoma (nombre temperatura-elevada) (valor si))
   (sintoma (nombre perdida-liquido) (valor si))
   (sintoma (nombre origen-fuga-refrigerante) (valor radiador))
   =>
   (assert (diagnostico
              (id diag-radiador-pinchado)
              (sistema "Disipador Térmico (Radiador)")
              (problema "Fuga de refrigerante por celdas rotas o fisura en los tanques plásticos laterales.")
              (causa-probable "Panel del radiador pinchado o tacho plástico rajado.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Desmontar el radiador para reparación o colocar radiador nuevo."))))

;; 4.5: Termostato trabado cerrado
(defrule regla-termostato-cerrado-exacta
   (sintoma (nombre temperatura-elevada) (valor si))
   (sintoma (nombre perdida-liquido) (valor no))
   (sintoma (nombre manguera-inferior-fria) (valor si))
   (sintoma (nombre retorno-refrigerante-activo) (valor si))
   =>
   (assert (diagnostico
              (id diag-termostato-cerrado)
              (sistema "Control Termodinámico")
              (problema "La válvula termosensible no expande impidiendo el paso del líquido hacia el radiador.")
              (causa-probable "Termostato trabado herméticamente en posición cerrada.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar el termostato inmediatamente antes de soplar la junta de tapa."))))

;; 4.6: Turbina de bomba de agua destruida
(defrule regla-bomba-agua-destruida-exacta
   (sintoma (nombre temperatura-elevada) (valor si))
   (sintoma (nombre perdida-liquido) (valor no))
   (sintoma (nombre manguera-inferior-fria) (valor si))
   (sintoma (nombre retorno-refrigerante-activo) (valor no))
   =>
   (assert (diagnostico
              (id diag-turbina-bomba-destruida)
              (sistema "Circulación Forzada de Refrigerante")
              (problema "La polea gira pero la turbina interna no impulsa el líquido refrigerante.")
              (causa-probable "Turbina de la bomba de agua desprendida del eje o con paletas destruidas.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Reemplazar la bomba de agua junto con el kit de correa de distribución."))))


;; ---------------------------------------------------------------------
;; CATEGORÍA 5: BATERÍA DESCARGADA / SISTEMA DE CARGA
;; ---------------------------------------------------------------------

;; 5.1: Correa de alternador cortada
(defrule regla-correa-alternador-cortada-exacta
   (sintoma (nombre testigo-bateria-encendido) (valor si))
   (sintoma (nombre correa-alternador-estado) (valor cortada))
   =>
   (assert (diagnostico
              (id diag-correa-alternador-cortada)
              (sistema "Transmisión de Generador Eléctrico")
              (problema "El alternador no recibe giro del cigüeñal para generar energía.")
              (causa-probable "Correa de alternador cortada o salida de sus poleas.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Instalar una nueva correa de accesorios y comprobar la alineación de poleas."))))

;; 5.2: Regulador de voltaje o placa de diodos quemada
(defrule regla-alternador-regulador-quemado-exacta
   (sintoma (nombre testigo-bateria-encendido) (valor si))
   (sintoma (nombre correa-alternador-estado) (valor colocada))
   =>
   (assert (diagnostico
              (id diag-regulador-alternador-quemado)
              (sistema "Generación y Regulación Eléctrica")
              (problema "El alternador gira pero no genera campo magnético ni rectifica corriente.")
              (causa-probable "Regulador de voltaje o placa de diodos del alternador quemada.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Desmontar el alternador para recambio del regulador de voltaje y carbones."))))

;; 5.3: Fuga de corriente parásita en reposo
(defrule regla-fuga-parasita-exacta
   (sintoma (nombre bateria-descargada) (valor si))
   (sintoma (nombre desconectar-borne-evita-descarga) (valor si))
   =>
   (assert (diagnostico
              (id diag-fuga-parasita)
              (sistema "Consumos Residuales del Vehículo")
              (problema "Hay un consumidor encendido con el vehículo cerrado que drena la batería.")
              (causa-probable "Fuga de corriente parásita en reposo (módulo de alarma, estéreo o luz interna fija).")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Medir consumo en reposo con pinza amperimétrica (normal <0.05A) e ir retirando fusibles para aislar el circuito defectuoso."))))

;; 5.4: Batería sulfatada por fin de vida útil
(defrule regla-bateria-fin-vida-util-exacta
   (sintoma (nombre bateria-descargada) (valor si))
   (sintoma (nombre desconectar-borne-evita-descarga) (valor no))
   =>
   (assert (diagnostico
              (id diag-bateria-fin-vida)
              (sistema "Batería / Acumulador Químico")
              (problema "La batería sufre autodescarga interna espontánea sin retener energía.")
              (causa-probable "Batería sulfatada internamente por cumplir su ciclo útil de vida (2-4 años).")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Sustituir la batería por una nueva con garantía."))))


;; ---------------------------------------------------------------------
;; CATEGORÍA 6: HUMO POR EL ESCAPE
;; ---------------------------------------------------------------------

;; 6.1: Junta de tapa de cilindros quemada/soplada
(defrule regla-junta-tapa-soplada-exacta
   (sintoma (nombre humo-escape) (valor si))
   (sintoma (nombre color-humo) (valor blanco))
   (sintoma (nombre emulsion-aceite-cafe-leche) (valor si))
   =>
   (assert (diagnostico
              (id diag-junta-tapa-soplada)
              (sistema "Culata y Estanqueidad de Motor")
              (problema "El refrigerante se filtra hacia las cámaras de combustión y hacia los conductos de lubricación.")
              (causa-probable "Junta de tapa de cilindros quemada / soplada por sobrecalentamiento.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "NO rodar el auto. Desmontar tapa de cilindros, enviar a rectificar plano y colocar junta nueva con tornillos nuevos torquados a especificación."))))

;; 6.2: Retenes de guías de válvulas resecos
(defrule regla-retenes-valvulas-exacta
   (sintoma (nombre humo-escape) (valor si))
   (sintoma (nombre color-humo) (valor azul))
   (sintoma (nombre momento-humo-azul) (valor arranque))
   =>
   (assert (diagnostico
              (id diag-retenes-valvulas)
              (sistema "Distribución Superior")
              (problema "El aceite del árbol de levas se escurre por los vástagos hacia los cilindros mientras el auto reposa.")
              (causa-probable "Retenes de guías de válvulas resecos, quebradizos y desgastados.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Reemplazar el juego de retenes de válvulas (muchos motores permiten hacerlo sin sacar la tapa de cilindros)."))))

;; 6.3: Aros de pistón desgastados (desgaste en cilindros)
(defrule regla-aros-piston-gastados-exacta
   (sintoma (nombre humo-escape) (valor si))
   (sintoma (nombre color-humo) (valor azul))
   (sintoma (nombre momento-humo-azul) (valor acelerando))
   =>
   (assert (diagnostico
              (id diag-aros-gastados)
              (sistema "Grupo Térmico y Pistones")
              (problema "Los aros rascadores de aceite no barren el lubricante de las camisas durante la carrera ascendente.")
              (causa-probable "Aros de pistón desgastados o alineados con ovalización de cilindros.")
              (gravedad CRITICA)
              (prioridad 1)
              (recomendacion "Medir compresión de cilindros; requiere cambio de aros o rectificación de cilindros del bloque."))))

;; 6.4: Filtro de aire obstruido (mezcla rica)
(defrule regla-filtro-aire-sucio-exacta
   (sintoma (nombre humo-escape) (valor si))
   (sintoma (nombre color-humo) (valor negro))
   (sintoma (nombre filtro-aire-tupido) (valor si))
   =>
   (assert (diagnostico
              (id diag-filtro-aire-sucio)
              (sistema "Admisión de Aire")
              (problema "Falta de oxígeno para quemar el combustible inyectado, generando hollín negro.")
              (causa-probable "Filtro de aire de admisión saturado de suciedad y tierra.")
              (gravedad MEDIA)
              (prioridad 3)
              (recomendacion "Reemplazar inmediatamente el elemento filtrante de aire del motor."))))

;; 6.5: Inyector de combustible trabado abierto
(defrule regla-inyector-trabado-abierto-exacta
   (sintoma (nombre humo-escape) (valor si))
   (sintoma (nombre color-humo) (valor negro))
   (sintoma (nombre filtro-aire-tupido) (valor no))
   (sintoma (nombre falla-cilindro-especifico) (valor si))
   =>
   (assert (diagnostico
              (id diag-inyector-abierto)
              (sistema "Inyección Electrónica de Combustible")
              (problema "Un inyector no sella y vierte un chorro continuo de nafta cruda en la cámara.")
              (causa-probable "Inyector de combustible mecánicamente trabado en posición abierta.")
              (gravedad ALTA)
              (prioridad 2)
              (recomendacion "Probar los inyectores en banco de prueba y ultrasonido; sustituir el inyector defectuoso antes de lavar el cilindro."))))


;; ---------------------------------------------------------------------
;; 3. REGLAS DE REPORTE FINAL
;; ---------------------------------------------------------------------

(defrule regla-generar-reporte-diagnosticos
   (declare (salience -100))
   (not (control-reporte (ejecutado si)))
   =>
   (assert (control-reporte (ejecutado si)))
   (printout t crlf)
   (printout t "================================================================================" crlf)
   (printout t "                 INFORME DE DIAGNÓSTICO DEL SISTEMA EXPERTO                      " crlf)
   (printout t "================================================================================" crlf))

(defrule regla-mostrar-cada-diagnostico
   (declare (salience -150))
   (control-reporte (ejecutado si))
   ?d <- (diagnostico (id ?id)
                      (sistema ?sis)
                      (problema ?prob)
                      (causa-probable ?causa)
                      (gravedad ?grav)
                      (recomendacion ?rec)
                      (prioridad ?prio))
   =>
   (printout t crlf)
   (printout t ">> [SISTEMA]: " ?sis "  (Nivel de Gravedad: " ?grav ")" crlf)
   (printout t "   PROBLEMA:       " ?prob crlf)
   (printout t "   CAUSA EXACTA:   " ?causa crlf)
   (printout t "   RECOMENDACIÓN:  " ?rec crlf)
   (printout t "--------------------------------------------------------------------------------" crlf))

(defrule regla-sin-diagnosticos-detectados
   (declare (salience -200))
   (control-reporte (ejecutado si))
   (not (diagnostico))
   =>
   (printout t crlf)
   (printout t ">> No se detectaron anomalías concluyentes con los síntomas ingresados." crlf)
   (printout t "   Recomendación: Verificar parámetros adicionales o consultar al servicio técnico." crlf)
   (printout t "--------------------------------------------------------------------------------" crlf))
