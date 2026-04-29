import sys
from PyQt5 import QtWidgets, uic
from PyQt5.QtCore import QDate
from conexion import DataBase
from vistas.utilidades import rellenar_tabla

class SociosWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/socios.ui", self)
                
        self.btn_buscar.clicked.connect(lambda: self.abrir_socio("buscar"))
        self.btn_anadir.clicked.connect(lambda: self.abrir_socio("añadir"))
        self.btn_editar.clicked.connect(lambda: self.abrir_socio("editar"))
        
    def abrir_socio(self, modo):
        ventana = DialogoSocio(modo)
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Socio guardados")
            
    def cargar_tablaSocios(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT ID, NOMBRE, DNI, DIRECCION, TELEFONO, TO_CHAR(FECHANACIMIENTO, 'DD/MM/YY') FROM TABLA_SOCIO ORDER BY ID ASC")
                filas = cursor.fetchall()
    
                rellenar_tabla(self, self.tabla_socios, filas)            
                self.tabla_socios.setColumnHidden(0, True)
                self.tabla_socios.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
            
class DialogoSocio(QtWidgets.QDialog):
    def __init__(self, modo = "añadir"):
        super().__init__()
        uic.loadUi("vistas/popUpSocios.ui", self) # Carga tu diseño bonito
        
        self.modo = modo
        self.configurar_interfaz()
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_socio.clicked.connect(self.accept)
    
        # Fijar en hoy la fecha de los calendarios
        self.input_fechaNacimiento.calendarWidget().setSelectedDate(QDate.currentDate())
        
    def configurar_interfaz(self):
        if self.modo == "añadir":
            self.titulo.setText("Alta Socio")
            # El ID suele ser autoincremental, así que lo ocultamos
            self.label_id.setVisible(False)
            self.input_id.setVisible(False)
            self.btn_socio.setText("Dar de Alta") 

        elif self.modo == "editar":
            self.titulo.setText("Modificar Socio")
            # En editar, el ID se ve pero no se toca
            self.label_id.setVisible(False)
            self.input_id.setVisible(False)
            self.btn_socio.setText("Editar")

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Socio")
            # En buscar, quizás solo queremos ver el nombre y la especie
            self.btn_socio.setText("Buscar")