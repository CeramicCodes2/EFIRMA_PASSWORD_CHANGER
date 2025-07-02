#!/bin/bash

echo "🔐 Cambiar contraseña de clave privada (.key) de e.firma (SAT)"
echo "---------------------------------------------------------------"

# Solicitar rutas
read -p "📂 Nombre del archivo .key original (ej: clave.key): " KEY_ORIGINAL
read -p "📂 Nombre del archivo .cer (ej: certificado.cer): " CERT
read -p "Nueva contraseña:" NEW_PASS
# Archivo con contraseña antigua (stdin)
if [[ ! -f "out.txt" ]]; then
  echo "❌ Error: No se encontró 'out.txt' con la contraseña antigua."
  exit 1
fi

# Archivo con nueva contraseña
#if [[ ! -f "file.txt" ]]; then
#  echo "❌ Error: No se encontró 'file.txt' con la nueva contraseña."
#  exit 1
#fi

# NEW_PASS=$(<file.txt)
KEY_TEMP="clave_temp.pem"
KEY_NUEVA="nueva_clave.key"

# Paso 1: Convertir la clave original DER cifrada a PEM sin cifrado
cat out.txt | openssl rsa -in "$KEY_ORIGINAL" -inform DER -out "$KEY_TEMP" -passin stdin
if [ $? -ne 0 ]; then
  echo "❌ Error: No se pudo descifrar la clave original. ¿La contraseña es correcta?"
  exit 1
fi

# Paso 2: Volver a cifrarla con DES-EDE3-CBC en DER
openssl pkcs8 -topk8 -inform PEM -in "$KEY_TEMP" -v2 des-ede3-cbc -v2prf hmacWithSHA1 -out "$KEY_NUEVA" -outform DER -passout pass:"$NEW_PASS"
if [ $? -ne 0 ]; then
  echo "❌ Error: No se pudo cifrar la clave con la nueva contraseña."
  rm -f "$KEY_TEMP"
  exit 1
fi

# Paso 3: Verificar que el módulo coincide con el certificado
MOD_CERT=$(openssl x509 -in "$CERT" -inform DER -noout -modulus 2>/dev/null | openssl md5)
MOD_KEY=$(openssl rsa -in "$KEY_NUEVA" -inform DER -passin pass:"$NEW_PASS" -noout -modulus 2>/dev/null | openssl md5)

echo ""
echo "🔍 Verificando integridad:"
echo "🔸 Módulo certificado:  $MOD_CERT"
echo "🔸 Módulo clave nueva:  $MOD_KEY"

if [ "$MOD_CERT" = "$MOD_KEY" ]; then
  echo "✅ Éxito: La nueva clave es válida y corresponde con el certificado."
else
  echo "❌ Error: La nueva clave NO corresponde con el certificado."
fi

# Paso 4: Validar cifrado usado en la nueva clave
echo ""
echo "🔎 Verificando cifrado de la nueva clave..."
ENC_INFO=$(openssl asn1parse -in "$KEY_NUEVA" -inform DER 2>/dev/null | grep "DES-EDE3-CBC")
if [[ -n "$ENC_INFO" ]]; then
  echo "✅ La clave está cifrada con Triple DES (DES-EDE3-CBC). Compatible con el SAT."
else
  echo "⚠️ Advertencia: No se detectó cifrado DES-EDE3-CBC. El SAT podría rechazar esta clave."
fi

# Limpieza
rm -f "$KEY_TEMP"

