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
        
        self.tabla_vacunacionAnimales.itemSelectionChanged.connect(self.cargar_tablaDosis)
        
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
                cursor.execute("SELECT a.id, a.nombre, a.sexo, e.nombre_especie AS especie, r.nombre_raza AS raza, TO_CHAR(a.fechaNacimiento, 'DD/MM/YYYY') AS fecha_nacimiento, TO_CHAR(a.fechaAdopcion, 'DD/MM/YYYY') AS fecha_adopcion FROM TABLE_ANIMAL a JOIN Tabla_Razas r ON a.id_raza = r.id_raza JOIN Tabla_Especies e ON r.id_especie = e.id_especie ORDER BY a.id ASC")
                filas = cursor.fetchall()
                              
                rellenar_tabla(self, self.tabla_vacunacionAnimales, filas)
                self.tabla_vacunacionAnimales.setColumnHidden(0, True)
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
            
class DialogoVacunacion(QtWidgets.QDialog):
    def __init__(self):
        super().__init__()
        uic.loadUi("vistas/popUpVacuna.ui", self) # Carga tu diseño bonito
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_vacuna.clicked.connect(self.accept)
        
        # Hacer que el primer elemento no se pueda elegir una vez abierto
        self.input_especie.model().item(0).setEnabled(False) 
        self.input_especie.setCurrentIndex(0)