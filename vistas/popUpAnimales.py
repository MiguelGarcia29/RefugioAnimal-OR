from PyQt5 import QtWidgets, uic
from PyQt5.QtCore import QDate
from vistas.utilidades import cargar_razas, cargar_especies, on_raza_changed, rellenar_tabla
from conexion import DataBase

def abrir_animal(self, modo, tabla_destino, id_animal=None): 
    ventana = DialogoAnimal(modo=modo, parent=self, tabla_destino=tabla_destino, id_animal=id_animal)
    if ventana.exec_() == QtWidgets.QDialog.Accepted:
        print("Datos de Animal guardados")

class DialogoAnimal(QtWidgets.QDialog):
    def __init__(self, modo="añadir", tabla_destino=None, parent=None, id_animal=None): 
        super().__init__(parent)
        uic.loadUi("vistas/popUpAnimales.ui", self)
        
        self.modo = modo
        self.tabla_destino = tabla_destino
        
        # 1. Cargas iniciales de datos
        cargar_especies(self)
                
        # 2. Rellenar datos si es edición
        if self.modo == "editar" and isinstance(id_animal, dict):
            self.id_animal_editar = id_animal["id"]
            self.rellenar_para_editar(id_animal)
        else:
            self.id_animal_editar = id_animal
            cargar_razas(self) # Si es añadir, cargamos razas por defecto

        self.configurar_interfaz()
        
        # 3. CONECTAR SEÑALES AL FINAL 
        # (Así el autorrelleno no dispara eventos accidentales)
        self.input_especie.currentIndexChanged.connect(lambda: cargar_razas(self))
        self.input_raza.currentIndexChanged.connect(lambda: on_raza_changed(self))
        
        self.input_sexo.addItem("Sexo", None)
        self.input_sexo.model().item(0).setEnabled(False) 
        self.input_sexo.setCurrentIndex(0)
        self.input_sexo.addItem("Macho", "M")
        self.input_sexo.addItem("Hembra", "H")
        
        # Fijar en hoy la fecha de los calendarios
        self.input_fechaNacimiento.calendarWidget().setSelectedDate(QDate.currentDate())
        self.input_fechaAdopcion.calendarWidget().setSelectedDate(QDate.currentDate())
        
    def rellenar_campos(self, datos):
        # Campos de texto
        self.input_id.setText(datos["id"])
        self.input_nombre.setText(datos["nombre"])
        self.input_color.setText(datos["color"])
        self.input_caracteristicas.setText(datos["caracteristicas"])

        # Sexo (buscar por el texto: Macho/Hembra o por el valor M/H)
        index_sexo = self.input_sexo.findText(datos["sexo"])
        if index_sexo != -1:
            self.input_sexo.setCurrentIndex(index_sexo)

        # Especie y Raza
        index_esp = self.input_especie.findText(datos["especie"])
        if index_esp != -1:
            self.input_especie.setCurrentIndex(index_esp)
            # Forzamos la carga de razas de esa especie antes de buscar la raza
            cargar_razas(self) 
            index_raza = self.input_raza.findText(datos["raza"])
            if index_raza != -1:
                self.input_raza.setCurrentIndex(index_raza)

        # Fecha de Nacimiento (Si no la ocultas en editar)
        if "fechaNac" in datos:
            fecha = QDate.fromString(datos["fechaNac"], "dd/MM/yyyy")
            self.input_fechaNacimiento.setDate(fecha)
    
    # --- Dentro de DialogoAnimal ---

    def rellenar_para_editar(self, datos):
        # 1. Premarcar el SEXO
        # findText busca el índice donde dice "Macho" o "Hembra"
        index_sexo = self.input_sexo.findText(datos["sexo"])
        if index_sexo != -1:
            self.input_sexo.setCurrentIndex(index_sexo)

        # 2. Premarcar la ESPECIE
        index_esp = self.input_especie.findText(datos["especie"])
        if index_esp != -1:
            self.input_especie.setCurrentIndex(index_esp)
            
            # IMPORTANTE: Al cambiar la especie, el combo de razas se suele limpiar.
            # Debemos forzar la carga de razas de esa especie antes de buscar la raza.
            cargar_razas(self) 
            
            # 3. Premarcar la RAZA
            index_raza = self.input_raza.findText(datos["raza"])
            if index_raza != -1:
                self.input_raza.setCurrentIndex(index_raza)

        # 4. Otros campos
        self.input_nombre.setText(datos["nombre"])
        self.input_color.setText(datos["color"])
        self.input_caracteristicas.setText(datos["caracteristicas"])
        
    def configurar_interfaz(self):
        if self.modo == "añadir":
            self.titulo.setText("Añadir Animal")
            # El ID suele ser autoincremental, así que lo ocultamos
            self.input_id.setVisible(False)
            self.input_fechaAdopcion.setVisible(False)
            self.label_adopcion.setVisible(False)
            self.input_adoptado.setVisible(False)
            self.btn_animal.setText("Añadir")
            self.btn_animal.clicked.connect(self.insertar_animal)

        elif self.modo == "editar":
            self.titulo.setText("Editar Animal")
            if self.id_animal_editar:
                self.input_id.setText(str(self.id_animal_editar))
                self.input_id.setEnabled(False)
            self.label_nacimiento.setVisible(False)
            self.input_fechaNacimiento.setVisible(False)
            self.label_adopcion.setVisible(False)
            self.input_fechaAdopcion.setVisible(False)
            self.input_adoptado.setVisible(False)
            self.btn_animal.setText("Editar")
            self.btn_animal.clicked.connect(self.editar_animal)
            

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Animal")
            self.btn_animal.setText("Buscar")
            self.label_nacimiento.setVisible(False)
            self.input_fechaNacimiento.setVisible(False)
            self.label_adopcion.setVisible(False)
            self.input_fechaAdopcion.setVisible(False)
            self.btn_animal.clicked.connect(self.buscar_animal)
            from vistas.adopcion import AdopcionWindow
            if isinstance(self.parent(), AdopcionWindow):
                self.input_adoptado.setVisible(False)
            
    def obtener_datos(self):
        return {
            "id": self.input_id.text().strip(),
            "nombre": self.input_nombre.text().strip(),
            "fechaNacimiento": self.input_fechaNacimiento.date().toPyDate(),
            "id_especie": self.input_especie.currentData(),
            "id_raza": self.input_raza.currentData(),
            "color": self.input_color.text().strip(),
            "sexo": self.input_sexo.currentData(),  # M / H
            "fechaLlegada": QDate.currentDate().toPyDate(),
            "adoptado": self.input_adoptado.isChecked(),
            "caracteristicas": self.input_caracteristicas.text().strip()
        }
        
    def validar_datos(self, datos):
        if not datos["nombre"]:
            QtWidgets.QMessageBox.warning(self, "Error", "El nombre es obligatorio")
            return False

        if datos["id_raza"] is None:
            QtWidgets.QMessageBox.warning(self, "Error", "Debes seleccionar una raza")
            return False

        if not datos["sexo"]:
            QtWidgets.QMessageBox.warning(self, "Error", "Debes seleccionar el sexo")
            return False

        return True
    
    def insertar_animal(self):
        datos = self.obtener_datos()
        if not self.validar_datos(datos):
            return
        
        db = DataBase()
        conn = db.conectar()

        if conn:
            try:
                cursor = conn.cursor()

                resultado = cursor.callfunc(
                    "funcionesRefugio.insertarAnimal",
                    int,
                    [
                        datos["nombre"],
                        datos["fechaNacimiento"],
                        datos["id_raza"],
                        datos["color"],
                        datos["sexo"],
                        datos["fechaLlegada"],
                        datos["caracteristicas"]
                    ]
                )

                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Animal añadido correctamente")
                    self.parent().cargar_tablaAnimal()
                    self.accept()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo añadir el animal")
                

            except Exception as e:
                print("Error BD:", e)
            finally:
                cursor.close()
                conn.close()
                
    def editar_animal(self):
        datos = self.obtener_datos()

        db = DataBase()
        conn = db.conectar()

        if conn:
            try:
                cursor = conn.cursor()

                # 1. Obtener datos actuales del animal (fallback)
                cursor.execute("SELECT nombre, id_raza, color, sexo, caracteristicas, fechaLlegada, fechaNacimiento, fechaAdopcion FROM Table_Animal WHERE id = :id", {"id": datos["id"]})

                actual = cursor.fetchone()

                if not actual:
                    QtWidgets.QMessageBox.warning(self, "Error", "Animal no encontrado")
                    return

                # 2. Mezclar valores (si viene vacío, usa el actual)
                nombre = datos["nombre"] or actual[0]
                id_raza = datos["id_raza"] or actual[1]
                color = datos["color"] or actual[2]
                sexo = datos["sexo"] or actual[3]
                caracteristicas = datos["caracteristicas"] or actual[4]
                fecha_llegada = actual[5]
                fecha_nacimiento = actual[6]
                fecha_adopcion = actual[7]

                # 3. Llamar a PL/SQL
                resultado = cursor.callfunc(
                    "funcionesRefugio.actualizarAnimal",
                    int,
                    [
                        int(datos["id"]),
                        nombre,
                        fecha_nacimiento,
                        id_raza,
                        color,
                        sexo,
                        fecha_llegada,
                        caracteristicas,
                        fecha_adopcion
                    ]
                )

                # 4. Resultado
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Animal actualizado correctamente")
                    self.parent().cargar_tablaAnimal()
                    self.accept()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo actualizar el animal")

            except Exception as e:
                print("Error:", e)

            finally:
                cursor.close()
                conn.close()
                
    def buscar_animal(self):
        datos = self.obtener_datos()

        db = DataBase()
        conn = db.conectar()

        if conn:
            try:
                cursor = conn.cursor()

                query = "SELECT a.id, a.nombre, a.sexo, TO_CHAR(a.fechaNacimiento, 'DD/MM/YYYY'), a.color, e.nombre_especie, r.nombre_raza, TO_CHAR(a.fechaLlegada, 'DD/MM/YYYY'), TO_CHAR(a.fechaAdopcion, 'DD/MM/YYYY'), a.caracteristicas FROM TABLE_ANIMAL a JOIN Tabla_Razas r ON a.id_raza = r.id_raza JOIN Tabla_Especies e ON r.id_especie = e.id_especie WHERE 1=1"

                parametros = {}
                
                if datos["id"]:
                    query += " AND a.id = :id"
                    parametros["id"] = datos["id"]

                if datos["nombre"]:
                    query += " AND LOWER(a.nombre) LIKE LOWER(:nombre)"
                    parametros["nombre"] = f"%{datos['nombre']}%"
                    
                if datos["id_especie"] is not None:
                    query += " AND r.id_especie = :id_especie"
                    parametros["id_especie"] = datos["id_especie"]

                if datos["id_raza"] is not None:
                    query += " AND r.id_raza = :id_raza"
                    parametros["id_raza"] = datos["id_raza"]

                if datos["sexo"] is not None:
                    query += " AND a.sexo = :sexo"
                    parametros["sexo"] = datos["sexo"]

                if datos["color"]:
                    query += " AND LOWER(a.color) LIKE LOWER(:color)"
                    parametros["color"] = f"%{datos['color']}%"

                if datos["caracteristicas"]:
                    query += """
                        AND LOWER(a.caracteristicas)
                        LIKE LOWER(:caracteristicas)
                    """
                    parametros["caracteristicas"] = f"%{datos['caracteristicas']}%"
                
                if datos["adoptado"]:
                    query += " AND a.fechaAdopcion is NOT NULL"

                cursor.execute(query, parametros)

                filas = cursor.fetchall()

                # RECARGAR TABLA DEL PADRE
                rellenar_tabla(
                    self.parent(),
                    self.tabla_destino,
                    filas
                )

                self.accept()

            except Exception as e:
                print("Error búsqueda:", e)

            finally:
                cursor.close()
                conn.close()
        