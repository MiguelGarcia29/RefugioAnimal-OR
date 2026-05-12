import oracledb
import configparser
import os

class DataBase:
    def __init__(self):
       # 1. Instanciar el lector de archivos .ini
        config = configparser.ConfigParser()
        
  
        ruta_archivo = os.path.join(os.path.dirname(__file__), 'datos.ini')
        config.read(ruta_archivo)

        try:
            self.user = config['ORACLE']['user']
            self.password = config['ORACLE']['password']
            self.dsn = config['ORACLE']['dsn']
        except KeyError as e:
            print(f"Error: No se encontró la clave {e} en el archivo datos.ini")
            self.user = self.password = self.dsn = None

    def conectar(self):
        try:
            conexion = oracledb.connect(
                user=self.user,
                password=self.password,
                dsn=self.dsn
            )
            return conexion
        except Exception as e:
            print(f"Error al conectar a Oracle: {e}")
            return None