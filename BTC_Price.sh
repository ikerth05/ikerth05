Éste script se ha creado para uso personal, donde cogemos el precio de BTC mediante la API de Kraken y hacemos un filtrado de los valores que necesitamos,
se establece un loop para que se actualize el precio cada 60 segundos. Éste precio lo podemos ver de forma gráfica mediante zenity en una ventana emergente.
Mediante if nos detecta el precio objetivo que le estipulamos, y en caso de llegar nos llega una llamada al número configurado mediante Twilio
#!/bin/bash
set -uo pipefail

URL=https://api.kraken.com/0/public/Ticker?pair=BTCEUR

call_count=0
fecha=$(date +"%H:%M:%S")
# Añadimos logs
if ls btc.log 2>/dev/null; then
    echo "$fecha SUCCESS [+] Se inicia script de forma exitosa" >> btc.log
else
    touch "btc.log"
    echo "$fecha SUCCESS [+] Se crea testigo log de forma exitosa" >> btc.log
    echo "$fecha SUCCESS [+] Se inicia script de forma exitosa" >> btc.log
fi

while true; do
    fecha=$(date +"%H:%M:%S")
    # Dejamos precio_btc null por si falla en algún loop que salte a else
    precio_btc=""
    if precio_btc=$(curl -fsS --connect-timeout 5 --max-time 8 "$URL" | tr -d '"',[],{},error,result,:.XB,T,Z,E,U,R,a' | head -c 6); then
        echo "$fecha SUCCESS [+] Se realiza CURL de forma exitosa" >> btc.log
        # Ajustamos a 5 o 6 dígitos
        if [[ $precio_btc == *"."* ]]; then
            precio_btc=$(echo "$precio_btc" | tr -d '.')
            echo "$fecha SUCCESS [+] Se reajusta a 5 dígitos" >> btc.log
        else
            precio_btc=$precio_btc
            echo "$fecha SUCCESS [+] Se reajusta a 6 dígitos" >> btc.log
        fi
        echo "# [$fecha] BTC/EUR: $precio_btc €" || true
        if (( $precio_btc > 100000 )) && (( $call_count < 2 )); then
            # Esto es para recibir llamadas automáticas con Twilio en caso de superar un precio de BTC
            {
                http=$(curl -sS -o /dev/null -w "%{http_code}" \
                -X POST "https://api.twilio.com/2010-04-01/Accounts/AC7605bc3b86e9c/Calls.json" \
                --data-urlencode "Url=https://handler.twilio.com/twiml/EH8fb0f2007b95a6419393be" \
                --data-urlencode "To=+34XXXXXXXXX" \
                --data-urlencode "From=+1XXXXXXXXX" \
                -u AC74b3bc63b948766e9c:c08ace869b32ba51e4c50b
                )
                echo "$fecha SUCCESS [+] Se lanza llamada automática de forma exitosa" >> btc.log
            } || {
                echo "$fecha ERROR [!] Fallo al contactar con Twilio, no se lanza llamada de forma automática" >> btc.log
                http=0
            }
            ((call_count++))
            echo "$fecha WARNING [!] ALERTA Call_Count tiene el valor $call_count" >> btc.log
        fi
    else
        echo "# [!] Kraken no ha respondido a la petición..." || true
        echo "$fecha ERROR [!] Kraken no ha respondido a la petición GET" >> btc.log
    fi
    echo "$fecha SUCCESS [+] Fin de ciclo..." >> btc.log
    sleep 60
done | zenity --progress \
    --title="Precio BTC Kraken" \
    --text="Cargando..." \
    --pulsate --auto-close --no-cancel
