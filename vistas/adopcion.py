from PyQt5 import QtWidgets, uic
from conexion import DataBase
from vistas.utilidades import rellenar_tabla, cargar_especies, cargar_razas, on_raza_changed
from vistas.popUpAnimales import abrir_animal

class AdopcionWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/adopcion.ui", self)
                
        self.cargar_tablaAdopcion()
                
        self.btn_adoptar.clicked.connect(self.adoptar_animal)
        self.btn_buscar.clicked.connect(lambda: abrir_animal(self, "buscar", self.tabla_adopcion))
        
    def cargar_tablaAdopcion(self):
        db = DataBase()
        conn  = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT a.id, a.nombre, a.sexo, TO_CHAR(a.fechaNacimiento, 'DD/MM/YYYY') AS fecha_nacimiento, a.color, e.nombre_especie AS especie, r.nombre_raza AS raza, TO_CHAR(a.fechaLlegada, 'DD/MM/YYYY') AS fecha_llegada, TO_CHAR(a.fechaAdopcion, 'DD/MM/YYYY') AS fecha_adopcion, a.caracteristicas FROM TABLE_ANIMAL a JOIN Tabla_Razas r ON a.id_raza = r.id_raza JOIN Tabla_Especies e ON r.id_especie = e.id_especie WHERE a.fechaAdopcion IS NULL ORDER BY a.id ASC")                
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
                
    def adoptar_animal(self):
        selected = self.tabla_adopcion.currentRow()
        if selected == -1:
            return
        
        id_selected = self.tabla_adopcion.item(selected, 0).text()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        if conn:
            try:
                cursor = conn.cursor()
                resultado = cursor.callfunc("funcionesRefugio.adoptarAnimal", int, [id_selected])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Animal adoptado correctamente")
                    self.cargar_tablaAdopcion()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo adoptar al animal")
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()