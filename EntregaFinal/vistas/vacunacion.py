from PyQt5 import QtWidgets, uic
from datetime import datetime
from vistas.utilidades import rellenar_tabla, cargar_especies
from vistas.popUpAnimales import abrir_animal
from conexion import DataBase

class VacunacionWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/vacunacion.ui", self)
        
        self.cargar_tablaVacunaAnimal()
        self.cargar_tablaVacuna()
        self.cargar_tablaDosis()
                
        self.btn_anadir.clicked.connect(self.abrir_vacunacion)
        self.btn_buscar.clicked.connect(lambda: abrir_animal(self, "buscar", self.tabla_vacunacionAnimales))
        self.btn_suministrar.clicked.connect(self.suministrar_vacuna)
        self.btn_eliminar.clicked.connect(self.borrar_vacuna)
        
        self.tabla_vacunacionAnimales.itemSelectionChanged.connect(self.cargar_tablaDosis)
        
    def abrir_vacunacion(self):
        ventana = DialogoVacunacion(self)
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Adopción guardados")
            
    def cargar_tablaVacuna(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT v.id, v.nombre, v.esEsencial, e.nombre_especie FROM TABLA_VACUNA v JOIN Tabla_Especies e ON v.id_especie = e.id_especie ORDER BY v.id ASC")                

                filas = cursor.fetchall()
                
                rellenar_tabla(self, self.tabla_vacunas, filas)
                self.tabla_vacunas.setColumnHidden(0, True)
                self.tabla_vacunas.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    def cargar_tablaVacunaAnimal(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT a.id, a.nombre, a.sexo, TO_CHAR(a.fechaNacimiento, 'DD/MM/YYYY') AS fecha_nacimiento, a.color, e.nombre_especie AS especie, r.nombre_raza AS raza, TO_CHAR(a.fechaLlegada, 'DD/MM/YYYY') AS fecha_llegada, TO_CHAR(a.fechaAdopcion, 'DD/MM/YYYY') AS fecha_adopcion, a.caracteristicas  FROM TABLE_ANIMAL a JOIN Tabla_Razas r ON a.id_raza = r.id_raza JOIN Tabla_Especies e ON r.id_especie = e.id_especie ORDER BY a.id ASC")
                filas = cursor.fetchall()
                              
                rellenar_tabla(self, self.tabla_vacunacionAnimales, filas)
                self.tabla_vacunacionAnimales.setColumnHidden(0, True)
                self.tabla_vacunacionAnimales.setColumnHidden(4, True)
                self.tabla_vacunacionAnimales.setColumnHidden(7, True)
                self.tabla_vacunacionAnimales.setColumnHidden(9, True)
                self.tabla_vacunacionAnimales.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
    
    def cargar_tablaDosis(self):
        selected = self.tabla_vacunacionAnimales.currentRow()
        if selected == -1:
            return
        
        id_animal = self.tabla_vacunacionAnimales.item(selected, 0).text()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT a.id, DEREF(d.vacuna).nombre, d.fechaAdministracion AS vacuna FROM TABLE_ANIMAL a, TABLE(a.dosis) d WHERE a.id = :id ORDER BY d.fechaAdministracion", {"id": id_animal})
                filas = cursor.fetchall()
                              
                rellenar_tabla(self, self.tabla_dosis, filas)
                self.tabla_dosis.setColumnHidden(0, True)
                self.tabla_dosis.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    def borrar_vacuna(self):
        selected = self.tabla_vacunas.currentRow()
        if selected == -1:
            return
        
        id_vacuna = self.tabla_vacunas.item(selected, 0).text()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                resultado = cursor.callfunc("funcionesRefugio.borrarVacuna", int, [id_vacuna])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Vacuna borrada correctamente")
                    self.cargar_tablaVacuna()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo borrar la vacuna")
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    def suministrar_vacuna(self):
        selected_animal = self.tabla_vacunacionAnimales.currentRow()
        selected_vacuna = self.tabla_vacunas.currentRow()
        if selected_vacuna == -1 or selected_animal == -1:
            return
        
        id_animal = self.tabla_vacunacionAnimales.item(selected_animal, 0).text()
        id_vacuna = self.tabla_vacunas.item(selected_vacuna, 0).text()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                resultado = cursor.callfunc("funcionesRefugio.suministrarDosis", int, [id_animal, id_vacuna, datetime.now()])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Dosis suministrada correctamente")
                    self.cargar_tablaDosis()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo suministrar la dosis")
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                    
            
class DialogoVacunacion(QtWidgets.QDialog):
    def __init__(self, parent = None):
        super().__init__(parent)
        uic.loadUi("vistas/popUpVacuna.ui", self) # Carga tu diseño bonito
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_vacuna.clicked.connect(self.insertar_vacuna)
        
        cargar_especies(self)
        
    def obtener_datos(self):
        return {
            "nombre": self.input_nombre.text().strip(),
            "id_especie": self.input_especie.currentData(),
            "esencial": "Y" if self.input_esencial.isChecked() else "N"
        }
        
    def validar_datos(self, datos):
        if not datos["nombre"]:
            QtWidgets.QMessageBox.warning(self, "Error", "El nombre es obligatorio")
            return False

        if datos["id_especie"] is None:
            QtWidgets.QMessageBox.warning(self, "Error", "Debes seleccionar una especie")
            return False

        if datos["esencial"] not in ("Y", "N"):
            QtWidgets.QMessageBox.warning(self, "Error", "Debes seleccionar si es esencial")
            return False

        return True
    
    def insertar_vacuna(self):
        datos = self.obtener_datos()
        if not self.validar_datos(datos):
            return
        
        db = DataBase()
        conn = db.conectar()

        if conn:
            try:
                cursor = conn.cursor()

                resultado = cursor.callfunc(
                    "funcionesRefugio.crearVacuna",
                    int,
                    [
                        datos["nombre"],
                        datos["esencial"],
                        datos["id_especie"]
                        
                    ]
                )

                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Vacuna añadida correctamente")
                    self.parent().cargar_tablaVacuna()
                    self.accept()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo añadir la vacuna")
                

            except Exception as e:
                print("Error BD:", e)
            finally:
                cursor.close()
                conn.close()
        