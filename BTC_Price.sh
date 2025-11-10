Éste script se ha creado para uso personal, donde cogemos el precio de BTC mediante la API de Kraken y hacemos un filtrado de los valores que necesitamos,
se establece un loop para que se actualize el precio cada 60 segundos. Éste precio lo podemos ver de forma gráfica mediante zenity en una ventana emergente.
Mediante if nos detecta el precio objetivo que le estipulamos, y en caso de llegar nos llega una llamada al número configurado mediante Twilio
#!/bin/bash
set -euo pipefail

URL=https://api.kraken.com/0/public/Ticker?pair=BTCEUR

(
  while true; do
    precio_btc=$(curl -s $URL | tr -d '", [, ], {, }, error, result, :, ., X, B, T, Z, E, U, R, a' | head -c 5)
    fecha=$(date +"%H:%M:%S")
    if (( $precio_btc > 99999 )); then
      precio_btc100k=$(curl -s $URL | tr -d '", [, ], {, }, error, result, :, ., X, B, T, Z, E, U, R, a' | head -c 6)
      echo "# [${fecha}] BTC/EUR: $precio_btc100k €"
    else
      echo "# [${fecha}] BTC/EUR: $precio_btc €"
      if (( $precio_btc > 92000 )); then
        # Esto es para recibir llamadas automáticas con Twilio en caso de superar un precio de BTC
        curl -X POST "https://api.twilio.com/2010-04-01/Accounts/AC76535a52c93694866ec/Calls.json" \
        # En esta URL le pasamos el mensaje que nos va a decir cuando nos llame, activo llamada a 92k
        --data-urlencode "Url=https://handler.twilio.com/twiml/EH8fb02a07906442199fabe" \
        --data-urlencode "To=+34_NUESTRO_NUMERO" \
        --data-urlencode "From=+1_NUMERO_TWILIO" \
        # Le damos nuestro SID de la cuenta
        -u AC77463b305b3936986e9c:c08ac6b93d2b8dce450b
      fi
    fi
    sleep 60
  done
) | zenity --progress \
           --title="Precio BTC Kraken" \
           --text="Cargando..." \
           --pulsate --auto-close --no-cancel
