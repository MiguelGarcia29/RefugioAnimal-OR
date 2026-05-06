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
        # self.cargar_especie()
        
        self.input_raza.model().item(0).setEnabled(False) 
        self.input_raza.setCurrentIndex(0)
        # self.cargar_raza()
        
        self.input_sexo.model().item(0).setEnabled(False) 
        self.input_sexo.setCurrentIndex(0)
        
    def cargar_tablaAdopcion(self):
        db = DataBase()
        conn  = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT a.id, a.nombre, a.sexo, TO_CHAR(a.fechaNacimiento, 'DD/MM/YYYY') AS fecha_nacimiento, a.color, e.nombre_especie AS especie, r.nombre_raza AS raza, TO_CHAR(a.fechaLlegada, 'DD/MM/YYYY') AS fecha_llegada, TO_CHAR(a.fechaAdopcion, 'DD/MM/YYYY') AS fecha_adopcion, a.caracteristicas FROM TABLE_ANIMAL a JOIN Tabla_Razas r ON a.id_raza = r.id_raza JOIN Tabla_Especies e ON r.id_especie = e.id_especie ORDER BY a.id ASC")                
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
                
    # def cargar_especie(self):
    #     db = DataBase()
    #     conn  = db.conectar()
    #     cursor = None
        
    #     if conn:
    #         try:
    #             cursor = conn.cursor()
    #             cursor.execute("SELECT id, nombre FROM especies")

    #             for id_, nombre in cursor.fetchall():
    #                 self.input_especie.addItem(nombre, id_)
                    
    #         except Exception as e:
    #             print(f"Error al cargar datos: {e}")
    #         finally:
    #             cursor.close()
    #             conn.close()        
    
    # def cargar_razas(self):    
    #     db = DataBase()
    #     conn  = db.conectar()
    #     cursor = None
        
    #     if conn:
    #         try:
    #             self.input_raza.clear()
    #             id_especie = self.input_especie.currentData()
    #             cursor.execute("SELECT nombre FROM razas WHERE id_especie = ?", (id_especie,))

    #             for (nombre,) in cursor.fetchall():
    #                 self.input_raza.addItem(nombre)
    #         except Exception as e:
    #             print(f"Error al cargar datos: {e}")
    #         finally:
    #             cursor.close()
    #             conn.close() 