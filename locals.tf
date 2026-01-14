locals {
  engine_ports = {
    postgres       = 5432
    mysql          = 3306
    mariadb        = 3306
    oracle-se2     = 1521
    oracle-ee      = 1521
    oracle-se2-cdb = 1521
    oracle-ee-cdb  = 1521
    sqlserver-ex   = 1433
    sqlserver-web  = 1433
    sqlserver-se   = 1433
    sqlserver-ee   = 1433
  }
}
