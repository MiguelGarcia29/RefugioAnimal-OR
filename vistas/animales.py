import sys
from PyQt5 import QtWidgets, uic
from vistas.utilidades import abrir_animal, rellenar_tabla
from conexion import DataBase

class AnimalesWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/animales.ui", self)
            
        # Abrir el popUp mediante funcion de utilidades
        self.btn_buscar.clicked.connect(lambda: abrir_animal(self, "buscar"))
        self.btn_anadir.clicked.connect(lambda: abrir_animal(self, "añadir"))
        self.btn_editar.clicked.connect(lambda: abrir_animal(self, "editar"))
        
    def cargar_tablaAnimal(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                # Consulta para traer los datos
                cursor.execute("SELECT ID, NOMBRE, SEXO, TO_CHAR(FECHANACIMIENTO, 'DD/MM/YYYY'), COLOR, ESPECIE, RAZA, TO_CHAR(FECHALLEGADA, 'DD/MM/YYYY'), TO_CHAR(FECHAADOPCION, 'DD/MM/YYYY'), CARACTERISTICAS FROM TABLE_ANIMAL ORDER BY ID ASC")
                filas = cursor.fetchall()
                
                rellenar_tabla(self, self.tabla_animales, filas)
                self.tabla_animales.setColumnHidden(0, True)
                self.tabla_animales.horizontalHeader().setStretchLastSection(True)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()