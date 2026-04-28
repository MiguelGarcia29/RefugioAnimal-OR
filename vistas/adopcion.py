import sys
from PyQt5 import QtWidgets, uic
from conexion import DataBase
from vistas.utilidades import rellenar_tabla

class AdopcionWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/adopcion.ui", self)
                
        self.input_especie.model().item(0).setEnabled(False) 
        self.input_especie.setCurrentIndex(0) # Aseguramos que se vea el placeholder
        
        self.input_raza.model().item(0).setEnabled(False) 
        self.input_raza.setCurrentIndex(0)
        
        self.input_sexo.model().item(0).setEnabled(False) 
        self.input_sexo.setCurrentIndex(0)
        
    def cargar_tablaAdopcion(self):
        db = DataBase()
        conn  = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT ID, NOMBRE, SEXO, TO_CHAR(FECHANACIMIENTO, 'DD/MM/YYYY'), COLOR, ESPECIE, RAZA, TO_CHAR(FECHALLEGADA, 'DD/MM/YYYY'), TO_CHAR(FECHAADOPCION, 'DD/MM/YYYY'), CARACTERISTICAS FROM TABLE_ANIMAL WHERE FECHAADOPCION IS NULL ORDER BY ID ASC")
                filas = cursor.fetchall()
                
                rellenar_tabla(self, self.tabla_adopcion, filas)
                self.tabla_adopcion.setColumnHidden(0, True)
                self.tabla_adopcion.setColumnHidden(8, True)
                self.tabla_adopcion.horizontalHeader().setStretchLastSection(True)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()