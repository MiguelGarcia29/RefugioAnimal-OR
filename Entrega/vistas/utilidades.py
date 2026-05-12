from PyQt5 import QtWidgets
from conexion import DataBase
        
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
                
def cargar_especies(self):
    db = DataBase()
    conn = db.conectar()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT id_especie, nombre_especie FROM Tabla_Especies")
            self.input_especie.clear()
            
            self.input_especie.addItem("Especie", None) 
            self.input_especie.setCurrentIndex(0) # Aseguramos que se vea el placeholder
            for id_, nombre in cursor.fetchall():
                self.input_especie.addItem(nombre, id_)
        finally:
            cursor.close()
            conn.close()
            
def cargar_razas(self):
    id_especie = self.input_especie.currentData()
    db = DataBase()
    conn = db.conectar()
    if conn:
        try:
            cursor = conn.cursor()
            
            if id_especie is None:
                cursor.execute("""
                    SELECT id_raza, nombre_raza
                    FROM Tabla_Razas
                """)
            else:
                cursor.execute("""
                    SELECT id_raza, nombre_raza
                    FROM Tabla_Razas
                    WHERE id_especie = :id
                """, {"id": id_especie})
            self.input_raza.clear()
            
            self.input_raza.addItem("Raza", None) 
            self.input_raza.setCurrentIndex(0)
            for id_, nombre in cursor.fetchall():
                self.input_raza.addItem(nombre, id_)
        finally:
            cursor.close()
            conn.close()
            
def on_raza_changed(self):
    id_raza = self.input_raza.currentData()
    if id_raza is None:
        return
    db = DataBase()
    conn = db.conectar()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT id_especie
                FROM Tabla_Razas
                WHERE id_raza = :id
            """, {"id": id_raza})
            row = cursor.fetchone()
            if not row:
                return
            id_especie = row[0]
            self.input_especie.blockSignals(True)
            index = self.input_especie.findData(id_especie)
            if index != -1:
                self.input_especie.setCurrentIndex(index)
            self.input_especie.blockSignals(False)
        finally:
            cursor.close()
            conn.close()