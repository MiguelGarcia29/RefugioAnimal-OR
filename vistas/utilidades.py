from PyQt5 import QtWidgets, uic
from PyQt5.QtCore import QDate
import recursos_rc

def abrir_animal(self, modo):
    ventana = DialogoAnimal(modo)
    if ventana.exec_() == QtWidgets.QDialog.Accepted:
        print("Datos de Animal guardados")
        
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
        uic.loadUi("vistas/popUpAnimales.ui", self) # Carga tu diseño bonito
        
        self.modo = modo
        self.configurar_interfaz()
        
        # Conectamos el botón confirmar del propio pop-up
        self.btn_animal.clicked.connect(self.accept)
        
        # Hacer que el primer elemento no se pueda elegir una vez abierto
        self.input_especie.model().item(0).setEnabled(False) 
        self.input_especie.setCurrentIndex(0) # Aseguramos que se vea el placeholder
        
        self.input_raza.model().item(0).setEnabled(False) 
        self.input_raza.setCurrentIndex(0)
        
        self.input_sexo.model().item(0).setEnabled(False) 
        self.input_sexo.setCurrentIndex(0)
        
        # Fijar en hoy la fecha de los calendarios
        self.input_fechaNacimiento.calendarWidget().setSelectedDate(QDate.currentDate())
        self.input_fechaAdopcion.calendarWidget().setSelectedDate(QDate.currentDate())
        
    def configurar_interfaz(self):
        if self.modo == "añadir":
            self.titulo.setText("Añadir Animal")
            # El ID suele ser autoincremental, así que lo ocultamos
            self.input_id.setVisible(False)
            self.input_fechaAdopcion.setVisible(False)
            self.label_adopcion.setVisible(False)
            self.input_adoptado.setVisible(False)
            self.btn_animal.setText("Añadir") 

        elif self.modo == "editar":
            self.titulo.setText("Editar Animal")
            # En editar, el ID se ve pero no se toca
            self.input_id.setVisible(False)
            self.input_adoptado.setVisible(False)
            self.btn_animal.setText("Editar")

        elif self.modo == "buscar":
            self.titulo.setText("Buscar Animal")
            # En buscar, quizás solo queremos ver el nombre y la especie
            self.btn_animal.setText("Buscar")
            
