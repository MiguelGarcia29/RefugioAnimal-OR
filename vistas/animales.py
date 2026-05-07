from PyQt5 import QtWidgets, uic
from vistas.utilidades import rellenar_tabla
from conexion import DataBase
from vistas.popUpAnimales import abrir_animal


class AnimalesWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/animales.ui", self)
            
        # Abrir el popUp mediante funcion de utilidades
        self.btn_buscar.clicked.connect(lambda: abrir_animal(self, "buscar", self.tabla_animales))
        self.btn_anadir.clicked.connect(lambda: abrir_animal(self, "añadir"))
        self.btn_editar.clicked.connect(lambda: abrir_animal(self, "editar"))
        self.btn_eliminar.clicked.connect(self.borrar_animal)
        
    def cargar_tablaAnimal(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                # Consulta para traer los datos
                cursor.execute("SELECT a.id, a.nombre, a.sexo, TO_CHAR(a.fechaNacimiento, 'DD/MM/YYYY') AS fecha_nacimiento, a.color, e.nombre_especie AS especie, r.nombre_raza AS raza, TO_CHAR(a.fechaLlegada, 'DD/MM/YYYY') AS fecha_llegada, TO_CHAR(a.fechaAdopcion, 'DD/MM/YYYY') AS fecha_adopcion, a.caracteristicas FROM TABLE_ANIMAL a JOIN Tabla_Razas r ON a.id_raza = r.id_raza JOIN Tabla_Especies e ON r.id_especie = e.id_especie ORDER BY a.id ASC")
                filas = cursor.fetchall()
                
                rellenar_tabla(self, self.tabla_animales, filas)
                self.tabla_animales.setColumnHidden(0, True)
                self.tabla_animales.horizontalHeader().setStretchLastSection(True)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    def borrar_animal(self):
        selected = self.tabla_animales.currentRow()
        if selected == -1:
            return
        
        id_animal = self.tabla_animales.item(selected, 0).text()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                resultado = cursor.callfunc("funcionesRefugio.borrarAnimal", int, [id_animal])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Animal borrado correctamente")
                    self.cargar_tablaAnimal()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo borrar el animal")
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()