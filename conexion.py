import oracledb

class DataBase:
    def __init__(self):
        # Datos de conexión (Ajusta con los que te dio tu profesor)
        self.user = "refugio"
        self.password = "refugio"
        self.dsn = "localhost:1521/xepdb1" # Host:Puerto/Servicio

    def conectar(self):
        try:
            # El modo Thin no necesita Oracle Client instalado
            conexion = oracledb.connect(
                user=self.user,
                password=self.password,
                dsn=self.dsn
            )
            return conexion
        except Exception as e:
            print(f"Error al conectar a Oracle: {e}")
            return None