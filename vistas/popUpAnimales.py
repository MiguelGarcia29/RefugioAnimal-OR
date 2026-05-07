from PyQt5 import QtWidgets, uic
from PyQt5.QtCore import QDate
from vistas.utilidades import cargar_razas, cargar_especies, on_raza_changed
from conexion import DataBase

def abrir_animal(self, modo):
    ventana = DialogoAnimal(modo, self)
    if ventana.exec_() == QtWidgets.QDialog.Accepted:
        print("Datos de Animal guardados")

class DialogoAnimal(QtWidgets.QDialog):
    def __init__(self, modo = "añadir", parent = None):
        super().__init__(parent)
        uic.loadUi("vistas/popUpAnimales.ui", self) # Carga tu diseño bonito
        
        self.modo = modo
        self.configurar_interfaz()
        
        # Cargamos las razas y especies en los selectores
        cargar_especies(self)
        cargar_razas(self)
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
            # En editar, el ID se ve pero no se toca
            self.input_id.setVisible(False)
            self.input_adoptado.setVisible(False)
            self.btn_animal.setText("Editar")

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Animal")
            # En buscar, quizás solo queremos ver el nombre y la especie
            self.btn_animal.setText("Buscar")
            
    def obtener_datos(self):
        return {
            "nombre": self.input_nombre.text().strip(),
            "fechaNacimiento": self.input_fechaNacimiento.date().toPyDate(),
            "id_raza": self.input_raza.currentData(),
            "color": self.input_color.text().strip(),
            "sexo": self.input_sexo.currentData(),  # M / H
            "fechaLlegada": QDate.currentDate().toPyDate(),
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