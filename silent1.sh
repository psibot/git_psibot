export ORACLE_SID=$ORACLE_SID
$ORACLE_HOME/bin/sqlplus -s '/as sysdba' <<EOF
@prod_arch_silent.sql
exit
EOF

