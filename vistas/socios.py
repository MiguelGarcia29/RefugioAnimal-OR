from PyQt5 import QtWidgets, uic
from PyQt5.QtCore import QDate
from conexion import DataBase
from vistas.utilidades import rellenar_tabla
import recursos_rc


class SociosWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # 1. Cargamos la interfaz
        uic.loadUi("vistas/socios.ui", self)
        
        self.cargar_tablaSocios()
        self.cargar_tablaCuotas()
        self.tabla_socios.itemSelectionChanged.connect(self.cargar_tablaCuotas)
                
        self.btn_buscar.clicked.connect(lambda: self.abrir_socio("buscar"))
        self.btn_anadir.clicked.connect(lambda: self.abrir_socio("añadir"))
        self.btn_nuevaCuota.clicked.connect(self.abrir_cuota)
        self.btn_pagarCuota.clicked.connect(self.pagar_cuota)
        self.btn_eliminar.clicked.connect(self.borrar_socio)
        
    def abrir_socio(self, modo):
        ventana = DialogoSocio(modo, self)
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Socio guardados")
            
    def abrir_cuota(self):
        ventana = DialogoCuota(self)
        if ventana.exec_() == QtWidgets.QDialog.Accepted:
            print("Datos de Cuota guardados")
            
    def cargar_tablaSocios(self):
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT S.ID, S.NOMBRE, S.DNI, S.DIRECCION, S.TELEFONO, TO_CHAR(S.FECHANACIMIENTO, 'DD/MM/YY'), COUNT(CASE WHEN c.pagada = 'N' THEN 1 END) FROM TABLA_SOCIO s LEFT JOIN TABLE(s.cuotas) c ON 1 = 1 GROUP BY S.ID, S.NOMBRE, S.DNI, S.DIRECCION, S.TELEFONO, S.FECHANACIMIENTO ORDER BY S.ID ASC")
                filas = cursor.fetchall()
    
                rellenar_tabla(self, self.tabla_socios, filas)            
                self.tabla_socios.setColumnHidden(0, True)
                self.tabla_socios.setColumnWidth(1, 250)
                self.tabla_socios.setColumnWidth(3, 400)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    def cargar_tablaCuotas(self):
        selected = self.tabla_socios.currentRow()
        if selected == -1:
            return
        
        id_socio = self.tabla_socios.item(selected, 0).text()
        db = DataBase()
        conn = db.conectar()
        cursor = None
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute("SELECT q.ejercicio AS ejercicio, q.importe AS importe, c.pagada AS estado FROM Tabla_Socio s, TABLE(s.cuotas) c, Tabla_InfoCuota q WHERE REF(q) = c.cuotaPagada AND s.id = :id ORDER BY q.ejercicio", {"id": id_socio})
                filas = cursor.fetchall()
                              
                rellenar_tabla(self, self.tabla_cuotas, filas)
                self.tabla_cuotas.horizontalHeader().setSectionResizeMode(QtWidgets.QHeaderView.Stretch)
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
                
    def borrar_socio(self):
        selected = self.tabla_socios.currentRow()
        if selected == -1:
            return
        
        id_socio = self.tabla_socios.item(selected, 0).text()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                resultado = cursor.callfunc("funcionesRefugio.borrarSocio", int, [id_socio])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Socio borrado correctamente")
                    self.cargar_tablaSocios()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo borrar el socio")
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
    
    def pagar_cuota(self):
        selected_socio = self.tabla_socios.currentRow()
        selected_cuota = self.tabla_cuotas.currentRow()
        if selected_socio == -1 or selected_cuota == -1:
            return
        
        id_socio = self.tabla_socios.item(selected_socio, 0).text()
        id_cuota = self.tabla_cuotas.item(selected_cuota, 0).text()

        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                resultado = cursor.callfunc("funcionesRefugio.asignarCuotaSocio", int, [id_socio, id_cuota, 'S'])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Cuota pagada correctamente")
                    self.cargar_tablaSocios()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo pagar la cuota")
                
            except Exception as e:
                print(f"Error al cargar datos: {e}")
            finally:
                cursor.close()
                conn.close()
        
            
class DialogoSocio(QtWidgets.QDialog):
    def __init__(self, modo = "añadir", parent = None):
        super().__init__(parent)
        uic.loadUi("vistas/popUpSocios.ui", self) # Carga tu diseño bonito
        
        self.modo = modo
        self.configurar_interfaz()
            
        # Fijar en hoy la fecha de los calendarios
        self.input_fechaNacimiento.calendarWidget().setSelectedDate(QDate.currentDate())
        
    def configurar_interfaz(self):
        if self.modo == "añadir":
            self.titulo.setText("Alta Socio")
            # El ID suele ser autoincremental, así que lo ocultamos
            self.label_id.setVisible(False)
            self.input_id.setVisible(False)
            self.btn_socio.setText("Dar de Alta") 
            self.btn_socio.clicked.connect(self.insertar_socio)

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Socio")
            self.btn_socio.setText("Buscar")
            self.label_fechaNacimiento.setVisible(False)
            self.input_fechaNacimiento.setVisible(False)
            self.btn_socio.clicked.connect(self.buscar_socio)
            
    def obtener_datos(self):
        return {
            "id": self.input_id.text().strip(),
            "nombre": self.input_nombre.text().strip(),
            "dni": self.input_dni.text().strip(),
            "direccion": self.input_direccion.text().strip(),
            "telefono": self.input_telefono.text().strip(),
            "fechaNacimiento": self.input_fechaNacimiento.date().toPyDate(),
        }
        
    def validar_datos(self, datos):
        if not datos["nombre"]:
            QtWidgets.QMessageBox.warning(self, "Error", "El nombre es obligatorio")
            return False

        if not datos["dni"]:
            QtWidgets.QMessageBox.warning(self, "Error", "El nombre es obligatorio")
            return False
        
        if not datos["direccion"]:
            QtWidgets.QMessageBox.warning(self, "Error", "El nombre es obligatorio")
            return False
        
        if not datos["telefono"]:
            QtWidgets.QMessageBox.warning(self, "Error", "El nombre es obligatorio")
            return False

        return True
    
    def insertar_socio(self):
        datos = self.obtener_datos()
        if not self.validar_datos(datos):
            return
        
        db = DataBase()
        conn = db.conectar()

        if conn:
            try:
                cursor = conn.cursor()

                resultado = cursor.callfunc(
                    "funcionesRefugio.insertarSocio",
                    int,
                    [
                        datos["nombre"],
                        datos["fechaNacimiento"],
                        datos["dni"],
                        datos["direccion"],
                        datos["telefono"],
                    ]
                )

                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Socio añadido correctamente")
                    self.parent().cargar_tablaSocios()
                    self.accept()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo añadir el socio")
                

            except Exception as e:
                print("Error BD:", e)
            finally:
                cursor.close()
                conn.close()
                
    def buscar_socio(self):
        datos = self.obtener_datos()
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        if conn:
            try:
                
                cursor = conn.cursor()
                query = "SELECT S.ID, S.NOMBRE, S.DNI, S.DIRECCION, S.TELEFONO, TO_CHAR(S.FECHANACIMIENTO, 'DD/MM/YY'), COUNT(CASE WHEN c.pagada = 'N' THEN 1 END) AS cuotas_impagadas FROM TABLA_SOCIO s LEFT JOIN TABLE(s.cuotas) c ON 1 = 1 WHERE 1=1"
                
                parametros = {}
                
                if datos["id"]:
                    query += " AND S.ID = :id"
                    parametros["id"] = datos["id"]
                
                if datos["nombre"]:
                    query += " AND LOWER(s.nombre) LIKE LOWER(:nombre)"
                    parametros["nombre"] = f"%{datos['nombre']}%"
                    
                if datos["dni"]:
                    query += " AND s.dni = :dni"
                    parametros["dni"] = datos["dni"]
                    
                if datos["direccion"]:
                    query += " AND LOWER(s.direccion) LIKE LOWER(:direccion)"
                    parametros["direccion"] = f"%{datos['direccion']}%"     
                    
                if datos["telefono"]:
                    query += " AND s.telefono = :telefono"
                    parametros["telefono"] = datos["telefono"]      
                    
                # Agrupacion
                query += " GROUP BY S.ID, S.NOMBRE, S.DNI, S.DIRECCION, S.TELEFONO, S.FECHANACIMIENTO"
                
                cursor.execute(query, parametros)
                
                filas = cursor.fetchall()

                # RECARGAR TABLA DEL PADRE
                rellenar_tabla(
                    self.parent(),
                    self.parent().tabla_socios,
                    filas
                )

                self.accept()

            except Exception as e:
                print("Error búsqueda:", e)

            finally:
                cursor.close()
                conn.close()      
                
class DialogoCuota(QtWidgets.QDialog):
    def __init__(self, parent = None):
        super().__init__(parent)
        uic.loadUi("vistas/popUpCuota.ui", self)
        
        self.btn_cuota.clicked.connect(self.crear_cuota)
        
    def crear_cuota(self):
        importe = self.input_importe.text().strip()
        ejercicio = self.input_ejercicio.text().strip()
        
        if importe is None or ejercicio is None:
            return
        
        db = DataBase()
        conn = db.conectar()
        cursor = None
        
        if conn:
            try:
                cursor = conn.cursor()
                
                resultado = cursor.callfunc("funcionesRefugio.insertarCuota", int, [ejercicio, importe])
                
                if resultado == 0:
                    QtWidgets.QMessageBox.information(self, "Éxito", "Cuota añadida correctamente")
                    self.parent().cargar_tablaSocios()
                    self.accept()
                else:
                    QtWidgets.QMessageBox.critical(self, "Error", "No se pudo añadir la cuota")
                

            except Exception as e:
                print("Error BD:", e)
            finally:
                cursor.close()
                conn.close()