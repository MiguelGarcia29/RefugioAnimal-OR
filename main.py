import sys
from PyQt5 import QtWidgets, uic, QtCore
from PyQt5.QtGui import QColor
from PyQt5.QtCore import QDate
from conexion import DataBase

# Definimos el color gris oscuro
color_placeholder = QColor("#333333")

class MiAplicacion(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz principal
        uic.loadUi("Interfaz/diseno.ui", self)
        
        # 2. Configuración inicial
        # Supongamos que tu QStackedWidget se llama 'stackedWidget'
        # Empezamos en la página de bienvenida (índice 0)
        self.stackedWidget.setCurrentIndex(0)
        
        # 3. Conectamos los botones del menú lateral
        # Reemplaza 'btn_animales', 'btn_socios', etc., por los nombres que pusiste en Designer
        self.btn_animales.clicked.connect(lambda: self.stackedWidget.setCurrentIndex(0))
        self.btn_socios.clicked.connect(lambda: self.stackedWidget.setCurrentIndex(1))
        self.btn_adopcion.clicked.connect(lambda: self.stackedWidget.setCurrentIndex(2))
        self.btn_vacunacion.clicked.connect(lambda: self.stackedWidget.setCurrentIndex(3))
        
        self.btn_buscarAnimales.clicked.connect(lambda: self.abrir_animal("buscar"))
        self.btn_anadirAnimales.clicked.connect(lambda: self.abrir_animal("añadir"))
        self.btn_editarAnimales.clicked.connect(lambda: self.abrir_animal("editar"))
        self.btn_buscarVacunacionAnimales.clicked.connect(lambda: self.abrir_animal("buscar"))
        
        self.btn_buscarSocios.clicked.connect(lambda: self.abrir_socio("buscar"))
        self.btn_altaSocios.clicked.connect(lambda: self.abrir_socio("añadir"))
        self.btn_modificarSocios.clicked.connect(lambda: self.abrir_socio("editar"))
        
        self.btn_anadirVacuna.clicked.connect(self.abrir_vacunacion)
        
        # Hacer que el primer elemento no se pueda elegir una vez abierto
        self.input_especie.model().item(0).setEnabled(False) 
        self.input_especie.setCurrentIndex(0) # Aseguramos que se vea el placeholder
        
        self.input_raza.model().item(0).setEnabled(False) 
        self.input_raza.setCurrentIndex(0)
        
        self.input_sexo.model().item(0).setEnabled(False) 
        self.input_sexo.setCurrentIndex(0)
        
        self.cargar_todo()
        
    # Funciones de apertura
    def abrir_animal(self, modo):
        ventana = DialogoAnimal(modo)
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Animal guardados")

    def abrir_socio(self, modo):
        ventana = DialogoSocio(modo)
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Socio guardados")

    def abrir_vacunacion(self):
        ventana = DialogoVacunacion()
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Adopción guardados")
            
            
    def cargar_todo(self):
        self.cargar_tablaAnimal()
        # self.cargar_tablaSocios()
        self.cargar_tablaAdopcion()
        self.cargar_tablaVacuna()
        
        self.cargar_tablaVacunaAnimal()
    
    
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
                
                self.rellenar_tabla(self.tabla_animales, filas)
                self.tabla_animales.setColumnHidden(0, True)
                self.tabla_animales.horizontalHeader().setStretchLastSection(True)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    # def cargar_tablaSocios(self):
    #     db = DataBase()
    #     conn = db.conectar
    #     cursor = None
        
    #     if conn:
    #         try:
    #             cursor = conn.cursor()
    #             cursor.execute("SELECT ID, NOMBRE, APELLIDOS, TO_CHAR(FECHANACIMIENTO, 'DD/MM/YY), CUOTASFALTANTES, TO_CHAR(FECHAINSCRIPCION, 'DD/MM/YY') FROM TABLE_SOCIOS ORDER BY ID ASC")
    #             filas = cursor.fetchall()
    #             self.rellenar_tabla(self.tabla_socios, filas)
                
    #             self.tabla_animales.setColumnHidden(0, True)
    #             self.tabla_socios.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
    #         except Exception as e:
    #             print(f"Error al cargar datos: {e}")
    #         finally:
    #             cursor.close()
    #             conn.close()
    
    def cargar_tablaAdopcion(self):
        db = DataBase()
        conn  = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT ID, NOMBRE, SEXO, TO_CHAR(FECHANACIMIENTO, 'DD/MM/YYYY'), COLOR, ESPECIE, RAZA, TO_CHAR(FECHALLEGADA, 'DD/MM/YYYY'), TO_CHAR(FECHAADOPCION, 'DD/MM/YYYY'), CARACTERISTICAS FROM TABLE_ANIMAL WHERE FECHAADOPCION IS NULL ORDER BY ID ASC")
                filas = cursor.fetchall()
                
                self.rellenar_tabla(self.tabla_adopcion, filas)
                self.tabla_adopcion.setColumnHidden(0, True)
                self.tabla_adopcion.setColumnHidden(8, True)
                self.tabla_adopcion.horizontalHeader().setStretchLastSection(True)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
    
    def cargar_tablaVacuna(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT ID, NOMBRE, ESESENCIAL FROM TABLA_VACUNA ORDER BY ID ASC")
                filas = cursor.fetchall()
                
                self.rellenar_tabla(self.tabla_vacunas, filas)
                self.tabla_vacunas.setColumnHidden(0, True)
                self.tabla_socios.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
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
                              
                self.rellenar_tabla(self.tabla_vacunacionAnimales, filas)
                self.tabla_vacunacionAnimales.setColumnHidden(6, True)
                self.tabla_socios.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
                
    def rellenar_tabla(self, qtable_widget, datos):
        qtable_widget.setRowCount(0)
        if not datos:
            return

        qtable_widget.setColumnCount(len(datos[0]))
        
        for row_idx, row_data in enumerate(datos):
            qtable_widget.insertRow(row_idx)
            for col_idx, value in enumerate(row_data):
                item = QtWidgets.QTableWidgetItem(str(value) if value is not None else "")
                qtable_widget.setItem(row_idx, col_idx, item)
                
class DialogoAnimal(QtWidgets.QDialog):
    def __init__(self, modo = "añadir"):
        super().__init__()
        uic.loadUi("Interfaz/popUpAnimales.ui", self) # Carga tu diseño bonito
        
        self.modo = modo
        self.configurar_interfaz()
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_animal.clicked.connect(self.validar_y_cerrar)
        
        # Hacer que el primer elemento no se pueda elegir una vez abierto
        self.input_especieAnimal.model().item(0).setEnabled(False) 
        self.input_especieAnimal.setCurrentIndex(0) # Aseguramos que se vea el placeholder
        
        self.input_razaAnimal.model().item(0).setEnabled(False) 
        self.input_razaAnimal.setCurrentIndex(0)
        
        self.input_sexoAnimal.model().item(0).setEnabled(False) 
        self.input_sexoAnimal.setCurrentIndex(0)
        
        # Fijar en hoy la fecha de los calendarios
        self.input_fechaNacimientoAnimal.calendarWidget().setSelectedDate(QDate.currentDate())
        self.input_fechaAdopcionAnimal.calendarWidget().setSelectedDate(QDate.currentDate())

    def validar_y_cerrar(self):
        self.accept() # Cierra el pop-up devolviendo 'Accepted'
        
    def configurar_interfaz(self):
        if self.modo == "añadir":
            self.titulo.setText("Añadir Animal")
            # El ID suele ser autoincremental, así que lo ocultamos
            self.input_idAnimal.setVisible(False)
            self.input_fechaAdopcionAnimal.setVisible(False)
            self.label_adopcion.setVisible(False)
            self.input_adoptadoAnimal.setVisible(False)
            self.btn_animal.setText("Añadir") 

        elif self.modo == "editar":
            self.titulo.setText("Editar Animal")
            # En editar, el ID se ve pero no se toca
            self.input_idAnimal.setVisible(False)
            self.input_adoptadoAnimal.setVisible(False)
            self.btn_animal.setText("Editar")

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Animal")
            # En buscar, quizás solo queremos ver el nombre y la especie
            self.btn_animal.setText("Buscar")
        
class DialogoSocio(QtWidgets.QDialog):
    def __init__(self, modo = "añadir"):
        super().__init__()
        uic.loadUi("Interfaz/popUpSocios.ui", self) # Carga tu diseño bonito
        
        self.modo = modo
        self.configurar_interfaz()
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_socio.clicked.connect(self.validar_y_cerrar)
    
        # Fijar en hoy la fecha de los calendarios
        self.input_fechaNacimientoSocio.calendarWidget().setSelectedDate(QDate.currentDate())

    def validar_y_cerrar(self):
        self.accept() # Cierra el pop-up devolviendo 'Accepted'
        
    def configurar_interfaz(self):
        if self.modo == "añadir":
            self.titulo.setText("Alta Socio")
            # El ID suele ser autoincremental, así que lo ocultamos
            self.label_idSocio.setVisible(False)
            self.input_idSocio.setVisible(False)
            self.btn_socio.setText("Dar de Alta") 

        elif self.modo == "editar":
            self.titulo.setText("Modificar Socio")
            # En editar, el ID se ve pero no se toca
            self.label_idSocio.setVisible(False)
            self.input_idSocio.setVisible(False)
            self.btn_socio.setText("Editar")

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Socio")
            # En buscar, quizás solo queremos ver el nombre y la especie
            self.btn_socio.setText("Buscar")
        
class DialogoVacunacion(QtWidgets.QDialog):
    def __init__(self):
        super().__init__()
        uic.loadUi("Interfaz/popUpVacuna.ui", self) # Carga tu diseño bonito
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_vacuna.clicked.connect(self.validar_y_cerrar)
        
        # Hacer que el primer elemento no se pueda elegir una vez abierto
        self.input_especieVacuna.model().item(0).setEnabled(False) 
        self.input_especieVacuna.setCurrentIndex(0)

    def validar_y_cerrar(self):
        self.accept() # Cierra el pop-up devolviendo 'Accepted'

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    ventana = MiAplicacion()
    ventana.show()
    sys.exit(app.exec_())