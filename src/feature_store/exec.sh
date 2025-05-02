# Navega para a pasta do script
cd "$(dirname "$0")" || exit 1

# Processa argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    -s) start_date="$2"; shift 2;;
    -e) end_date="$2"; shift 2;;
    *) echo "Argumento inválido: $1"; exit 1;;
  esac
done

# Verifica se as variáveis estão vazias
if [[ -z "$start_date" || -z "$end_date" ]]; then
  # Executa os scripts Python sem argumentos -s e -e
  python execute.py -f fs_general
  python execute.py -f fs_hour
  python execute.py -f fs_points
  python execute.py -f fs_products
  python execute.py -f fs_transactions
else
  # Executa os scripts Python com os argumentos -s e -e
  python execute.py -f fs_general -s "$start_date" -e "$end_date"
  python execute.py -f fs_hour -s "$start_date" -e "$end_date"
  python execute.py -f fs_points -s "$start_date" -e "$end_date"
  python execute.py -f fs_products -s "$start_date" -e "$end_date"
  python execute.py -f fs_transactions -s "$start_date" -e "$end_date"
fi