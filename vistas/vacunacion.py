from PyQt5 import QtWidgets, uic
from vistas.utilidades import abrir_animal, rellenar_tabla
from conexion import DataBase

class VacunacionWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/vacunacion.ui", self)
                
        self.btn_anadir.clicked.connect(self.abrir_vacunacion)
        self.btn_buscar.clicked.connect(lambda: abrir_animal(self, "buscar"))
        
    def abrir_vacunacion(self):
        ventana = DialogoVacunacion()
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Adopción guardados")
            
    def cargar_tablaVacuna(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT ID, NOMBRE, ESESENCIAL FROM TABLA_VACUNA ORDER BY ID ASC")
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
                cursor.execute("SELECT ID, NOMBRE, SEXO, ESPECIE, RAZA, TO_CHAR(FECHANACIMIENTO, 'DD/MM/YY'), TO_CHAR(FECHAADOPCION, 'DD/MM/YY') FROM TABLE_ANIMAL WHERE FECHAADOPCION IS NULL ORDER BY ID ASC")
                filas = cursor.fetchall()
                              
                rellenar_tabla(self, self.tabla_vacunacionAnimales, filas)
                self.tabla_vacunacionAnimales.setColumnHidden(6, True)
                self.tabla_vacunacionAnimales.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
            
class DialogoVacunacion(QtWidgets.QDialog):
    def __init__(self):
        super().__init__()
        uic.loadUi("vistas/popUpVacuna.ui", self) # Carga tu diseño bonito
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_vacuna.clicked.connect(self.accept)
        
        # Hacer que el primer elemento no se pueda elegir una vez abierto
        self.input_especie.model().item(0).setEnabled(False) 
        self.input_especie.setCurrentIndex(0)