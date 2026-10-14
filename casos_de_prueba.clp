;;; =====================================================================
;;; CASOS DE PRUEBA AUTOMATIZADOS - PROYECTO 7
;;; Validación de Diagnósticos Deterministas con Causa Única
;;; =====================================================================

(deftemplate caso-activo
   (slot id (type SYMBOL)))

;; CASO 1: Batería descargada (voltaje bajo confirmado, bornes limpios)
(defrule cargar-caso-1
   (caso-activo (id caso-1))
   =>
   (printout t crlf "[EJECUTANDO CASO 1: Motor no arranca, hace 'clic', luces caen y bornes limpios]" crlf)
   (assert (sintoma (nombre motor-no-arranca) (valor si)))
   (assert (sintoma (nombre motor-gira) (valor no)))
   (assert (sintoma (nombre chasquido-arranque) (valor si)))
   (assert (sintoma (nombre luces-apagan-en-clic) (valor si)))
   (assert (sintoma (nombre bornes-sulfatados-flojos) (valor no))))

;; CASO 2: Falla térmica exacta del sensor de cigüeñal (CKP) en marcha
(defrule cargar-caso-2
   (caso-activo (id caso-2))
   =>
   (printout t crlf "[EJECUTANDO CASO 2: Motor se apaga de golpe en velocidad y arranca al enfriar]" crlf)
   (assert (sintoma (nombre motor-se-apaga) (valor si)))
   (assert (sintoma (nombre momento-apagado) (valor marcha)))
   (assert (sintoma (nombre forma-apagado-marcha) (valor golpe)))
   (assert (sintoma (nombre arranca-al-enfriar) (valor si))))

;; CASO 3: Cojinetes / Metales de biela fundidos (golpeteo en cárter)
(defrule cargar-caso-3
   (caso-activo (id caso-3))
   =>
   (printout t crlf "[EJECUTANDO CASO 3: Ruido de golpeteo metálico en la parte baja del motor]" crlf)
   (assert (sintoma (nombre ruido-extrano) (valor si)))
   (assert (sintoma (nombre tipo-ruido) (valor golpeteo-metalico)))
   (assert (sintoma (nombre ubicacion-golpeteo) (valor baja))))

;; CASO 4: Sensor de temperatura (ECT) averiado (electro arranca con A/C)
(defrule cargar-caso-4
   (caso-activo (id caso-4))
   =>
   (printout t crlf "[EJECUTANDO CASO 4: Sobrecalentamiento, electro inactivo pero arranca con A/C]" crlf)
   (assert (sintoma (nombre temperatura-elevada) (valor si)))
   (assert (sintoma (nombre electroventilador-enciende) (valor no)))
   (assert (sintoma (nombre electro-enciende-directo-ac) (valor si))))

;; CASO 5: Junta de tapa de cilindros soplada (emulsión en aceite)
(defrule cargar-caso-5
   (caso-activo (id caso-5))
   =>
   (printout t crlf "[EJECUTANDO CASO 5: Humo blanco espeso con emulsión blanquecina en el aceite]" crlf)
   (assert (sintoma (nombre humo-escape) (valor si)))
   (assert (sintoma (nombre color-humo) (valor blanco)))
   (assert (sintoma (nombre emulsion-aceite-cafe-leche) (valor si))))

;; CASO 6: Correa de alternador cortada
(defrule cargar-caso-6
   (caso-activo (id caso-6))
   =>
   (printout t crlf "[EJECUTANDO CASO 6: Testigo de batería encendido y correa rota visible]" crlf)
   (assert (sintoma (nombre testigo-bateria-encendido) (valor si)))
   (assert (sintoma (nombre correa-alternador-estado) (valor cortada))))
