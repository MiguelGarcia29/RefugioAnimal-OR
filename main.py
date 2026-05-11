import sys
from PyQt5 import QtWidgets, uic
import vistas.animales as animales
import vistas.socios as socios
import vistas.adopcion as adopcion
import vistas.vacunacion as vacunacion

class MainApp(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        # Cargamos el cascarón (el que tiene el menú lateral)
        uic.loadUi("interfaz_principal.ui", self)

        # 2. Creamos las instancias de las pestañas
        self.pestana_animales = animales.AnimalesWindow()
        self.pestana_socios = socios.SociosWindow()
        self.pestana_adopcion = adopcion.AdopcionWindow()
        self.pestana_vacunacion = vacunacion.VacunacionWindow()

        # 3. LAS INYECTAMOS en el StackedWidget del cascarón
        self.stackedWidget.addWidget(self.pestana_animales)
        self.stackedWidget.addWidget(self.pestana_socios)
        self.stackedWidget.addWidget(self.pestana_adopcion)
        self.stackedWidget.addWidget(self.pestana_vacunacion)

        # 4. CONECTAMOS la navegación
        self.btn_animales.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.pestana_animales))
        self.btn_socios.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.pestana_socios))
        self.btn_adopcion.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.pestana_adopcion))
        self.btn_vacunacion.clicked.connect(lambda: self.stackedWidget.setCurrentWidget(self.pestana_vacunacion))

        # 5. Vista inicial
        self.stackedWidget.setCurrentWidget(self.pestana_animales)

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    window = MainApp()
    window.showMaximized()
    sys.exit(app.exec_())